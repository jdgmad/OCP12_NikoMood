//
//  5MCauseTableViewController.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 27/03/2022.
//

import UIKit

class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    let nikoFirestoreManager =  NikoFirestoreManager.shared
    var tableView = UITableView()
    var cellTitles = [ ""]

    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CauseTableCell.self, forCellReuseIdentifier: "causeTableCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 48

        view.addSubview(tableView)
        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: g.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: g.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: g.topAnchor, constant: 20),
            tableView.heightAnchor.constraint(equalTo: g.heightAnchor, multiplier: 0.6)
        ])
        
        switch nikoFirestoreManager.currentNiko.niko5M {
                    case "methode":
                        cellTitles = causeMethode
                    case "matiere":
                        cellTitles = causeMatiere
                    case "machine":
                        cellTitles = causeMachine
                    case "maindoeuvre":
                        cellTitles = causeMaindoeuvre
                    case "milieu":
                        cellTitles = causeMilieu
                    default:
                        cellTitles = [""]
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "causeTableCell", for: indexPath) as? CauseTableCell else {
            fatalError("Unable to dequeue causeTableCell")
        }

        let title = cellTitles[indexPath.row]
        cell.cellLabel.text = title

        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 8)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? CauseTableCell else {return}
        nikoFirestoreManager.currentNiko.nikoCause = cellTitles[indexPath.row]
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        cell.accessoryType = .checkmark
    }
}


class CauseTableCell: UITableViewCell {
    var cellLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "causeTableCell")

        cellLabel.translatesAutoresizingMaskIntoConstraints = false
        cellLabel.font = UIFont.systemFont(ofSize: 20)
        contentView.addSubview(cellLabel)

        NSLayoutConstraint.activate([
            cellLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cellLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
    }
    required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
    }
}
