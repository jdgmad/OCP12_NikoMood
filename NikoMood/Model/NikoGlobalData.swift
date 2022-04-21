//
//  NikoRecordModel.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 28/03/2022.
//

import Foundation


enum NikoStatus {
    case nikoNTR, nikoTought, NikoSuper
}

enum cause5M {
    case methode, matiere, machine, maindoeuvre, milieu
}

enum FirebaseError: Error {
    case errSignin, errSignup, noUserConnected, noDocUser, errGettingDoc
}

//extension FirebaseError: CustomStringConvertible {
//    var description: String {
//        switch self {
//        case .errSignin: return "Erreur Signin"
//        case .errSignup: return "Erreur Signout"
//        case .noUserConnected: return "Pas d'utilisteur connecté"
//        case .noDocUser: return "Pas de document utilisateur"
//        case .errGettingDoc: return "Erreur accès document"
//        }
//    }
//}


public var causeMethode = [
        "Pas de Modes opératoires",
        "Procédures non à jour",
        "Cause 3 methode",
        "Cause 4 methode",
        "Cause 5 methode",
        "Cause 6 methode",
        "Cause 7 methode",
]

public var causeMatiere = [
        "Qualité matière première",
        "Rupture matière première",
        "Coupure électricité",
        "Cause 4 matiere",
        "Cause 5 matiere",
        "Cause 6 matiere",
        "Cause 7 matiere",
]

public var causeMachine = [
        "Cause 1 machine",
        "Cause 2 machine",
        "Cause 3 machine",
        "Cause 4 machine",
        "Cause 5 machine",
        "Cause 6 machine",
        "Cause 7 machine",
]

public var causeMaindoeuvre = [
        "Cause 1 maindoeuvre",
        "Cause 2 maindoeuvre",
        "Cause 3 maindoeuvre",
        "Cause 4 maindoeuvre",
        "Cause 5 maindoeuvre",
        "Cause 6 maindoeuvre",
        "Cause 7 maindoeuvre",
]

public var causeMilieu = [
        "Cause 1 milieu",
        "Cause 2 milieu",
        "Cause 3 milieu",
        "Cause 4 milieu",
        "Cause 5 milieu",
        "Cause 6 milieu",
        "Cause 7 milieu",
]
