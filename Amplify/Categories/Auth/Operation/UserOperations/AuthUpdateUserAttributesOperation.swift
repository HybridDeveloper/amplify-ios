//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

public protocol AuthUpdateUserAttributesOperation: AmplifyOperation<AuthUpdateUserAttributesRequest,
    Void,
    [AuthUserAttributeKey: AuthUpdateAttributeResult],
AuthError> {}

public extension HubPayload.EventName.Auth {

    /// eventName for HubPayloads emitted by this operation
    static let updateUserAttributes = "Auth.updateUserAttributes"
}
