//
//  TeamLocationTableViewController.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 05/04/2022.
//

import UIKit

class TeamLocationTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    var etablissement = [
            "",
            "Saint Cloud",
            "Lacq",
            "Parnac",
            "Salin"
    ]
    
    var departement = [
            "Direction",
            "Finance",
            "Supply Chain",
            "HR",
            "Marketing",
            "R&D",
            "Production"
    ]
    
    var service = [
            "",
            "HR",
            "Finance",
            "Supply Chain",
            "HR",
            "Marketing",
            "R&D",
            "Production",
            "Qalité",
            "Maintenance",
            "Process",
            "Achats",
            "Comptabilité"
    ]
    var equipe = [
            "",
            "A",
            "B",
            "C",
            "D",
            "E"
    ]
    
    let nikoFirestoreManager =  NikoFirestoreManager.shared
    var tableView = UITableView()
    var cellTitles = [""]
    var locationRank = 0

    public var completion: ((String?) -> Void)?

    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TeamTableCell.self, forCellReuseIdentifier: "teamTableCell")
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
        print(" locationRank = \(locationRank)")
        switch locationRank {
                    case 0:
                        cellTitles = etablissement
                    case 1:
                        cellTitles = service
                    case 2:
                        cellTitles = equipe
//                    case 3:
//                        cellTitles = equipe

                    default:
//                        cellTitles = etablissement
                        cellTitles = [""]
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "teamTableCell", for: indexPath) as? TeamTableCell else {
            fatalError("Unable to dequeue teamTableCell")
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
        guard let cell = tableView.cellForRow(at: indexPath) as? TeamTableCell else {return}
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        cell.accessoryType = .checkmark
        completion?(cellTitles[indexPath.row])
        print("dismiss")
        navigationController?.popViewController(animated: true)
//        dismiss(animated: true, completion: nil)
    }
}


class TeamTableCell: UITableViewCell {
    var cellLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "teamTableCell")

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
