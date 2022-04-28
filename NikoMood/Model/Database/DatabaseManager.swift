//
//  DatabaseManager.swift
//  FirebaseLoginScreen
//
//  Created by Sebastien Bastide on 02/02/2020.
//  Copyright © 2020 Sebastien Bastide. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class DatabaseManager {

    // MARK: - Properties

    private let database: DatabaseType
    private let authService: AuthService = AuthService()

    var dataTCDMonth = [NikoTCD]()
    var dataTCDYear = [NikoTCD]()
    var dataCause5M = [Dictionary<String, Int>.Element]()
    //var dataCause5M = [String : Int]()

    var currentNikoTCD = NikoTCD(rankAverage: -1, nbRecord: 0, nbSuper: 0, nbNTR: 0, nbTought: 0, nbMethod: 0, nbMatiere: 0, nbMachine: 0, nbMaindoeuvre: 0, nbMilieu: 0)

    var currentNiko = NikoRecord(userID: "", firstname: "", lastname: "", position: "", plant: "", department: "", workshop: "", shift: "", nikoStatus: "", nikoRank: 0, niko5M: "", nikoCause: "", nikoComment: "", permission: 0, date: Date(), formattedMonthString: "", formattedDateString : "", formattedYearString: "", error: "")

    var currentUser = NikoUser(id: "", userID: "", firstname: "", lastname: "", position: "", plant: "", department: "", workshop: "", shift: "",  permission: 0, password: "", birthday: Date(), email: "")

    var paramQueryField = ["plant", "workshop", "shift"  ]

    var category5M = ["methode", "matiere", "machine", "maindoeuvre", "milieu"]

    // MARK: - Initialization

    init(database: DatabaseType = FirebaseDatabase()) {
        self.database = database
    }

    // MARK: - Read Queries

    func getUserData(with uid: String, callback: @escaping (Result<NikoRecord, FirebaseError>) -> Void) {
        database.getUserData(with: uid) { (result) in
            switch result {
            case .success(let data):
                if data.documents.count == 1 {
                    for document in data.documents {
                        do {
                            let decodeData = try document.data(as: NikoUser.self)
                            self.currentUser = decodeData!
                            self.transfertDataUserToNikoRecord()
                            callback(.success(self.currentNiko))
                            return
                        }
                        catch {
                            print("erreur catch in func retrieveUserData")
                            callback(.failure(.errGettingDoc))
                            return
                        }
                    }
                }
            case .failure(let err):
                callback(.failure(err))
            }
        }
    }
    
    func storeNikoRecord (record : NikoRecord, callback: @escaping (Bool) -> Void) {
        
        // MARK: - Properties
        
        let calendarHelper = CalendarHelper()
        let date = currentNiko.date
        let error = (currentNiko.error ?? "")
        let docData: [String: Any] = ([
            "userID": currentUser.userID,
            "firstname": currentUser.firstname,
            "lastname": currentUser.lastname,
            "position": currentUser.position,
            "plant": currentUser.plant,
            "department": currentUser.department,
            "workshop": currentUser.workshop,
            "shift": currentUser.shift,
            "nikoStatus": currentNiko.nikoStatus,
            "nikoRank": currentNiko.nikoRank,
            "niko5M": currentNiko.niko5M,
            "nikoCause": currentNiko.nikoCause,
            "nikoComment": currentNiko.nikoComment,
            "permission": currentNiko.permission,
            "date": currentNiko.date,
            "formattedMonthString": calendarHelper.monthString(date: date),
            "formattedDateString": calendarHelper.dateString(date: date),
            "formattedYearString": calendarHelper.yearString(date: date),
            "error": error
        ])
        
        database.addRecord(docData : docData) { result in
            if result {
            callback(true)
            } else {
            callback(false)
            }
        }
    }
    
    func checkIfRecordExist (uid: String, dateSelected: Date, callback: @escaping (Bool) -> Void)  {
        // Retrieve the user data
        let calendarHelper = CalendarHelper()
        let dateString = calendarHelper.dateString(date: dateSelected)
        
        database.checkIfRecordExist(uid: uid, dateString: dateString) { (result) in 
            if result {
                callback(true)
            } else {
                callback(false)
            }
        }
    }
    
    func requestRecordUserRetrievelocalisationData (uid: String,
                                                  selectedDate: Date,
                                                  location : [String],
                                                  personnal : Bool,
                                                  monthVsYear: Bool,
                                                  ishikawa : Bool,
                                                  callback: @escaping (Result<[NikoTCD], FirebaseError>) -> Void) {
        //var calendarNiko = Array(repeating: -1 , count: 42)
        var records = [NikoRecord]()

        dataTCDMonth = Array(repeating: currentNikoTCD, count: 31)
        dataTCDYear = Array(repeating: currentNikoTCD, count: 12)
        
        //calendarNiko = razCalendarNiko(listDay: calendarNiko)

        database.getQuery(uid: uid, location: location, monthVsYear: monthVsYear, personnal: personnal, selectedDate: selectedDate) { queryResult in
            
            switch queryResult {
            case .success(let data):
                let documents = data.documents
                //guard let documents = data?.documents else {return}
                records = documents.compactMap { queryDocumentSnapshot -> NikoRecord? in
                    return try? queryDocumentSnapshot.data(as: NikoRecord.self)}
                if monthVsYear {
                    if ishikawa {
                        
                    }
                    self.calcTCDMonth(records: records, selectedDate: selectedDate)
                    callback(.success(self.dataTCDMonth))
                    return
                } else {
                    self.calcTCDYear(records: records, selectedDate: selectedDate)
                    callback(.success(self.dataTCDYear))
                    return
                }
            case .failure(let err):
                callback(.failure(err))
            }
//                for i in 0...30 {
//                    let rank = self.dataTCD[i].rankAverage
//                    print("Boucle before return to view      rank = \(rank)")
//                }
        }
    }
    
    /// - Parameters:
    ///   - uid: user ID
    ///   - selectedDate: date selected by the user in the view controller
    ///   - location: Array with the location selected by the user (Plant, Workshop, shift)
    ///   - personnal: Indicate that the user only want to see his data
    ///   - monthVsYear: Indicate weither month or year data retrieve (true for month, false for year)
    ///   - category5MSelected: Give the category selected in the Ishikawa bar chart
    func requestRecordUserRetrieveIshikawaData (uid: String,
                                              selectedDate: Date,
                                              location : [String],
                                              personnal : Bool,
                                              monthVsYear: Bool,
                                              category5MSelected: Int,
                                              callback: @escaping (Result<[Dictionary<String, Int>.Element], FirebaseError>) -> Void) {
        var records = [NikoRecord]()
 
        database.getQuery(uid: uid, location: location, monthVsYear: monthVsYear, personnal: personnal, selectedDate: selectedDate) { queryResult in
            
            switch queryResult {
            case .success(let data):
                let documents = data.documents
                //guard let documents = data?.documents else {return}
                records = documents.compactMap { queryDocumentSnapshot -> NikoRecord? in
                    return try? queryDocumentSnapshot.data(as: NikoRecord.self)}
                if monthVsYear {
                    self.calcTCDMonthIshikawa(records: records, category5MSelected: category5MSelected)
                    print(self.dataCause5M)
                    callback(.success(self.dataCause5M))
                    return
                }
            case .failure(let err):
                callback(.failure(err))
            }
        }
    }
    
    
    private func calcTCDMonth(records: [NikoRecord], selectedDate: Date) {
        
        let calendarHelper = CalendarHelper()
        let calendar = Calendar.current
        let daysInMonth = calendarHelper.daysInMonth(date: selectedDate)
        let firstDayOfMonth = calendarHelper.firstOfMonth(date: selectedDate)
        print("NB records dans calcMonth : \(records.count)")
        (0...daysInMonth - 1).forEach { n in
            let date = calendar.date(byAdding: .day, value: n, to: firstDayOfMonth)!
            let dateString = calendarHelper.dateString(date: date)
            
            let recordsDate = records.filter ({$0.formattedDateString == dateString})
            currentNikoTCD.nbRecord = recordsDate.count
            let recordsRank = recordsDate.map({return $0.nikoRank})
            let ranksCount = recordsRank.count
            if ranksCount > 0 {
                let ranksSum = recordsRank.reduce(0, +)
                currentNikoTCD.rankAverage = ranksSum / ranksCount
            }
            let recordsSuper = recordsDate.filter({$0.nikoStatus == "Super"})
            currentNikoTCD.nbSuper = recordsSuper.count
            let recordsNTR = recordsDate.filter({$0.nikoStatus == "NTR"})
            currentNikoTCD.nbNTR = recordsNTR.count
            let recordsTought = recordsDate.filter({$0.nikoStatus == "Tought"})
            currentNikoTCD.nbTought = recordsTought.count
            let recordsMethode = recordsDate.filter({$0.niko5M == "methode"})
            currentNikoTCD.nbMethod = recordsMethode.count
            let recordsMatiere = recordsDate.filter({$0.niko5M == "matiere"})
            currentNikoTCD.nbMatiere = recordsMatiere.count
            let recordsMachine = recordsDate.filter({$0.niko5M == "machine"})
            currentNikoTCD.nbMachine = recordsMachine.count
            let recordsMaindoeuvre = recordsDate.filter({$0.niko5M == "maindoeuvre"})
            currentNikoTCD.nbMaindoeuvre = recordsMaindoeuvre.count
            let recordsMilieu = recordsDate.filter({$0.niko5M == "milieu"})
            currentNikoTCD.nbMilieu = recordsMilieu.count
        
            print(" \(dateString) \(n)  nbRecord = \(currentNikoTCD.nbRecord) Method = \(currentNikoTCD.nbMethod) nbMatiere = \(currentNikoTCD.nbMatiere)  nbMachine = \(currentNikoTCD.nbMachine)  nbMO : \(currentNikoTCD.nbMaindoeuvre)")
            
            dataTCDMonth[n] = currentNikoTCD
            razCurrentTCD()
            
        }
    }
 
    private func calcTCDMonthIshikawa(records: [NikoRecord], category5MSelected: Int) {
        // Group the table by niko5M record and count the number of record
        let selected5M = category5M[category5MSelected]
        let array5MSelected = records.filter ({ $0.niko5M == selected5M})
        let grouped = Dictionary(grouping: array5MSelected, by: { $0.nikoCause }).mapValues ({ items in items.count })
        dataCause5M = grouped.sorted { $0.1 > $1.1 }
    }
    
    private func calcTCDYear(records: [NikoRecord], selectedDate: Date) {
        
        let calendarHelper = CalendarHelper()
        let calendar = Calendar.current
        let nbMonth = 12
        let firstDayOfYear = calendarHelper.firstOfYear(date: selectedDate)
              
        (0...nbMonth - 1).forEach { n in
            let date = calendar.date(byAdding: .month, value: n, to: firstDayOfYear)!
            let monthString = calendarHelper.monthString(date: date)
            
            let recordsDate = records.filter ({$0.formattedMonthString == monthString})
            currentNikoTCD.nbRecord = recordsDate.count
            let recordsRank = recordsDate.map({return $0.nikoRank})
            let ranksCount = recordsRank.count
            if ranksCount > 0 {
                let ranksSum = recordsRank.reduce(0, +)
                currentNikoTCD.rankAverage = ranksSum / ranksCount
            }
            let recordsSuper = recordsDate.filter({$0.nikoStatus == "Super"})
            currentNikoTCD.nbSuper = recordsSuper.count
            let recordsNTR = recordsDate.filter({$0.nikoStatus == "NTR"})
            currentNikoTCD.nbNTR = recordsNTR.count
            let recordsTought = recordsDate.filter({$0.nikoStatus == "Tought"})
            currentNikoTCD.nbTought = recordsTought.count
            let recordsMethode = recordsDate.filter({$0.nikoCause == "Methode"})
            currentNikoTCD.nbMethod = recordsMethode.count
            let recordsMatiere = recordsDate.filter({$0.nikoCause == "Matiere"})
            currentNikoTCD.nbMatiere = recordsMatiere.count
            let recordsMachine = recordsDate.filter({$0.nikoCause == "Machine"})
            currentNikoTCD.nbMachine = recordsMachine.count
            let recordsMaindoeuvre = recordsDate.filter({$0.nikoCause == "Maindoeuvre"})
            currentNikoTCD.nbMaindoeuvre = recordsMaindoeuvre.count
            let recordsMilieu = recordsDate.filter({$0.nikoCause == "Milieu"})
            currentNikoTCD.nbMilieu = recordsMilieu.count
        
            print(" \(monthString) \(n)  nbRecord = \(currentNikoTCD.nbRecord) rank = \(currentNikoTCD.rankAverage) nbSuper = \(currentNikoTCD.nbSuper)  nbNTR = \(currentNikoTCD.nbNTR)  nbTought : \(currentNikoTCD.nbTought)")
            
            dataTCDYear[n] = currentNikoTCD
            razCurrentTCD()
        }
    }
    
    private func razCalendarNiko(listDay:[Int]) -> [Int]{
        var list = listDay
        for index in  (0..<list.count) {
            list[index] = -1
        }
        return list
    }
    
    private func razCurrentTCD() {
        
        currentNikoTCD = NikoTCD(rankAverage: -1, nbRecord: 0, nbSuper: 0, nbNTR: 0, nbTought: 0, nbMethod: 0, nbMatiere: 0, nbMachine: 0, nbMaindoeuvre: 0, nbMilieu: 0)
    }
    
    private func transfertDataUserToNikoRecord() {
        currentNiko.userID = currentUser.userID
        currentNiko.firstname = currentUser.firstname
        currentNiko.lastname =  currentUser.lastname
        currentNiko.position =  currentUser.position
        currentNiko.plant =  currentUser.plant
        currentNiko.department =  currentUser.department
        currentNiko.workshop =  currentUser.workshop
        currentNiko.shift = currentUser.shift
        currentNiko.permission = currentUser.permission
    }
    
}
