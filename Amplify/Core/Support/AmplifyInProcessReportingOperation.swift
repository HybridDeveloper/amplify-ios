//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// An AmplifyOperation that emits InProcess values intermittently during the operation.
///
/// Unlike a regular `AmplifyOperation`, which emits a single Result at the completion of the operation's work, an
/// `AmplifyInProcessReportingOperation` may emit intermediate values while its work is ongoing. These values could be
/// incidental to the operation (such as a `Storage.downloadFile` operation reporting Progress values periodically as
/// the download proceeds), or they could be the primary delivery mechanism for an operation (such as a
/// `GraphQLSubscriptionOperation`'s emitting new subscription values).
open class AmplifyInProcessReportingOperation<
    Request: AmplifyOperationRequest,
    InProcess,
    Success,
    Failure: AmplifyError
>: AmplifyOperation<Request, Success, Failure> {
    var inProcessListenerUnsubscribeToken: UnsubscribeToken?
    var secondaryResultListenerToken: UnsubscribeToken?

    public init(categoryType: CategoryType,
                eventName: HubPayloadEventName,
                request: Request,
                inProcessListener: InProcessListener? = nil,
                resultListener: ResultListener? = nil) {

        super.init(categoryType: categoryType, eventName: eventName, request: request, resultListener: resultListener)

        // If the inProcessListener is present, we need to register a hub event listener for it, and ensure we
        // automatically unsubscribe when we receive a completion event for the operation
        if let inProcessListener = inProcessListener {
            let inProcessToken = subscribe(inProcessListener: inProcessListener)
            self.inProcessListenerUnsubscribeToken = inProcessToken
            self.secondaryResultListenerToken = removeListenerUponCompletion(listenerToken: inProcessToken)
        }
    }

    // Provide a handle for Hub.listen() to register progress and result listeners
    func subscribe(inProcessListener: @escaping InProcessListener) -> UnsubscribeToken {
        let channel = HubChannel(from: categoryType)
        let filterById = HubFilters.forOperation(self)

        let progressHubListener: HubListener = { payload in
            guard let inProcessData = payload.data as? InProcess else {
                return
            }
            inProcessListener(inProcessData)
        }

        let progressListenerToken = Amplify.Hub.listen(to: channel,
                                                       isIncluded: filterById,
                                                       listener: progressHubListener)

        _ = removeListenerUponCompletion(listenerToken: progressListenerToken)

        return progressListenerToken
    }

    private func removeListenerUponCompletion(listenerToken: UnsubscribeToken) -> UnsubscribeToken {
        var removerToken: UnsubscribeToken!
        removerToken = Amplify.Hub.listenForResult(to: self) { _ in
            Amplify.Hub.removeListener(listenerToken)
            Amplify.Hub.removeListener(removerToken)
        }
        return removerToken
    }
}

public extension AmplifyInProcessReportingOperation {
    /// Convenience typealias for the `inProcessListener` callback submitted during Operation creation
    typealias InProcessListener = (InProcess) -> Void

    /// Dispatches an event to the hub. Internally, creates an `AmplifyOperationContext` object from the
    /// operation's `id`, and `request`
    /// - Parameter result: The OperationResult to dispatch to the hub as part of the HubPayload
    func dispatchInProcess(data: InProcess) {
        let channel = HubChannel(from: categoryType)
        let context = AmplifyOperationContext(operationId: id, request: request)
        let payload = HubPayload(eventName: eventName, context: context, data: data)
        Amplify.Hub.dispatch(to: channel, payload: payload)
    }

    /// Removes the listener that was registered during operation instantiation
    func removeInProcessResultListener() {
        if let inProcessListenerUnsubscribeToken = inProcessListenerUnsubscribeToken {
            Amplify.Hub.removeListener(inProcessListenerUnsubscribeToken)
        }

        if let secondaryResultListenerToken = secondaryResultListenerToken {
            Amplify.Hub.removeListener(secondaryResultListenerToken)
        }
    }

}
