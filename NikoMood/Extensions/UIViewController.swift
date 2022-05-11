//
//  File.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 24/03/2022.
//


import UIKit

extension UIViewController {
    
    /// Alert message to user
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    /// Alert Network error message to user
    func presentFirebaseAlert(typeError: FirebaseError, message: String) {
        //var message: String
        var title: String

        switch typeError {
        case .errSignin:
            title = "Signin error"
        case .errSignup:
            title = "Signup error"
        case .errSignout:
            title = "Erreur Signout"
        case .noUserConnected:
            title = "no user connected"
        case .noDocUser:
            title = "no document user"
        case .errGettingDoc:
            title = "Access to document Firestore"
        case .errWritingData:
            title = "Firestore data"
        case .errEmailNotEnable:
            title = "Signup error"
        }
        
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
