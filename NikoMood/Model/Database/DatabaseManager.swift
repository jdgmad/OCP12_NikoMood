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
                            self.currentUser = data
                            self.transfertDataUserToNikoRecord()
                            callback(.success(self.currentNiko))
                            return
            
            case .failure(let err):
                callback(.failure(err))
            }
        }
    }
    
    /// Store the record and return a status BOOL type within a closure.
    /// - Parameters:
    ///   - record: records to save
    func storeNikoRecord (record : NikoRecord, callback: @escaping (Bool) -> Void) {
        // MARK: - Properties
        let currentNiko = record
        let calendarHelper = CalendarHelper()
        let date = currentNiko.date
        let error = (currentNiko.error ?? "")
        let docData: [String: Any] = ([
            "userID": record.userID,
            "firstname": record.firstname,
            "lastname": record.lastname,
            "position": record.position,
            "plant": record.plant,
            "department": record.department,
            "workshop": record.workshop,
            "shift": record.shift,
            "nikoStatus": record.nikoStatus,
            "nikoRank": record.nikoRank,
            "niko5M": record.niko5M,
            "nikoCause": record.nikoCause,
            "nikoComment": record.nikoComment,
            "permission": record.permission,
            "date": record.date,
            "formattedMonthString": calendarHelper.month2Digits(date: date),
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

    /// Retrieve the user or location data, calculate sums by items and return a NikoTCD type within a closure.
    /// - Parameters:
    ///   - uid: user ID
    ///   - selectedDate: date selected by the user in the view controller
    ///   - location: Array with the location selected by the user (Plant, Workshop, shift)
    ///   - personnal: Indicate that the user only want to see his data
    ///   - monthVsYear: Indicate weither month or year data retrieve (true for month, false for year)
    func requestRecordUserRetrievelocalisationData (uid: String,
                                                  selectedDate: Date,
                                                  location : [String],
                                                  personnal : Bool,
                                                  monthVsYear: Bool,
                                                  callback: @escaping (Result<[NikoTCD], FirebaseError>) -> Void) {

        dataTCDMonth = Array(repeating: currentNikoTCD, count: 31)
        dataTCDYear = Array(repeating: currentNikoTCD, count: 12)

        database.getQuery(uid: uid, location: location, monthVsYear: monthVsYear, personnal: personnal, selectedDate: selectedDate) { records in
            
            switch records {
            case .success(let records):
                if monthVsYear {
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
        }
    }
    
    /// Retrieve the user or location data, calculate sums by items and return a NikoTCD type within a closure.
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
 
        database.getQuery(uid: uid, location: location, monthVsYear: monthVsYear, personnal: personnal, selectedDate: selectedDate) { records in
            switch records {
            case .success(let records):
                if monthVsYear {
                    self.calcTCDMonthIshikawa(records: records, category5MSelected: category5MSelected)
                    callback(.success(self.dataCause5M))
                    return
                }
            case .failure(let err):
                callback(.failure(err))
            }
        }
    }
    
    /// Calculate the month sums of nikoStatus and niko5M and store the result in dataTCDMonth.
    /// - Parameters:
    ///   - records: records returns from the query
    private func calcTCDMonth(records: [NikoRecord], selectedDate: Date) {
        let calendarHelper = CalendarHelper()
        let calendar = Calendar.current
        let daysInMonth = calendarHelper.daysInMonth(date: selectedDate)
        let firstDayOfMonth = calendarHelper.firstOfMonth(date: selectedDate)
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
            
            dataTCDMonth[n] = currentNikoTCD
            razCurrentTCD()
        }
    }
 
    /// Group the month records  by nikoCause and store the result in dataCause5M.
    /// - Parameters:
    ///   - records: records returns from the query
    private func calcTCDMonthIshikawa(records: [NikoRecord], category5MSelected: Int) {
        // Group the table by niko5M record and count the number of record
        let selected5M = category5M[category5MSelected]
        let array5MSelected = records.filter ({ $0.niko5M == selected5M})
        let grouped = Dictionary(grouping: array5MSelected, by: { $0.nikoCause }).mapValues ({ items in items.count })
        dataCause5M = grouped.sorted { $0.1 > $1.1 }
    }
    
    /// Calculate the year sums of nikoStatus and niko5M and store the result in dataTCDYear.
    /// - Parameters:
    ///   - records: records returns from the query
    private func calcTCDYear(records: [NikoRecord], selectedDate: Date) {
        let calendarHelper = CalendarHelper()
        let calendar = Calendar.current
        let nbMonth = 12
        let firstDayOfYear = calendarHelper.firstOfYear(date: selectedDate)
              
        (0...nbMonth - 1).forEach { n in
            let date = calendar.date(byAdding: .month, value: n, to: firstDayOfYear)!
            let month2D = calendarHelper.month2Digits(date: date)
            
            let recordsDate = records.filter ({$0.formattedMonthString == month2D})
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
            let recordsMethode = recordsDate.filter({$0.nikoCause == "methode"})
            currentNikoTCD.nbMethod = recordsMethode.count
            let recordsMatiere = recordsDate.filter({$0.nikoCause == "matiere"})
            currentNikoTCD.nbMatiere = recordsMatiere.count
            let recordsMachine = recordsDate.filter({$0.nikoCause == "machine"})
            currentNikoTCD.nbMachine = recordsMachine.count
            let recordsMaindoeuvre = recordsDate.filter({$0.nikoCause == "maindoeuvre"})
            currentNikoTCD.nbMaindoeuvre = recordsMaindoeuvre.count
            let recordsMilieu = recordsDate.filter({$0.nikoCause == "milieu"})
            currentNikoTCD.nbMilieu = recordsMilieu.count
     
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
