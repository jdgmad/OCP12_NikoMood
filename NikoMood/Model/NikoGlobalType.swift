//
//  NikoRecordModel.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 28/03/2022.
//

import Foundation
import FirebaseFirestoreSwift

enum NikoStatus {
    case nikoNTR, nikoTought, NikoSuper
}

enum cause5M {
    case methode, matiere, machine, maindoeuvre, milieu
}

struct NikoUser: Codable {
    @DocumentID var id: String?
    var userID : String
    var firstname : String
    var lastname : String
    var position : String
    var plant : String
    var department : String
    var workshop : String
    var shift : String
    var permission : Int
    var password : String
    var birthday : Date
    var email: String
}

struct NikoRecord: Codable {
    @DocumentID var id: String?
    var userID : String
    var firstname : String
    var lastname : String
    var position : String
    var plant : String
    var department : String
    var workshop : String
    var shift : String
    var nikoStatus: String
    var nikoRank : Int
    var niko5M : String
    var nikoCause : String
    var nikoComment : String
    var permission : Int
    var date : Date
    var formattedMonthString : String
    var formattedDateString : String
    var formattedYearString : String
    var error : String?
}

struct NikoTCD {
    var rankAverage: Int
    var nbRecord: Int
    var nbSuper: Int
    var nbNTR: Int
    var nbTought: Int
    var nbMethod: Int
    var nbMatiere: Int
    var nbMachine: Int
    var nbMaindoeuvre: Int
    var nbMilieu: Int
    
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


