//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

public typealias GraphQLOperation<R: Decodable> = AmplifyOperation<
    GraphQLOperationRequest<R>,
    GraphQLResponse<R>,
    APIError>

// TODO: Figure out a publisher for SubscriptionEvent<GraphQLResponse<R>>. Subscription network level errors are the
// Failure case of the Result; successful termination is a Result<Void>
public typealias GraphQLSubscriptionOperation<R: Decodable> = AmplifyOperation<
    GraphQLOperationRequest<R>,
    Void,
    APIError>

public extension HubPayload.EventName.API {
    /// eventName for HubPayloads emitted by this operation
    static let mutate = "API.mutate"
    static let query = "API.query"
    static let subscribe = "API.subscribe"
}
