//
//  String.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 06/05/2022.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(
            self,
            tableName: "Localizable",
            bundle: .main,
            value: self,
            comment: self)
    }
}
