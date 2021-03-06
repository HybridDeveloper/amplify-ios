//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

public enum AuthStrategy {
    case owner
    case groups
    case `private`
    case `public`
}

public enum AuthProvider {
    case apiKey
    case iam
    case oidc
    case userPools
}

public enum ModelOperation {
    case create
    case update
    case delete
    case read
}

public typealias AuthRules = [AuthRule]

public struct AuthRule {
    public let allow: AuthStrategy
    public let field: CodingKey?
    public let provider: AuthProvider?
    public let ownerField: CodingKey?
    public let identityClaim: String?
    public let groupClaim: String?
    public let groups: [String]
    public let groupsField: CodingKey?
    public let operations: [ModelOperation]

    public init(allow: AuthStrategy,
                field: CodingKey? = nil,
                provider: AuthProvider? = nil,
                ownerField: CodingKey? = nil,
                identityClaim: String? = nil,
                groupClaim: String? = nil,
                groups: [String] = [],
                groupsField: CodingKey? = nil,
                operations: [ModelOperation] = []) {
        self.allow = allow
        self.field = field
        self.provider = provider
        self.ownerField = ownerField
        self.identityClaim = identityClaim
        self.groupClaim = groupClaim
        self.groups = groups
        self.groupsField = groupsField
        self.operations = operations
    }
}
