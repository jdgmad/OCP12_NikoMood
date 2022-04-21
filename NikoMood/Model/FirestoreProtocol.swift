//
//  FirestoreProtocol.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 30/03/2022.
//

import Foundation

protocol FirestoreProtocol {

    func firestoresSignIn (withEmail: String, password: String, completionHandler: @escaping (Result<Any, Error>) -> Void)
            
        
}



