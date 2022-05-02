//
//  DatabaseManagerTests.swift
//  NikoMoodTests
//
//  Created by José DEGUIGNE on 01/05/2022.
//

import XCTest
@testable import NikoMood

class DatabaseManagerTests: XCTestCase {

    // MARK: - Helpers

    private class DatabaseStub: DatabaseType {

        private let isSuccess: Bool?
        private let firebaseError: FirebaseError?
        private let nikoResultUser: NikoUser?
        private let nikoResultRecord: [NikoRecord]?
        
        
        init(_ isSuccess: Bool?, _ nikoResultUser: NikoUser?, _ nikoResultRecord: [NikoRecord]?, _ firebaseError: FirebaseError?) {
        
            self.nikoResultUser = nikoResultUser
            self.nikoResultRecord = nikoResultRecord
            self.isSuccess = isSuccess
            self.firebaseError = firebaseError
            
        }
    
        // MARK: - Read Queries

        func getUserData(with uid: String, callback: @escaping (Result<NikoUser, FirebaseError>) -> Void) {
            let ret: Result<NikoUser, FirebaseError>
            if nikoResultUser != nil {
                ret = .success(nikoResultUser!)
            } else {
                ret = .failure(.errGettingDoc)
            }
            callback(ret)
        }
        
        func checkIfRecordExist (uid: String, dateString: String, callback: @escaping (Bool) -> Void) {
            callback(isSuccess!)
        }
        
        func getQuery(uid: String, location: [String], monthVsYear: Bool, personnal: Bool, selectedDate: Date, callback: @escaping (Result<[NikoRecord], FirebaseError>) -> Void) {
            
            callback(.success(nikoResultRecord!))
        }
        
        func addRecord(docData : [String: Any], callback: @escaping (Bool) -> Void) {
            callback(isSuccess!)
        }
    }

//        func getQuery(uid: String, location: [String], monthVsYear: Bool, personnal: Bool, selectedDate: Date, callback: @escaping (Result<[NikoRecord], FirebaseError>) -> Void) {
//
//    print("\n\n")
//    print("uid: \(uid)")
//    print("location: \(location)")
//    print("monthVsYear: \(monthVsYear)")
//    print("personnal: \(personnal)")
//    print("date: \(selectedDate)")
//
//        var q: Query?
//        var records = [NikoRecord]()
//        let calendarHelper = CalendarHelper()
//        let month = calendarHelper.monthString(date: selectedDate)
//        let year = calendarHelper.yearString(date: selectedDate)
//        let db = Firestore.firestore()
//        let usersRef = db.collection("NikoRecord")
//        if monthVsYear {
//            q = usersRef.whereField("formattedMonthString", isEqualTo: month)
//        } else {
//            q = usersRef.whereField("formattedYearString", isEqualTo: year)
//        }
//        if personnal {
//            q = q?.whereField("userID", isEqualTo: uid)
//        } else {
//            for (index, val) in location.enumerated() {
//                if location[index] != "" {
//                    //q = q?.whereField(paramQueryField[index], isEqualTo: val)
//                    print("location name : \(LocationEntreprise.locations[index].locationName!) val: \(val)")
//                    q = q?.whereField(LocationEntreprise.locations[index].locationName!, isEqualTo: val)
//                }
//            }
//        }
//        q?.getDocuments{ (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//                callback(.failure(.errGettingDoc))
//                return
//            }
//            records = querySnapshot!.documents.compactMap { queryDocumentSnapshot -> NikoRecord? in
//                return try? queryDocumentSnapshot.data(as: NikoRecord.self)}
//            callback(.success(records))
//        //callback(.success(querySnapshot!))
//        }
//    }
//    }
//
//    enum TestError: Error {
//        case invalidUID
//    }

    
        
    // MARK: - Tests

    func testGetUserDataMethod_WhenTheUIDIsCorrect_ThenShouldReturnUserData() {
        
        let currentUser = NikoUser(id: "", userID: "NyeVduglGkQAgldAgG5durdJAer2", firstname: "Jose", lastname: "DE GUIGNE", position: "", plant: "", department: "", workshop: "", shift: "",  permission: 0, password: "", birthday: Date(), email: "")
        let sut: DatabaseManager = DatabaseManager(database: DatabaseStub(nil, currentUser, nil, nil))
        let uid: String = "NyeVduglGkQAgldAgG5durdJAer2"
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        sut.getUserData(with: uid) { result in
            guard case .success(let userData) = result else {
                XCTFail("Get User Data Method Success Tests Fails")
                return
            }
            XCTAssertTrue(userData.userID == "NyeVduglGkQAgldAgG5durdJAer2")
            XCTAssertTrue(userData.firstname == "Jose")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.01)
    }

    func testGetUserDataMethod_WhenTheUIDIsIncorrect_ThenShouldReturnAnError() {
        let sut: DatabaseManager = DatabaseManager(database: DatabaseStub(nil, nil, nil, FirebaseError.errGettingDoc))
        let uid: String = "invalidUid"
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        sut.getUserData(with: uid) { result in
            guard case .failure(let error) = result else {
                XCTFail("Get User Data Method Success Tests Fails")
                return
            }
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }
    
    func testAddRecordMethod_WhenWriteCorrectRecord_ThenShouldReturnisSuccess() {
        let currentNiko = NikoRecord(userID: "", firstname: "", lastname: "", position: "", plant: "", department: "", workshop: "", shift: "", nikoStatus: "", nikoRank: 0, niko5M: "", nikoCause: "", nikoComment: "", permission: 0, date: Date(), formattedMonthString: "", formattedDateString : "", formattedYearString: "", error: "")
        let sut: DatabaseManager = DatabaseManager(database: DatabaseStub(true, nil, nil, nil))
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        sut.storeNikoRecord(record: currentNiko) { isSuccess in
            XCTAssertTrue(isSuccess == true)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }
    
    func testAddRecordMethod_WhenErrrorWritingRecord_ThenShouldReturnfailure() {
        let currentNiko = NikoRecord(userID: "", firstname: "", lastname: "", position: "", plant: "", department: "", workshop: "", shift: "", nikoStatus: "", nikoRank: 0, niko5M: "", nikoCause: "", nikoComment: "", permission: 0, date: Date(), formattedMonthString: "", formattedDateString : "", formattedYearString: "", error: "")
        let sut: DatabaseManager = DatabaseManager(database: DatabaseStub(false, nil, nil, nil))
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        sut.storeNikoRecord(record: currentNiko) { isSuccess in
            XCTAssertTrue(isSuccess == false)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }

    func testCheckIfRecordExistMethod_WhenRecordExist_ThenShouldReturnisTrue() {
        let uid: String = "NyeVduglGkQAgldAgG5durdJAer2"
        let sut: DatabaseManager = DatabaseManager(database: DatabaseStub(true, nil, nil, nil))
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        sut.checkIfRecordExist(uid: uid, dateSelected: Date()) { isSuccess in
            XCTAssertTrue(isSuccess == true)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }
    
    func testCheckIfRecordExistMethod_WhenRecordDoNotExist_ThenShouldReturnisFalse() {
        let uid: String = "NyeVduglGkQAgldAgG5durdJAer2"
        let sut: DatabaseManager = DatabaseManager(database: DatabaseStub(false, nil, nil, nil))
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        sut.checkIfRecordExist(uid: uid, dateSelected: Date()) { isSuccess in
            XCTAssertTrue(isSuccess == false)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }
    
    func testGetQueryMethod_WhenWriteCorrectRecord_ThenShouldReturnisSuccess() {
        let locationSelected = ["Salin", "Production", "B"]
        let uid: String = "NyeVduglGkQAgldAgG5durdJAer2"
        let nikoRecords = [NikoRecord(userID: "6zxxcvxJXcOqFxuBOfDcj74S6Yf2", firstname: "Serge", lastname: "Marinier", position: "Chef de poste", plant: "Salin", department: "Production", workshop: "Production", shift: "B", nikoStatus: "", nikoRank: 0, niko5M: "", nikoCause: "", nikoComment: "", permission: 2, date: 2022-04-01 21:32:16 +0000, formattedMonthString: "avril", formattedDateString: "01/04/2022", formattedYearString: "2022", error: ""), NikoRecord(userID: "6zxxcvxJXcOqFxuBOfDcj74S6Yf2", firstname: "Serge", lastname: "Marinier", position: "Chef de poste", plant: "Salin", department: "Production", workshop: "Production", shift: "B", nikoStatus: "Tought", nikoRank: 0, niko5M: "methode", nikoCause: "Pas de Modes opératoires", nikoComment: "", permission: 2, date: 2022-04-02 13:56:00 +0000, formattedMonthString: "avril", formattedDateString: "02/04/2022", formattedYearString: "2022", error: ""), NikoRecord(userID: "6zxxcvxJXcOqFxuBOfDcj74S6Yf2", firstname: "Serge", lastname: "Marinier", position: "Chef de poste", plant: "Salin", department: "Production", workshop: "Production", shift: "B", nikoStatus: "NTR", nikoRank: 5, niko5M: "", nikoCause: "", nikoComment: "", permission: 2, date: 2022-04-03 13:00:00 +0000, formattedMonthString: "avril", formattedDateString: "03/04/2022", formattedYearString: "2022", error: "")]
        
        let sut: DatabaseManager = DatabaseManager(database: DatabaseStub(false, nil, nikoRecords, nil))
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        sut.requestRecordUserRetrievelocalisationData(uid: uid, selectedDate: 2022-04-02 13:56:00, location: locationSelected, personnal: true, monthVsYear: true, ishikawa: false ) { result in
            XCTAssertTrue(result == true)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }
}
