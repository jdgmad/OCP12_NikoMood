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
            let ret: Result<[NikoRecord], FirebaseError>
            if nikoResultRecord != nil {
                ret = .success(nikoResultRecord!)
            } else {
                ret = .failure(.errGettingDoc)
            }
            callback(ret)
            
        }
        
        func addRecord(docData : [String: Any], callback: @escaping (Bool) -> Void) {
            callback(isSuccess!)
        }
    }


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
    
    func testGetQueryMethodMonth_WhenRetrieveCorrectRecord_ThenShouldReturnisSuccess() {
        let locationSelected = ["Salin", "Production", "B"]
        let uid: String = "6zxxcvxJXcOqFxuBOfDcj74S6Yf2"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let nikoRecords = [NikoRecord(userID: "6zxxcvxJXcOqFxuBOfDcj74S6Yf2", firstname: "Serge", lastname: "Marinier", position: "Chef de poste", plant: "Salin", department: "Production", workshop: "Production", shift: "B", nikoStatus: "", nikoRank: 0, niko5M: "", nikoCause: "", nikoComment: "", permission: 2, date: dateFormatter.date(from: "2022-04-01")!, formattedMonthString: "avril", formattedDateString: "01/04/2022", formattedYearString: "2022", error: ""), NikoRecord(userID: "6zxxcvxJXcOqFxuBOfDcj74S6Yf2", firstname: "Serge", lastname: "Marinier", position: "Chef de poste", plant: "Salin", department: "Production", workshop: "Production", shift: "B", nikoStatus: "Tought", nikoRank: 0, niko5M: "methode", nikoCause: "Pas de Modes opératoires", nikoComment: "", permission: 2, date: dateFormatter.date(from: "2022-04-02")!, formattedMonthString: "avril", formattedDateString: "02/04/2022", formattedYearString: "2022", error: ""), NikoRecord(userID: "6zxxcvxJXcOqFxuBOfDcj74S6Yf2", firstname: "Serge", lastname: "Marinier", position: "Chef de poste", plant: "Salin", department: "Production", workshop: "Production", shift: "B", nikoStatus: "NTR", nikoRank: 5, niko5M: "", nikoCause: "", nikoComment: "", permission: 2, date: dateFormatter.date(from: "2022-04-03")!, formattedMonthString: "avril", formattedDateString: "03/04/2022", formattedYearString: "2022", error: "")]
        
        let sut: DatabaseManager = DatabaseManager(database: DatabaseStub(false, nil, nikoRecords, nil))
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        sut.requestRecordUserRetrievelocalisationData(uid: uid, selectedDate: dateFormatter.date(from: "2022-04-02")!, location: locationSelected, personnal: true, monthVsYear: true, ishikawa: false ) { result in
            guard case .success(let userData) = result else {
                XCTFail("Get User Data Method Success Tests Fails")
                return
            }
            XCTAssertTrue(userData.count == 31)
            XCTAssertTrue(userData[2].rankAverage == 5)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }
    
    func testGetQueryMethodYear_WhenRetrieveCorrectRecord_ThenShouldReturnisSuccess() {
        let locationSelected = ["Salin", "Production", "B"]
        let uid: String = "6zxxcvxJXcOqFxuBOfDcj74S6Yf2"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let nikoRecords = [NikoRecord(userID: "6zxxcvxJXcOqFxuBOfDcj74S6Yf2", firstname: "Serge", lastname: "Marinier", position: "Chef de poste", plant: "Salin", department: "Production", workshop: "Production", shift: "B", nikoStatus: "", nikoRank: 0, niko5M: "", nikoCause: "", nikoComment: "", permission: 2, date: dateFormatter.date(from: "2022-04-01")!, formattedMonthString: "avril", formattedDateString: "01/04/2022", formattedYearString: "2022", error: ""), NikoRecord(userID: "6zxxcvxJXcOqFxuBOfDcj74S6Yf2", firstname: "Serge", lastname: "Marinier", position: "Chef de poste", plant: "Salin", department: "Production", workshop: "Production", shift: "B", nikoStatus: "Tought", nikoRank: 0, niko5M: "methode", nikoCause: "Pas de Modes opératoires", nikoComment: "", permission: 2, date: dateFormatter.date(from: "2022-04-02")!, formattedMonthString: "avril", formattedDateString: "02/04/2022", formattedYearString: "2022", error: ""), NikoRecord(userID: "6zxxcvxJXcOqFxuBOfDcj74S6Yf2", firstname: "Serge", lastname: "Marinier", position: "Chef de poste", plant: "Salin", department: "Production", workshop: "Production", shift: "B", nikoStatus: "NTR", nikoRank: 5, niko5M: "", nikoCause: "", nikoComment: "", permission: 2, date: dateFormatter.date(from: "2022-04-03")!, formattedMonthString: "avril", formattedDateString: "03/04/2022", formattedYearString: "2022", error: "")]
        
        let sut: DatabaseManager = DatabaseManager(database: DatabaseStub(false, nil, nikoRecords, nil))
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        sut.requestRecordUserRetrievelocalisationData(uid: uid, selectedDate: dateFormatter.date(from: "2022-04-02")!, location: locationSelected, personnal: true, monthVsYear: false, ishikawa: false ) { result in
            guard case .success(let userData) = result else {
                XCTFail("Get User Data Method Success Tests Fails")
                return
            }
            XCTAssertTrue(userData.count == 12)

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }
    
    func testGetQueryMethod_WhenRetrieveNoRecord_ThenShouldReturnFailure() {
        let locationSelected = ["Salin", "Production", "B"]
        let uid: String = "6zxxcvxJXcOqFxuBOfDcj74S6Yf2"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let sut: DatabaseManager = DatabaseManager(database: DatabaseStub(false, nil, nil, FirebaseError.errGettingDoc))
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        sut.requestRecordUserRetrievelocalisationData(uid: uid, selectedDate: dateFormatter.date(from: "2022-04-02")!, location: locationSelected, personnal: true, monthVsYear: true, ishikawa: false ) { result in
            guard case .failure(let error) = result else {
                XCTFail("Get User Data Method Success Tests Fails")
                return
            }
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }
    
    func testGetQueryIshikawaMonth_WhenRetrieveCorrectRecord_ThenShouldReturnisSuccess() {
        let locationSelected = ["Salin", "Production", "B"]
        let uid: String = "6zxxcvxJXcOqFxuBOfDcj74S6Yf2"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let nikoRecords = [NikoRecord(userID: "6zxxcvxJXcOqFxuBOfDcj74S6Yf2", firstname: "Serge", lastname: "Marinier", position: "Chef de poste", plant: "Salin", department: "Production", workshop: "Production", shift: "B", nikoStatus: "", nikoRank: 0, niko5M: "", nikoCause: "", nikoComment: "", permission: 2, date: dateFormatter.date(from: "2022-04-01")!, formattedMonthString: "avril", formattedDateString: "01/04/2022", formattedYearString: "2022", error: ""), NikoRecord(userID: "6zxxcvxJXcOqFxuBOfDcj74S6Yf2", firstname: "Serge", lastname: "Marinier", position: "Chef de poste", plant: "Salin", department: "Production", workshop: "Production", shift: "B", nikoStatus: "Tought", nikoRank: 0, niko5M: "methode", nikoCause: "Pas de Modes opératoires", nikoComment: "", permission: 2, date: dateFormatter.date(from: "2022-04-02")!, formattedMonthString: "avril", formattedDateString: "02/04/2022", formattedYearString: "2022", error: ""), NikoRecord(userID: "6zxxcvxJXcOqFxuBOfDcj74S6Yf2", firstname: "Serge", lastname: "Marinier", position: "Chef de poste", plant: "Salin", department: "Production", workshop: "Production", shift: "B", nikoStatus: "NTR", nikoRank: 5, niko5M: "", nikoCause: "", nikoComment: "", permission: 2, date: dateFormatter.date(from: "2022-04-03")!, formattedMonthString: "avril", formattedDateString: "03/04/2022", formattedYearString: "2022", error: "")]
        
        let sut: DatabaseManager = DatabaseManager(database: DatabaseStub(false, nil, nikoRecords, nil))
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        sut.requestRecordUserRetrieveIshikawaData(uid: uid, selectedDate: dateFormatter.date(from: "2022-04-02")!, location: locationSelected, personnal: false, monthVsYear: true, category5MSelected: 0 ) { result in
            guard case .success(let userData) = result else {
                XCTFail("Get User Data Method Success Tests Fails")
                return
            }
            XCTAssertTrue(userData.count == 1) // only one record with cause "method"
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }
}
