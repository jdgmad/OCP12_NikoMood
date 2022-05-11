//
//  AuthService.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 25/04/2022.
//

import Foundation
import FirebaseAuth

final class AuthService {

    // MARK: - Properties

    private let auth: AuthType
    var currentUID: String? { return auth.currentUID }
    var currentEmail: String? { return auth.currentEmail}

    // MARK: - Initializer

    init(auth: AuthType = AuthFirebase()) {
        self.auth = auth
    }

    // MARK: - Auth Methods

    func signIn(email: String, password: String, callback: @escaping (Bool) -> Void) {
        auth.signIn(email: email, password: password, callback: callback)
        
    }

    func signUp(email: String, password: String, callback: @escaping (Result<Bool, FirebaseError>) -> Void) {
        auth.signUp(email: email, password: password, callback: callback)
    }

    func signOut(callback: @escaping (Bool) -> Void) {
        auth.signOut(callback: callback)
    }

    func isUserConnected(callback: @escaping (Bool) -> Void) {
        auth.isUserConnected(callback: callback)
    }
}
