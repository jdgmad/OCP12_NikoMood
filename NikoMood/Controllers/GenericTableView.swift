//
//  GenericTableView.swift
//  AwesonTable
//
//  Created by José DEGUIGNE on 09/05/2022.
//
//

import UIKit

class GenericTableView : UITableView, UITableViewDelegate, UITableViewDataSource {
   
    // MARK: - Properties
    
    var items: [String]
    var itemsSelected : [String]
    var permission : Int
    var config: (String, String, LocationTableCell) -> ()
    var selectHandler: (Int) -> ()
    
    // MARK: - Init
    
    init(frame: CGRect, items: [String], itemsSelected: [String], permission: Int, config: @escaping (String, String, LocationTableCell) -> (), selectHandler: @escaping (Int) -> ()) {
        self.items = items
        self.itemsSelected = itemsSelected
        self.permission = permission
        self.config = config
        self.selectHandler = selectHandler
        super.init(frame: frame, style: .plain)
        
        self.delegate = self
        self.dataSource = self
        self.register(LocationTableCell.self, forCellReuseIdentifier: "locationTableCell")
        self.translatesAutoresizingMaskIntoConstraints = false
        self.rowHeight = 35
        self.backgroundColor = .none
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.dequeueReusableCell(withIdentifier: "locationTableCell", for: indexPath) as? LocationTableCell else { fatalError("Unable to dequeue locationTableCell") }
        handlePermission(cell: cell, button: cell.button, index: indexPath.row)
        cell.button.tag = indexPath.row
        cell.button.addTarget(self, action: #selector(didChangeButton(_:)), for: .touchUpInside)
        config(items[indexPath.row], itemsSelected[indexPath.row], cell)
        
        return cell
    }

    // Hide the right button depending the permission level of the user connected
    private func handlePermission(cell: UITableViewCell, button: UIButton, index : Int) {
        switch index {
        case 0:
        if permission >= 4  {
            cell.isUserInteractionEnabled = true
            button.isHidden = false
        } else {
            cell.isUserInteractionEnabled = false
            button.isHidden = true
        }
        case 1:
        if permission >= 3   {
            cell.isUserInteractionEnabled = true
            button.isHidden = false
        } else {
            cell.isUserInteractionEnabled = false
            button.isHidden = false
            button.isHidden = true
        }
        case 2:
        if permission >= 2   {
            cell.isUserInteractionEnabled = true
            button.isHidden = false
        } else {
            cell.isUserInteractionEnabled = false
            button.isHidden = true
        }
        default:
            return
        }
    }
  
    // Return the button number when one right button is press up
    @objc func didChangeButton(_ sender: UIButton) {
        if sender.isTouchInside {
            let buttonNumber = sender.tag
            selectHandler(buttonNumber)
        }
    }
    
}

extension GenericTableView {
    func reload(items: [String], itemsSelected: [String]) {
        self.items = items
        self.itemsSelected = itemsSelected
        self.reloadData()
    }
}
