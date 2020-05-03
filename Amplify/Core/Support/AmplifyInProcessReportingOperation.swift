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
    public typealias InProcessListener = (InProcess) -> Void

    var inProcessListener: InProcessListener?

    public init(categoryType: CategoryType,
                eventName: HubPayloadEventName,
                request: Request,
                inProcessListener: InProcessListener? = nil,
                resultListener: ResultListener? = nil) {
        self.inProcessListener = inProcessListener

        // This will invoke `subscribe` if `listener` is not nil
        super.init(categoryType: categoryType, eventName: eventName, request: request, listener: resultListener)

        // We know the super.init() implementation only invokes `subscribe` if `listener` is not nil, but we want
        // to release the progressListener if it is present, regardless of the state of `listener`. Catch the case
        // where we have a progress listener but no result listener
        if inProcessListener != nil, resultListener == nil {
            let releasingListener: ResultListener = { [weak self] result in
                self?.inProcessListener = nil
            }
            self.unsubscribeToken = super.subscribe(listener: releasingListener)
        }
    }

    // Override default behavior with a subscription that releases the progressListener
    override func subscribe(listener: @escaping ResultListener) -> UnsubscribeToken {
        let wrappedListener: ResultListener = { [weak self] result in
            self?.inProcessListener = nil
            listener(result)
        }
        return super.subscribe(listener: wrappedListener)
    }

    // Provide a handle for Hub.listen() to register progress and result listeners
    func subscribe(inProcessListener: InProcessListener?,
                   resultListener: ResultListener?) -> UnsubscribeToken {
        self.inProcessListener = inProcessListener
        let wrappedListener: ResultListener = { [weak self] result in
            self?.inProcessListener = nil
            resultListener?(result)
        }
        return super.subscribe(listener: wrappedListener)
    }

}
