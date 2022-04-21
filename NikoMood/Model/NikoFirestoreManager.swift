//
//  NikoFirebaseManager.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 29/03/2022.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

public class NikoFirestoreManager {
    
    // MARK: - Properties
    
    //private let firestoreSession: FirestoreProtocol
    
    public static let shared = NikoFirestoreManager()
    
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
    
    var dataTCDMonth = [NikoTCD]()
    var dataTCDYear = [NikoTCD]()
    var dataCause5M = [Dictionary<String, Int>.Element]()
    //var dataCause5M = [String : Int]()
    
    var currentNikoTCD = NikoTCD(rankAverage: -1, nbRecord: 0, nbSuper: 0, nbNTR: 0, nbTought: 0, nbMethod: 0, nbMatiere: 0, nbMachine: 0, nbMaindoeuvre: 0, nbMilieu: 0)
    
    var currentNiko = NikoRecord(userID: "", firstname: "", lastname: "", position: "", plant: "", department: "", workshop: "", shift: "", nikoStatus: "", nikoRank: 0, niko5M: "", nikoCause: "", nikoComment: "", permission: 0, date: Date(), formattedMonthString: "", formattedDateString : "", formattedYearString: "", error: "")

    var currentUser = NikoUser(id: "", userID: "", firstname: "", lastname: "", position: "", plant: "", department: "", workshop: "", shift: "",  permission: 0, password: "", birthday: Date(), email: "")
    
    var paramQueryField = ["plant", "workshop", "shift"  ]
    
    var category5M = ["methode", "matiere", "machine", "maindoeuvre", "milieu"]
    
    // MARK: - Init
    
//    init(firestoreSession: FirestoreProtocol = FirestoreSession()) {
//        self.firestoreSession = firestoreSession
//    }
    
    private init() {
        }

    // MARK: - Methods
    
    func loginUser(email: String, password: String, completionHandler: @escaping (Result<[NikoRecord], FirebaseError>) -> Void) {
    
    Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
        if error != nil {
            // Couldn't sign in
            completionHandler(.failure(.errSignin))
            print(" error signin : \(error!.localizedDescription)")
            self.currentNiko.error = error!.localizedDescription
            return
        }
        else {
            if Auth.auth().currentUser != nil {
                if let user = Auth.auth().currentUser {
                    let uid = user.uid
                    self.retrieveUserData(uid: uid) {(resultData) in
                        switch resultData {
                        case .success(_):
                            completionHandler(.success([self.currentNiko]))
                            
                        case .failure(let error):
                            completionHandler(.failure(error))
                        }
                    }
                }
            }else {
                    completionHandler(.failure(.noUserConnected))
                    return
            }
        }
        }
    }

    func retrieveUserData (uid: String, completionHandler: @escaping (Result<[NikoUser], FirebaseError>) -> Void) {
        // Retrieve the user data
        let db = Firestore.firestore()
        let usersRef = db.collection("users")
        usersRef.whereField("userID", isEqualTo: uid)
            .getDocuments{ (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completionHandler(.failure(.errGettingDoc))
                    return
                }
                if querySnapshot?.documents.count == 1 {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        do {
//                            let dataDescription = document.data().map(String.init(describing:))
//                            print("Document data: \(dataDescription)")
                            let decodeData = try document.data(as: NikoUser.self)
                            self.currentUser = decodeData!
                            self.transfertDataUserToNikoRecord()
                            completionHandler(.success([self.currentUser]))
                            return
                        }
                        catch {
                            print("erreur catch in func retrieveUserData")
                            completionHandler(.failure(.errGettingDoc))
                            return
                        }
                    }

                } else {
                    completionHandler(.failure(.noDocUser))
                    return
                }
            }
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

    func storeNikoRecord (record : NikoRecord) {
        
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
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        ref = db.collection("NikoRecord").addDocument(data: docData) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        
    }
        
    func requestRecordUsertrievelocalisationData (uid: String,
                                                  selectedDate: Date,
                                                  location : [String],
                                                  personnal : Bool,
                                                  monthVsYear: Bool,
                                                  ishikawa : Bool,
                                                  completionHandler: @escaping (Result<[NikoTCD], FirebaseError>) -> Void) {
        //var calendarNiko = Array(repeating: -1 , count: 42)
        var records = [NikoRecord]()

        dataTCDMonth = Array(repeating: currentNikoTCD, count: 31)
        dataTCDYear = Array(repeating: currentNikoTCD, count: 12)
        
        //calendarNiko = razCalendarNiko(listDay: calendarNiko)

        if let query = getQuery(uid: uid, location: location, monthVsYear: monthVsYear, personnal: personnal, selectedDate: selectedDate) {
            query.getDocuments {( querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completionHandler(.failure(.errGettingDoc))
                    return
                }
                guard let documents = querySnapshot?.documents else {return}
                records = documents.compactMap { queryDocumentSnapshot -> NikoRecord? in
                    return try? queryDocumentSnapshot.data(as: NikoRecord.self)}
                
                if monthVsYear {
                    if ishikawa {
                        
                    }
                    self.calcTCDMonth(records: records, selectedDate: selectedDate)
                    completionHandler(.success(self.dataTCDMonth))
                    return
                } else {
                    self.calcTCDYear(records: records, selectedDate: selectedDate)
                    completionHandler(.success(self.dataTCDYear))
                    return
                }
//                for i in 0...30 {
//                    let rank = self.dataTCD[i].rankAverage
//                    print("Boucle before return to view      rank = \(rank)")
//                }

            }

        }
    }

    /// - Parameters:
    ///   - uid: user ID
    ///   - selectedDate: date selected by the user in the view controller
    ///   - location: Array with the location selected by the user (Plant, Workshop, shift)
    ///   - personnal: Indicate that the user only want to see his data
    ///   - monthVsYear: Indicate weither month or year data retrieve (true for month, false for year)
    ///   - category5MSelected: Give the category selected in the Ishikawa bar chart
    func requestRecordUsertrieveIshikawaData (uid: String,
                                              selectedDate: Date,
                                              location : [String],
                                              personnal : Bool,
                                              monthVsYear: Bool,
                                              category5MSelected: Int,
                                              completionHandler: @escaping (Result<[Dictionary<String, Int>.Element], FirebaseError>) -> Void) {
        var records = [NikoRecord]()
 
        if let query = getQuery(uid: uid, location: location, monthVsYear: monthVsYear, personnal: personnal, selectedDate: selectedDate) {
            query.getDocuments {( querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completionHandler(.failure(.errGettingDoc))
                    return
                }
                guard let documents = querySnapshot?.documents else {return}
                records = documents.compactMap { queryDocumentSnapshot -> NikoRecord? in
                    return try? queryDocumentSnapshot.data(as: NikoRecord.self)}
                
                if monthVsYear {
                    self.calcTCDMonthIshikawa(records: records, category5MSelected: category5MSelected)
                    print(self.dataCause5M)
                    completionHandler(.success(self.dataCause5M))
                    return
                }
            }
        }
    }
    
    func getQuery(uid: String, location: [String], monthVsYear: Bool, personnal: Bool, selectedDate: Date) -> Query? {
        var q: Query?
        let calendarHelper = CalendarHelper()
        let month = calendarHelper.monthString(date: selectedDate)
        let year = calendarHelper.yearString(date: selectedDate)
        let db = Firestore.firestore()
        let usersRef = db.collection("NikoRecord")
        if monthVsYear {
            q = usersRef.whereField("formattedMonthString", isEqualTo: month)
        } else {
            q = usersRef.whereField("formattedYearString", isEqualTo: year)
        }
        if personnal {
            q = q?.whereField("userID", isEqualTo: uid)
        } else {
            for (index, val) in location.enumerated() {
                if location[index] != "" {
                    q = q?.whereField(paramQueryField[index], isEqualTo: val)
                }
            }
        }
        return q
    }
    
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
        
            print(" \(dateString) \(n)  nbRecord = \(currentNikoTCD.nbRecord) Method = \(currentNikoTCD.nbMethod) nbMatiere = \(currentNikoTCD.nbMatiere)  nbMachine = \(currentNikoTCD.nbMachine)  nbMO : \(currentNikoTCD.nbMaindoeuvre)")
            
            dataTCDMonth[n] = currentNikoTCD
            razCurrentTCD()
            
        }
    }
 
    private func calcTCDMonthIshikawa(records: [NikoRecord], category5MSelected: Int) {
        // Group the table by niko5M record and count the number of record
        let selected5M = category5M[category5MSelected]
        let array5MSelected = records.filter ({ $0.niko5M == selected5M})
print("Niko5M selected: \(selected5M)")
        
        print(" Apres filtre 5M")
        print(array5MSelected)

        //var causesLabel = [String ]()
        //var causesCount = [Double]()
        let grouped = Dictionary(grouping: array5MSelected, by: { $0.nikoCause }).mapValues ({ items in items.count })
        dataCause5M = grouped.sorted { $0.1 > $1.1 }
        //dataCause5M = grouped.sorted { $0.1 > $1.1 }
        
print("Cause 5M")
//print(dataCause5M)
//            let grouped = Dictionary(grouping: records, by: { $0.niko5M }).mapValues { items in items.count }
//            let group = grouped.values.sorted()
            

    }
    
    private func calcTCDYear(records: [NikoRecord], selectedDate: Date) {
        
        let calendarHelper = CalendarHelper()
        let calendar = Calendar.current
        let nbMonth = 12
//        let year = calendarHelper.yearString(date: selectedDate)
//        let month = calendarHelper.monthString(date: selectedDate)
//        let daysInMonth = calendarHelper.daysInMonth(date: selectedDate)
//        let firstDayOfMonth = calendarHelper.firstOfMonth(date: selectedDate)
        
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
//
//        let month = calendarHelper.monthString(date: selectedDate)
//        let year = calendarHelper.yearString(date: selectedDate)
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
    
    
}


//                    completionHandler(.success([self.currentNikoTCD]))
//                    return
//                } else {
//                    completionHandler(.failure(.noDocUser))
//                    return
//                }


