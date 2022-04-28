//
//  FirebaseDatabase.swift
//  FirebaseLoginScreen
//
//  Created by Sebastien Bastide on 02/02/2020.
//  Copyright © 2020 Sebastien Bastide. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift



protocol DatabaseType {
    func getUserData(with uid: String, callback: @escaping (Result<QuerySnapshot, FirebaseError>) -> Void)
    func addRecord(docData : [String: Any], callback: @escaping (Bool) -> Void)
    func checkIfRecordExist (uid: String, dateString: String, callback: @escaping (Bool) -> Void)
    func getQuery(uid: String, location: [String], monthVsYear: Bool, personnal: Bool, selectedDate: Date, callback: @escaping (Result<QuerySnapshot, FirebaseError>) -> Void)
}

final class FirebaseDatabase: DatabaseType {

    // MARK: - Read Queries

    func getUserData(with uid: String, callback: @escaping (Result<QuerySnapshot, FirebaseError>) -> Void) {
        
        let db = Firestore.firestore()
        let usersRef = db.collection("users")
        usersRef.whereField("userID", isEqualTo: uid)
            .getDocuments{ (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    callback(.failure(.errGettingDoc))
                    return
                }
            callback(.success(querySnapshot!))
        }
    }
    
    func addRecord(docData : [String: Any], callback: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        ref = db.collection("NikoRecord").addDocument(data: docData) { err in
            if err != nil {
                //print("Error adding document: \(err)")
                callback(false)
            } else {
                print("Document added with ID: \(ref!.documentID)")
                callback(true)
            }
        }
    }
    
    func checkIfRecordExist (uid: String, dateString: String, callback: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let usersRef = db.collection("users")
        usersRef.whereField("userID", isEqualTo: uid)
            .whereField("formattedDateString", isEqualTo: dateString)
            .getDocuments{ (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    callback(false)
                    return
                } else {
                    if querySnapshot?.documents.count == 1 {
                        callback(true)

                    }
                }
            }
    }
    
    func getQuery(uid: String, location: [String], monthVsYear: Bool, personnal: Bool, selectedDate: Date, callback: @escaping (Result<QuerySnapshot, FirebaseError>) -> Void) {
        print("\n\n")
        print("uid: \(uid)")
        print("location: \(location)")
        print("monthVsYear: \(monthVsYear)")
        print("personnal: \(personnal)")
        print("date: \(selectedDate)")
        
//        //var q: Query?
//        let calendarHelper = CalendarHelper()
//        let month = calendarHelper.monthString(date: selectedDate)
//        let year = calendarHelper.yearString(date: selectedDate)
//        let db = Firestore.firestore()
//        let usersRef = db.collection("NikoRecord")
//        if monthVsYear {
//            usersRef.whereField("formattedMonthString", isEqualTo: month)
//        } else {
//            usersRef.whereField("formattedYearString", isEqualTo: year)
//        }
//        if personnal {
//            usersRef.whereField("userID", isEqualTo: uid)
//        } else {
//            for (index, val) in location.enumerated() {
//                if location[index] != "" {
//                    //q = q?.whereField(paramQueryField[index], isEqualTo: val)
//                    print("location name : \(LocationEntreprise.locations[index].locationName!) val: \(val)")
//                    usersRef.whereField(LocationEntreprise.locations[index].locationName!, isEqualTo: val)
//                }
//            }
//        }
//        usersRef.getDocuments{ (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//                callback(.failure(.errGettingDoc))
//                return
//            }
//            print ("querysnapshot getquery: \(querySnapshot?.count)")
//        callback(.success(querySnapshot!))
//        }
//    }
    
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
                //q = q?.whereField(paramQueryField[index], isEqualTo: val)
                print("location name : \(LocationEntreprise.locations[index].locationName!) val: \(val)")
                q = q?.whereField(LocationEntreprise.locations[index].locationName!, isEqualTo: val)
            }
        }
    }
    q?.getDocuments{ (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
            callback(.failure(.errGettingDoc))
            return
        }
        print ("querysnapshot getquery: \(querySnapshot?.count)")
    callback(.success(querySnapshot!))
    }
}

    
}
