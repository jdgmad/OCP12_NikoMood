//
//  FakeResponseData.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 2/04/2022.
//

import Foundation

class FakeResponseData {
    
    // MARK: - Response
    
    static let responseOK = HTTPURLResponse(url: URL(string: "https://www.google.fr")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    static let responseKO = HTTPURLResponse(url: URL(string: "https://www.google.fr")!, statusCode: 500, httpVersion: nil, headerFields: nil)!
    
    // MARK: - Error

//    class NetworkError: Error {}
//    static let networkError = NetworkError()
    
    // MARK: - Data
    
    static var correctData: Data {
        let bundle = Bundle(for: FakeResponseData.self)
        guard let url = bundle.url(forResource: "Recipes", withExtension: "json") else {
            fatalError("Recipes.json is not found.")
        }
        guard let data = try? Data(contentsOf: url) else { return Data() }
        return data
    }
    
    static var noRecipeData: Data {
        let bundle = Bundle(for: FakeResponseData.self)
        guard let url = bundle.url(forResource: "ZeroRecipe", withExtension: "json") else {
            fatalError("ZeroRecipe.json is not found.")
        }
        guard let data = try? Data(contentsOf: url) else { return Data() }
        return data
    }
    
    static var fourRecipe: Data {
        let bundle = Bundle(for: FakeResponseData.self)
        guard let url = bundle.url(forResource: "FourRecipes", withExtension: "json") else {
            fatalError("FourRecipes.json is not found.")
        }
        guard let data = try? Data(contentsOf: url) else { return Data() }
        return data
    }
    
    
    static let incorrectData = "erreur".data(using: .utf8)!
}
