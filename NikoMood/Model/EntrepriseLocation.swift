//
//  EntrepriseLocation.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 01/04/2022.
//

import Foundation


struct Location {
    var locationName:String?
    var locationSelected:String?
}

class LocationEntreprise {
    static var locations = [
            Location(locationName: "plant", locationSelected: " "),
            Location(locationName: "workshop", locationSelected: " "),
            Location(locationName: "shift", locationSelected: " ")
        ]
    
    // Modifications à venir :
    // Récupérer depuis Firebase les valeurs pour remplir locations

}

