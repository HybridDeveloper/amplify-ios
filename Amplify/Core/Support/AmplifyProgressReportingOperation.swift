//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// An AmplifyOperation that emits Progress events intermittently
open class AmplifyProgressReportingOperation<
    Request: AmplifyOperationRequest,
    Success,
    Failure: AmplifyError
>: AmplifyOperation<Request, Success, Failure> {
    var progressListener: ProgressListener?

    public init(categoryType: CategoryType,
                eventName: HubPayloadEventName,
                request: Request,
                resultListener: ResultListener? = nil,
                progressListener: ProgressListener? = nil) {
        self.progressListener = progressListener

        // This will invoke `subscribe` if `listener` is not nil
        super.init(categoryType: categoryType, eventName: eventName, request: request, listener: resultListener)

        // We know the super.init() implementation only invokes `subscribe` if `listener` is not nil, but we want
        // to release the progressListener if it is present, regardless of the state of `listener`. Catch the case
        // where we have a progress listener but no result listener
        if progressListener != nil, resultListener == nil {
            let releasingListener: ResultListener = { [weak self] result in
                self?.progressListener = nil
            }
            self.unsubscribeToken = super.subscribe(listener: releasingListener)
        }
    }

    // Override default behavior with a subscription that releases the progressListener
    override func subscribe(listener: @escaping ResultListener) -> UnsubscribeToken {
        let wrappedListener: ResultListener = { [weak self] result in
            self?.progressListener = nil
            listener(result)
        }
        return super.subscribe(listener: wrappedListener)
    }

    // Provide a handle for Hub.listen() to register progress and result listeners
    func subscribe(progressListener: ProgressListener?,
                   resultListener: ResultListener?) -> UnsubscribeToken {
        self.progressListener = progressListener
        let wrappedListener: ResultListener = { [weak self] result in
            self?.progressListener = nil
            resultListener?(result)
        }
        return super.subscribe(listener: wrappedListener)
    }

}
