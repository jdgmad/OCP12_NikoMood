//
//  FirestoreSession.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 30/03/2022.
//

import Foundation
import Firebase

class FirestoreSession: FirestoreProtocol {

    func firestoresSignIn (withEmail: String, password: String, completionHandler: @escaping (Result<Any, Error>) -> Void) {
        Auth.auth().signIn(withEmail: withEmail, password: password) { AuthDataResult, Error in
        }
    }
    
    //func retrieveUserData (uid: String, completionHandler: @escaping (Result<[NikoRecord], FirebaseError>) -> Void) {
        
}

