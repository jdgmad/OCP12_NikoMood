//
//  EntrepriseLocation.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 01/04/2022.
//

import Foundation


struct Location {
    let locationName:String?
    let locationSelected:String?
}

class LocationEntreprise {
    static func getLocations() -> [Location]{
        let locations = [
            Location(locationName: "Etablissement", locationSelected: " "),
            Location(locationName: "Département", locationSelected: " "),
            Location(locationName: "Service", locationSelected: " "),
            Location(locationName: "Equipe", locationSelected: " ")
        ]
        return locations
    }
}
