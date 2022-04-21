//
//  UITableViewCell.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 31/03/2022.
//

import UIKit

extension UITableViewCell {
    func addCustomDisclosureIndicator(with color: UIColor) {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 15))
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular, scale: .large)
        let symbolImage = UIImage(systemName: "chevron.right",
                                  withConfiguration: symbolConfig)
        button.setImage(symbolImage?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal), for: .normal)
        button.tintColor = color

        self.contentView.addSubview(button)
        
    }
    
    func addCustomLabel(with color: UIColor) {
        let lbl = UILabel()
        lbl.backgroundColor = .yellow
            lbl.textColor = color
            lbl.font = UIFont.systemFont(ofSize: 14)
            lbl.textAlignment = .left
            lbl.text = "Détail"
            //lbl.numberOfLines = 0
        //self.accessoryView = button
        self.contentView.addSubview(lbl)
    }
}
// to use it
// cell.addCustomDisclosureIndicator(with: .white) // Here your own color

//contentView.addSubview(productImage)
