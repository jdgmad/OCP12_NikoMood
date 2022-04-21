//
//  CalendViewController.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 31/03/2022.
//

import UIKit
import Charts

class CalendViewController: UIViewController {

    
    // MARK: - Properties
    
    let nikoFirestoreManager =  NikoFirestoreManager.shared
    let calendarHelper = CalendarHelper()
    var uid = String()
    var locationSelected = String()
    
    //  Properties for locationTableView
    var locationTableView = UITableView()
    var cellTitles = [ "Etablissement", "Service", "Equipe"]
    var cellTitlesSelected = ["Etablissement", "Service", "Equipe"]
    var personnalCalendarSwitch = true
  
    
    //  Properties for calendar
    var selectedDate = Date()
    var totalSquares = [String]()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pieChartView: PieChartView!
    
    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        locationTableView.delegate = self
        locationTableView.dataSource = self
        setLocationTableView()
        collectionView.delegate = self
        pieChartView.isHidden = true

        
        setCellsView()
        setMonthView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        locationTableView.reloadData()
        //collectionView.reloadData()

    }
    
    // MARK: - IBActions
    
    @IBAction func previousMonth(_ sender: UIButton) {
        selectedDate = calendarHelper.minusMonth(date: selectedDate)
        setMonthView()
    }
    
    
    @IBAction func nextMonth(_ sender: UIButton) {
        selectedDate = calendarHelper.plusMonth(date: selectedDate)
        setMonthView()
    }
    
    @IBAction func personnalDataSwitch(_ sender: UISwitch) {
        if sender.isOn {
            personnalCalendarSwitch = true
            pieChartView.isHidden = true
            setMonthView()
            //locationTableView.reloadData()
        } else {
            personnalCalendarSwitch = false
            pieChartView.isHidden = false
            setMonthView()
            //locationTableView.reloadData()
        }
    }

    // MARK: - Methods
    
    // Global settings for tableview locationTableView
    private func setLocationTableView() {
        uid = nikoFirestoreManager.currentNiko.userID
        cellTitlesSelected[0] = nikoFirestoreManager.currentNiko.plant
        cellTitlesSelected[1] = nikoFirestoreManager.currentNiko.workshop
        cellTitlesSelected[2] = nikoFirestoreManager.currentNiko.shift
        locationTableView.register(LocationTableCell.self, forCellReuseIdentifier: "locationTableCell")
        locationTableView.translatesAutoresizingMaskIntoConstraints = false
        locationTableView.rowHeight = 35
        locationTableView.backgroundColor = .none
        view.addSubview(locationTableView)
        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            locationTableView.leadingAnchor.constraint(equalTo: g.leadingAnchor),
            locationTableView.trailingAnchor.constraint(equalTo: g.trailingAnchor),
            locationTableView.topAnchor.constraint(equalTo: g.topAnchor, constant: 36),
            locationTableView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setCellsView() {
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.sectionInset.left = 0
        flowLayout.sectionInset.right = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        let width = (collectionView.frame.size.width - 3 ) / 7
        let height = (collectionView.frame.size.height - 3 ) / 7
        flowLayout.itemSize = CGSize(width: width, height: height)
        collectionView!.collectionViewLayout = flowLayout
    }
    
    private func setMonthView()
    {
        totalSquares.removeAll()
        let daysInMonth = calendarHelper.daysInMonth(date: selectedDate)
        let firstDayOfMonth = calendarHelper.firstOfMonth(date: selectedDate)
        let startingSpaces = calendarHelper.weekDay(date: firstDayOfMonth)
        // write the number of the day in the calendar
        var count: Int = 1
        while(count <= 42)
        {
            if(count <= startingSpaces || count - startingSpaces > daysInMonth)
            {
                totalSquares.append("")
            }
            else
            {
                totalSquares.append(String(count - startingSpaces))
            }
            count += 1
        }
        let month = calendarHelper.monthString(date: selectedDate)
        let year = calendarHelper.yearString(date: selectedDate)
        monthLabel.text = month + " " + year
        // Update de Niko value with a request to Fierstore
        nikoFirestoreManager.requestRecordUsertrievelocalisationData(uid: uid, selectedDate: selectedDate, location: cellTitlesSelected, personnal: personnalCalendarSwitch, monthVsYear: true, ishikawa: false) { (result) in
            switch result {
            case .success(_):
                self.collectionView.reloadData()
            case .failure(let error):
                self.presentFirebaseAlert(typeError: error, message: "")
            }
        }
    }

    private func displayPieChart(index : Int) {
        if totalSquares[index] != "" {
            var nikoRanks = [Double]()
            let jour = Int(totalSquares[index])
            let nbSuper = nikoFirestoreManager.dataTCDMonth[jour! - 1].nbSuper
            let nbNTR = nikoFirestoreManager.dataTCDMonth[jour! - 1].nbNTR
            let nbTought = nikoFirestoreManager.dataTCDMonth[jour! - 1].nbTought
            let nikoStatus = ["Super", "OK", "Tought"]
            nikoRanks.append(Double(nbSuper))
            nikoRanks.append(Double(nbNTR))
            nikoRanks.append(Double(nbTought))
            setPieChart(dataPoints: nikoStatus, values: nikoRanks)
        }
    }

    private func setPieChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry1 = ChartDataEntry(x: Double(i), y: values[i], data: dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry1)
        }

        //print(dataEntries[0].data)
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "")
        let c1 = UIColor.green
        let c2 = UIColor.yellow
        let c3 = UIColor.red

        pieChartDataSet.colors = [c1, c2, c3,]
        pieChartDataSet.valueTextColor = .black

        let pieChartData = PieChartData(dataSet: pieChartDataSet)

        let pFormatter = NumberFormatter()
        //pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 0
        pFormatter.zeroSymbol = ""          // don't display label if data = 0
        //pFormatter.multiplier = 1
        //pFormatter.percentSymbol = " %"
        pieChartData.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        pieChartView.legend.enabled = false
        //pieChartView.spin(duration: 1, fromAngle: 0, toAngle: 20, easingOption: .easeOutCirc)
        pieChartView.animate(yAxisDuration: 1)
        pieChartView.centerText = "Niko Status"
        pieChartView.data = pieChartData
    }

}

//
// Extension Delegate et DataSource pour la la table locationTableView
//
extension CalendViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = locationTableView.dequeueReusableCell(withIdentifier: "locationTableCell", for: indexPath) as? LocationTableCell else { fatalError("Unable to dequeue locationTableCell") }
        handlePermission(cell: cell, button: cell.button, index: indexPath.row)
        cell.button.tag = indexPath.row
        cell.button.addTarget(self, action: #selector(didChangeButton(_:)), for: .touchUpInside)
        let title = cellTitles[indexPath.row]
        let titleSlected = cellTitlesSelected[indexPath.row]
        cell.cellLabelEtablissement.text = title
        cell.cellLabelEtablissementSelected.text = titleSlected
        return cell
    }

    private func handlePermission(cell: UITableViewCell, button: UIButton, index : Int) {
        switch index {
        case 0:
        if nikoFirestoreManager.currentNiko.permission >= 4  {
            cell.isUserInteractionEnabled = true
            button.isHidden = false
        } else {
            cell.isUserInteractionEnabled = false
            button.isHidden = true
        }
        case 1:
        if nikoFirestoreManager.currentNiko.permission >= 3   {
            cell.isUserInteractionEnabled = true
            button.isHidden = false
        } else {
            cell.isUserInteractionEnabled = false
            button.isHidden = false
            button.isHidden = true
        }
        case 2:
        if nikoFirestoreManager.currentNiko.permission >= 2   {
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
    
    func tableView(_ TableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 8)
    }
    
    @objc func didChangeButton(_ sender: UIButton) {
        
        if sender.isTouchInside {
            let buttonNumber = sender.tag
            let vc = TeamLocationTableViewController()
            vc.completion = {[weak self] text in
                self!.cellTitlesSelected[buttonNumber] = text ?? ""
                self!.setMonthView()
            }
            vc.locationRank = buttonNumber
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//
// Extension Delegate and DataSource for the calendar
//
extension CalendViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calCell", for: indexPath) as! CalendarCell
        
        cell.dayOfMonth.text = totalSquares[indexPath.item]
        cell.backgroundColor = .none
        if totalSquares[indexPath.item] != "" {
            let jour = Int(totalSquares[indexPath.item])
            let nikoRank = nikoFirestoreManager.dataTCDMonth[jour! - 1].rankAverage
            print ("jour : \(jour!)  nikoRank : \(nikoRank)")
            switch nikoRank {
            case 0, 1:
                cell.backgroundColor = .red
            case 2,3:
                cell.backgroundColor = .orange
            case 4,5,6:
                cell.backgroundColor = .yellow
            case 7,8:
                cell.backgroundColor = .cyan
            case 9,10:
                cell.backgroundColor = .green
            default:
                cell.backgroundColor = .none
            }
        
        } else {
            cell.backgroundColor = .none
        }
        cell.layer.cornerRadius = cell.bounds.size.width / 2
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !personnalCalendarSwitch {
            pieChartView.isHidden = false
            displayPieChart(index: indexPath.item)
        } else {
            pieChartView.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            //cell.contentView.backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
            cell.contentView.layer.borderWidth = 2
            cell.contentView.layer.borderColor = UIColor.blue.cgColor
        }
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            //cell.contentView.backgroundColor = nil
            cell.contentView.layer.borderWidth = 0
        }
    }
}
