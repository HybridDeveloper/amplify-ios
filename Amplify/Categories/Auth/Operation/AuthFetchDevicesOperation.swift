//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

public protocol AuthFetchDevicesOperation: AmplifyOperation<AuthFetchDevicesRequest,
    Void,
    [AuthDevice],
AuthError> {}

public extension HubPayload.EventName.Auth {

    /// eventName for HubPayloads emitted by this operation
    static let fetchDevices = "Auth.fetchDevices"
}
