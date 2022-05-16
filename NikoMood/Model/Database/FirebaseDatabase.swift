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
    func getUserData(with uid: String, callback: @escaping (Result<NikoUser, FirebaseError>) -> Void)
    func addRecord(docData : [String: Any], callback: @escaping (Bool) -> Void)
    func checkIfRecordExist (uid: String, dateString: String, callback: @escaping (Bool) -> Void)
    func getQuery(uid: String, location: [String], monthVsYear: Bool, personnal: Bool, selectedDate: Date, callback: @escaping (Result<[NikoRecord], FirebaseError>) -> Void)
}

final class FirebaseDatabase: DatabaseType {
    
    // MARK: - Methods
    
    // Retrieve the user data and decode according to NikoUser
    func getUserData(with uid: String, callback: @escaping (Result<NikoUser, FirebaseError>) -> Void) {
        let db = Firestore.firestore()
        let usersRef = db.collection("users")
        usersRef.whereField("userID", isEqualTo: uid)
            .getDocuments{ (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    callback(.failure(.errGettingDoc))
                    return
                }
                let document = querySnapshot?.documents.first
                do {
                    let decodeData = try document!.data(as: NikoUser.self)
                    callback(.success(decodeData!))
                    return
                }
                catch {
                    callback(.failure(.errGettingDoc))
                    return
                }
            }
    }
    
    /// Add a record and return a status BOOL type within a closure.
    /// - Parameters:
    ///   - docData: records to save
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
    
    /// Check if a record already exist for the user at the date and return a status BOOL type within a closure.
    /// - Parameters:
    ///   - uid: user ID
    ///   - dateString: date to check if a record exist.
    func checkIfRecordExist (uid: String, dateString: String, callback: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let usersRef = db.collection("NikoRecord")
        usersRef.whereField("userID", isEqualTo: uid)
            .whereField("formattedDateString", isEqualTo: dateString)
            .getDocuments{ (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    callback(false)
                    return
                } else {
                    if (querySnapshot?.documents.count)! >= 1 {
                        callback(true)
                    } else {
                        callback(false)
                    }
                }
            }
    }
    
    /// Format and Launch a query and decode the result as NikoRecord type  and return it within a closure.
    /// - Parameters:
    ///   - uid: user ID
    ///   - location: Array with the location selected by the user (Plant, Workshop, shift)
    ///   - personnal: Indicate that the user only want to see his data
    ///   - selectedDate: date selected by the user in the view controller
    ///   - monthVsYear: Indicate weither month or year data retrieve (true for month, false for year)
    func getQuery(uid: String, location: [String], monthVsYear: Bool, personnal: Bool, selectedDate: Date, callback: @escaping (Result<[NikoRecord], FirebaseError>) -> Void) {
        var q: Query?
        var records = [NikoRecord]()
        let calendarHelper = CalendarHelper()
        let month2D = calendarHelper.month2Digits(date: selectedDate)
        print("month 2D \(month2D)")
        let year = calendarHelper.yearString(date: selectedDate)
        let db = Firestore.firestore()
        let usersRef = db.collection("NikoRecord")
        if monthVsYear {
            q = usersRef.whereField("formattedMonthString", isEqualTo: month2D)
        } else {
            q = usersRef.whereField("formattedYearString", isEqualTo: year)
        }
        if personnal {
            q = q?.whereField("userID", isEqualTo: uid)
        } else {
            for (index, val) in location.enumerated() {
                if location[index] != "" {
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
            records = querySnapshot!.documents.compactMap { queryDocumentSnapshot -> NikoRecord? in
                return try? queryDocumentSnapshot.data(as: NikoRecord.self)}
            callback(.success(records))
        }
    }
}
