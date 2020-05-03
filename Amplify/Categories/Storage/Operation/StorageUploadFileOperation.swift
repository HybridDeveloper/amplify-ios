//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

// TODO: Figure out a progress publisher for this

public protocol StorageUploadFileOperation: AmplifyOperation<StorageUploadFileRequest, String, StorageError> {}

public extension HubPayload.EventName.Storage {
    /// eventName for HubPayloads emitted by this operation
    static let uploadFile = "Storage.uploadFile"
}
