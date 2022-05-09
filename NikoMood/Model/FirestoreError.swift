//
//  FirestoreError.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 30/03/2022.
//

import Foundation


enum FirebaseError: Error {
    case errSignin, errSignup, errSignout, noUserConnected, noDocUser, errGettingDoc, errWritingData
}

extension FirebaseError: CustomStringConvertible {
    var description: String {
        switch self {
        case .errSignin: return "Error Signin".localized()
        case .errSignup: return "Error Signup".localized()
        case .errSignout: return "Error Signout".localized()
        case .noUserConnected: return "No user connected".localized()
        case .noDocUser: return "No user document".localized()
        case .errGettingDoc: return "Error access to document".localized()
        case .errWritingData: return "Error writing data".localized()
        }
    }
}
