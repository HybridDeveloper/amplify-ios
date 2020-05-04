//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Foundation

struct HubListenerTestUtilities {

    /// Blocks current thread until the listener with `token` is attached to the plugin. Returns `true` if the listener
    /// becomes present before the `timeout` expires, `false` otherwise.
    ///
    /// - Parameter token: the token identifying the listener to wait for
    /// - Parameter plugin: the plugin on which the listener will be checked
    /// - Parameter timeout: the maximum length of time to wait for the listener to be registered
    /// - Throws: if the plugin cannot be cast to `AWSHubPlugin`
    static func waitForListener(with token: UnsubscribeToken,
                                plugin: HubCategoryPlugin? = nil,
                                timeout: TimeInterval,
                                file: StaticString = #file,
                                line: UInt = #line) throws -> Bool {

        let plugin = try plugin ?? Amplify.Hub.getPlugin(for: AWSHubPlugin.key)

        guard let resolvedPlugin = plugin as? AWSHubPlugin else {
            throw "Could not cast plugin as AWSHubPlugin (\(file) L\(line))"
        }

        var hasListener = false

        let deadline = Date(timeIntervalSinceNow: timeout)
        while !hasListener && Date() < deadline {
            if resolvedPlugin.hasListener(withToken: token) {
                hasListener = true
                break
            }
            Thread.sleep(forTimeInterval: 0.01)
        }

        return hasListener
    }

    /// Blocks current thread until the listener with `token` is not attached to the plugin. Returns `true` if the
    /// listener becomes absent before the `timeout` expires, `false` otherwise.
    ///
    /// - Parameter token: the token identifying the listener to wait for
    /// - Parameter plugin: the plugin on which the listener will be checked
    /// - Parameter timeout: the maximum length of time to wait for the listener to be removed
    /// - Parameter onSuccess: a closure to be invoked if the listener is removed within the specified interval
    static func waitForListenerToBeRemoved(with token: UnsubscribeToken,
                                           plugin: HubCategoryPlugin? = nil,
                                           timeout: TimeInterval = 1.0,
                                           file: StaticString = #file,
                                           line: UInt = #line,
                                           onSuccess: BasicClosure) throws {
        let plugin = try plugin ?? Amplify.Hub.getPlugin(for: AWSHubPlugin.key)

        guard let resolvedPlugin = plugin as? AWSHubPlugin else {
            throw "Could not cast plugin as AWSHubPlugin (\(file) L\(line))"
        }

        let deadline = Date(timeIntervalSinceNow: timeout)
        while Date() < deadline {
            if !resolvedPlugin.hasListener(withToken: token) {
                onSuccess()
                break
            }
            Thread.sleep(forTimeInterval: 0.01)
        }
    }

}
