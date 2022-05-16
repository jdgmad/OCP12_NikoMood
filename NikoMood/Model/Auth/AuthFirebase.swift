//
//  AuthFirebase.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 25/04/2022.
//

import Foundation
import FirebaseAuth
import Firebase

protocol AuthType {
    var currentUID: String? { get }
    var currentEmail: String? { get }
    func signIn(email: String, password: String, callback: @escaping (Bool) -> Void)
    func signUp(email: String, password: String, callback: @escaping (Result<Bool, FirebaseError>) -> Void)
    func signOut(callback: @escaping (Bool) -> Void)
    func isUserConnected(callback: @escaping (Bool) -> Void)
}

final class AuthFirebase: AuthType {
    
    // MARK: - Properties
    
    var currentUID: String? {
        return Auth.auth().currentUser?.uid
    }
    var currentEmail: String? {
        return Auth.auth().currentUser?.email
    }
    
    // MARK: - Auth Methods
    
    func signIn(email: String, password: String, callback: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            guard (authDataResult != nil), error == nil else {
                callback(false)
                return
            }
            callback(true)
        }
    }
    
    func signUp(email: String, password: String, callback: @escaping (Result<Bool, FirebaseError>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
            guard let authDataResult = authDataResult, error == nil else {
                callback(.failure(.errSignup))
                return
            }
            let  authUserID =  authDataResult.user.uid
            let db = Firestore.firestore()
            let usersRef = db.collection("users")
            usersRef.whereField("email", isEqualTo: email)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        callback(.failure(.errSignup))
                        return
                    } else {
                        // Check if the email is in the company list
                        if querySnapshot?.documents.count == 1 {
                            // Store the Auth user ID in the collection users
                            for document in querySnapshot!.documents {
                                let userDocumentID = document.documentID
                                let userDoc = db.collection("users").document(userDocumentID)
                                userDoc.updateData(["userID": authUserID]) { err in
                                    if let err = err {
                                        print ("Erreur update \(err)")
                                        //self.showError("Error updating document: \(err)")
                                        callback(.failure(.errWritingData))
                                        return
                                    } else {
                                        //print("Document successfully updated")
                                        callback(.success(true))
                                        return
                                    }
                                }
                            }
                        } else {
                            //self.showError("Vous n'êtes pas identifié dans la liste des salariés")
                            callback(.failure(.errEmailNotEnable))
                            return
                        }
                    }
                }
        }
    }
    
    func signOut(callback: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            callback(true)
        } catch {
            callback(false)
        }
    }
    
    func isUserConnected(callback: @escaping (Bool) -> Void) {
        if Auth.auth().currentUser != nil {
            callback(true)
        } else {
            callback(false)
        }
    }
}
