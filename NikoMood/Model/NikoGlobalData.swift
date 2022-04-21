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

public var causeMethode = [
        "Pas de Modes opératoires",
        "Procédures non à jour",
        "Non respect des régles/procédures",
        "Mauvaise communication",
        "Mauvaise organisation",
        "Cause 6 methode",
        "Cause 7 methode",
]

public var causeMatiere = [
        "Qualité matière première",
        "Rupture matière première",
        "Exédent matiere premiere",
        "Coupure énergie",
        "Coupure énergie",
        "Cause 6 matiere",
        "Cause 7 matiere",
]

public var causeMachine = [
        "Machine en panne",
        "Manque de maintenance",
        "Manque de nettoyage",
        "Mauvais fonctionnement machine",
        "Manque de documentation",
        "Cause 6 machine",
        "Cause 7 machine",
]

public var causeMaindoeuvre = [
        "Manque de compétences",
        "Manque d'effectif/charge",
        "Absentéisme",
        "Manque d'implication",
        "Cause 5 maindoeuvre",
        "Cause 6 maindoeuvre",
        "Cause 7 maindoeuvre",
]

public var causeMilieu = [
        "Ergonomie au poste de travail",
        "Flux en famine",
        "Flus en saturation",
        "Cause 4 milieu",
        "Cause 5 milieu",
        "Cause 6 milieu",
        "Cause 7 milieu",
]

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
