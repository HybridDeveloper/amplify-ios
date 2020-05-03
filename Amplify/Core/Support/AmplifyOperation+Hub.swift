//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

public extension HubCategory {

    /// Convenience method to allow callers to listen to Hub events for a particular operation. Internally, the listener
    /// transforms the HubPayload into the Operation's expected AsyncEvent type, so callers may re-use their `listener`s
    ///
    /// - Parameter operation: The operation to monitor for results
    /// - Parameter listener: The Operation-specific listener callback to be invoked when an AsyncEvent for that
    ///   operation is received.
    func listen<Request: AmplifyOperationRequest, Success, Failure: AmplifyError>(
        to operation: AmplifyOperation<Request, Success, Failure>,
        listener: @escaping AmplifyOperation<Request, Success, Failure>.ResultListener)
        -> UnsubscribeToken {
            return operation.subscribe(listener: listener)
    }

    /// Convenience method to allow callers to listen to Hub events for a particular operation. Internally, the listener
    /// transforms the HubPayload into the Operation's expected AsyncEvent type, so callers may re-use their `listener`s
    ///
    /// - Parameter operation: The progress reporting operation monitor for progress and results
    /// - Parameter progressListener: The ProgressListener callback to be invoked when the operation emits a progress
    ///   update
    /// - Parameter resultListener: The Operation-specific listener callback to be invoked when an AsyncEvent for that
    ///   operation is received
    func listen<Request: AmplifyOperationRequest, Success, Failure: AmplifyError>(
        to operation: AmplifyProgressReportingOperation<Request, Success, Failure>,
        progressListener: ProgressListener?,
        resultListener: AmplifyOperation<Request, Success, Failure>.ResultListener?)
        -> UnsubscribeToken {
            return operation.subscribe(progressListener: progressListener, resultListener: resultListener)
    }
}
