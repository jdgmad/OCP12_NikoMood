//
//  LocationTableCell.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 03/04/2022.
//

import UIKit

class LocationTableCell: UITableViewCell {
    
    var cellLabelEtablissement = UILabel()
    var cellLabelEtablissementSelected = UILabel()
    var button = UIButton(frame: CGRect(x: 0, y: 0, width: 15, height: 20))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "locationTableCell")

        cellLabelEtablissement.translatesAutoresizingMaskIntoConstraints = false
        cellLabelEtablissement.font = UIFont.systemFont(ofSize: 16)
        contentView.addSubview(cellLabelEtablissement)
        
        cellLabelEtablissementSelected.translatesAutoresizingMaskIntoConstraints = false
        cellLabelEtablissementSelected.textColor = .darkGray
        cellLabelEtablissementSelected.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(cellLabelEtablissementSelected)
        

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)
        let symbolImage = UIImage(systemName: "chevron.right",
                                  withConfiguration: symbolConfig)
        button.setImage(symbolImage?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal), for: .normal)
        button.tintColor = .systemBlue
        accessoryView = button
        
        NSLayoutConstraint.activate([
            cellLabelEtablissement.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cellLabelEtablissement.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cellLabelEtablissementSelected.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cellLabelEtablissementSelected.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -140),
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
