//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify

extension AWSAuthPlugin {

    public func reset(onComplete: @escaping BasicClosure) {

        if authorizationProvider != nil {
            authorizationProvider.reset()
            authorizationProvider = nil
        }
        if authenticationProvider != nil {
            authenticationProvider = nil
        }
        if userService != nil {
            userService = nil
        }
        if deviceService != nil {
            deviceService = nil
        }
        onComplete()
    }
}
