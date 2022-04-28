//
//  5MCauseTableViewController.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 27/03/2022.
//

import UIKit

class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    //let nikoFirestoreManager =  NikoFirestoreManager.shared
    var tableView = UITableView()
    var cellTitles = [ ""]
    var currentNiko = NikoRecord(userID: "", firstname: "", lastname: "", position: "", plant: "", department: "", workshop: "", shift: "", nikoStatus: "", nikoRank: 0, niko5M: "", nikoCause: "", nikoComment: "", permission: 0, date: Date(), formattedMonthString: "", formattedDateString : "", formattedYearString: "", error: "")
    public var completion: ((NikoRecord) -> Void)?

    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setTableView()
        switch currentNiko.niko5M {
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

    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CauseTableCell.self, forCellReuseIdentifier: "causeTableCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 35
        view.addSubview(tableView)
        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: g.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: g.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: g.topAnchor, constant: 20),
            tableView.heightAnchor.constraint(equalTo: g.heightAnchor, multiplier: 0.6)
        ])
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
        currentNiko.nikoCause = cellTitles[indexPath.row]
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        cell.accessoryType = .checkmark
        completion?(currentNiko)
        navigationController?.popViewController(animated: true)
//        dismiss(animated: true, completion: nil)
    }
}


class CauseTableCell: UITableViewCell {
    var cellLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "causeTableCell")
        cellLabel.translatesAutoresizingMaskIntoConstraints = false
        cellLabel.font = UIFont.systemFont(ofSize: 16)
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
