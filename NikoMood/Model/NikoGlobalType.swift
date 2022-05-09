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
    "No instructions list".localized(),
    "Procedure not updated".localized(),
    "No respect procedure or rules".localized(),
    "Bad communication".localized(),
    "Bad organisation".localized(),
    "Cause 6 methods".localized(),
    "Cause 7 methods".localized(),
]

public var causeMatiere = [
    "Bad materials quality".localized(),
    "Materials out of stock".localized(),
    "Materials on excedent".localized(),
    "Electrical blackout".localized(),
    "Cause 6 matierials".localized(),
    "Cause 7 matierials".localized(),
]

public var causeMachine = [
    "Machine break down".localized(),
    "Lack of maintenance".localized(),
    "Lack of cleanning".localized(),
    "Bad machine".localized(),
    "Lack of documentation".localized(),
    "Cause 6 machinery".localized(),
    "Cause 7 machinery".localized(),
]

public var causeMaindoeuvre = [
    "Lack of competencies".localized(),
    "Lack of people/load".localized(),
    "Absenteism".localized(),
    "Lack of involvement".localized(),
    "Lack of versatility".localized(),
    "Cause 6 manpower".localized(),
    "Cause 7 manpower".localized(),
]

public var causeMilieu = [
    "Ergonomics at workplace".localized(),
    "Flow in starvation".localized(),
    "Flow in saturation".localized(),
    "Cause 4 management".localized(),
    "Cause 5 management".localized(),
    "Cause 6 management".localized(),
    "Cause 7 management".localized(),
]


