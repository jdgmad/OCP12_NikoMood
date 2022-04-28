//
//  AuthManager.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 25/04/2022.
//

/*

import Foundation



private let authService: AuthService = AuthService()

func loginUser(email: String, password: String, completionHandler: @escaping (Result<[NikoRecord], FirebaseError>) -> Void) {

    authService.signIn(email: login, password: password) { isSuccess in
        if isSuccess {
            self.dismiss(animated: true)
        }
    AuthService.signIn(email: email, password: password) { (result, error) in
    if error != nil {
        // Couldn't sign in
        completionHandler(.failure(.errSignin))
        self.currentNiko.error = error!.localizedDescription
        return
    }
    else {
        if Auth.auth().currentUser != nil {
            if let user = Auth.auth().currentUser {
                let uid = user.uid
                self.retrieveUserData(uid: uid) {(resultData) in
                    switch resultData {
                    case .success(_):
                        completionHandler(.success([self.currentNiko]))
                        
                    case .failure(let error):
                        completionHandler(.failure(error))
                    }
                }
            }
        }else {
                completionHandler(.failure(.noUserConnected))
                return
        }
    }
    }
}

func deconnectUser(completionHandler: @escaping (Result<Bool, FirebaseError>) -> Void) {
    do {
        try Auth.auth().signOut()
        completionHandler(.success(true))
    } catch {
        completionHandler(.failure(.errSignout))
    }
}


*/
