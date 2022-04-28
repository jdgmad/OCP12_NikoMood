//
//  FirestoreError.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 30/03/2022.
//

import Foundation


enum FirebaseError: Error {
    case errSignin, errSignup, errSignout, noUserConnected, noDocUser, errGettingDoc, errWritingData
}

extension FirebaseError: CustomStringConvertible {
    var description: String {
        switch self {
        case .errSignin: return "Erreur Signin"
        case .errSignup: return "Erreur Signup"
        case .errSignout: return "Erreur Signout"
        case .noUserConnected: return "Pas d'utilisteur connecté"
        case .noDocUser: return "Pas de document utilisateur"
        case .errGettingDoc: return "Erreur accès document"
        case .errWritingData: return "Erreur enregistrement de données"
        }
    }
}
