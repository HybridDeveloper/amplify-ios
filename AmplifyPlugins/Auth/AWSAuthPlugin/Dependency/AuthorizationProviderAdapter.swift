//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSMobileClient

typealias SessionCompletionHandler = (Result<AuthSession, AuthError>) -> Void

class AuthorizationProviderAdapter: AuthorizationProviderBehavior {

    let awsMobileClient: AWSMobileClientBehavior

    init(awsMobileClient: AWSMobileClientBehavior) {
        self.awsMobileClient = awsMobileClient
        setupListener()
    }

    func fetchSession(request: AuthFetchSessionRequest,
                      completionHandler: @escaping SessionCompletionHandler) {

        switch awsMobileClient.getCurrentUserState() {
        case .guest:
            fetchSignedOutSession(completionHandler)
        case .signedIn,
             .signedOutFederatedTokensInvalid,
             .signedOutUserPoolsTokenInvalid:
            fetchSignedInSession(completionHandler)
        case .signedOut,
             .unknown:
            fetchSignedOutSession(completionHandler)
        }
    }

    func invalidateCachedTemporaryCredentials() {
        awsMobileClient.invalidateCachedTemporaryCredentials()
    }

    private func setupListener() {
        awsMobileClient.addUserStateListener(self) { [weak self] state, _ in
            guard let self = self else {
                return
            }
            switch state {
            case .signedOutFederatedTokensInvalid,
                 .signedOutUserPoolsTokenInvalid:
                print("AWSMobileClient Event listener - \(state)")
                // These two state are returned when the session expired. It is safe to call releaseSignInWait from here
                // because AWSMobileClient had just locked the signIn state before sending out this state. This will
                // fail if someone else is listening to the state and called releaseSignInWait, signOut or signIn apis
                // of awsmobileclient.
                self.awsMobileClient.releaseSignInWait()
            default:
                print("AWSMobileClient Event listener - \(state)")
            }
        }
    }

    func reset() {
        awsMobileClient.removeUserStateListener(self)
        awsMobileClient.signOut()
        awsMobileClient.clearCredentials()
        awsMobileClient.clearKeychain()
    }
}
