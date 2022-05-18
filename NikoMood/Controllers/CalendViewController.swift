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
    
    private let authService: AuthService = AuthService()
    private let databaseManager: DatabaseManager = DatabaseManager()
    let calendarHelper = CalendarHelper()
    var userUID = String()
    var currentNiko = NikoRecord(userID: "", firstname: "", lastname: "", position: "", plant: "", department: "", workshop: "", shift: "", nikoStatus: "", nikoRank: 0, niko5M: "", nikoCause: "", nikoComment: "", permission: 0, date: Date(), formattedMonthString: "", formattedDateString : "", formattedYearString: "", error: "")
    //  Properties for locationTableView
    var reustableTable: GenericTableView!
    var cellTitles = [ "Plant".localized(), "Workshop".localized(), "Shift".localized()]
    var cellTitlesSelected = ["", "", ""]
    var locationSelected = String()
    //  Properties for calendar
    var selectedDate = Date()
    var totalSquares = [String]()
    var personnalCalendarSwitch = true
    var dataTCDMonth = [NikoTCD]()
    var currentNikoTCD = NikoTCD(rankAverage: -1, nbRecord: 0, nbSuper: 0, nbNTR: 0, nbTought: 0, nbMethod: 0, nbMatiere: 0, nbMachine: 0, nbMaindoeuvre: 0, nbMilieu: 0)
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pieChartView: PieChartView!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        dataTCDMonth = Array(repeating: currentNikoTCD, count: 31)
        getUserData()
        collectionView.delegate = self
        pieChartView.isHidden = true
        setCellsViewCalendar()
        setMonthView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Update the calendar view
        setMonthView()
    }
    
    // MARK: - IBActions
    
    @IBAction func previousMonth(_ sender: UIButton) {
        selectedDate = calendarHelper.minusMonth(date: selectedDate)
        setMonthView()
        pieChartView.isHidden = true
    }
    
    @IBAction func nextMonth(_ sender: UIButton) {
        selectedDate = calendarHelper.plusMonth(date: selectedDate)
        setMonthView()
        pieChartView.isHidden = true    }
    
    @IBAction func personnalDataSwitch(_ sender: UISwitch) {
        if sender.isOn {
            personnalCalendarSwitch = true
            pieChartView.isHidden = true
            setMonthView()
        } else {
            personnalCalendarSwitch = false
            pieChartView.isHidden = false
            setMonthView()
        }
    }
    
    // MARK: - Methods
    
    func getUserData() {
        guard let uid = authService.currentUID else { return}
        userUID = uid
        databaseManager.getUserData(with: userUID) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.currentNiko = data
                    self.setLocationTableView()
                    self.reustableTable.reload(items: self.cellTitles, itemsSelected: self.cellTitlesSelected)
                case .failure(let error):
                    self.presentFirebaseAlert(typeError: error, message: error.description)
                }
            }
        }
    }
    
    // Global settings for tableview locationTableView
    // Create an instance of the GeneriTableview class to display the location table view
    // On touch inside the right button display the TeamLocationTableViewController to select a location
    // Retrieve the location enter and update the locationTableView
    private func setLocationTableView() {
        // Use the by default the data location of the current user
        cellTitlesSelected[0] = currentNiko.plant
        cellTitlesSelected[1] = currentNiko.workshop
        cellTitlesSelected[2] = currentNiko.shift
        
        reustableTable = GenericTableView(frame: view.frame, items: cellTitles, itemsSelected: cellTitlesSelected, permission: currentNiko.permission
                                          , config: { (item, itemSelected, cell) in
                                                cell.cellLabelEtablissement.text = item
                                                cell.cellLabelEtablissementSelected.text = itemSelected }
                                          , selectHandler: { (item) in       // item = buttonnumber
                                                let vc = TeamLocationTableViewController()
                                                vc.completion = {[weak self] text in    // text contains the location selected
                                                    self!.cellTitlesSelected[item] = text ?? ""
                                                    LocationEntreprise.locations[item].locationSelected = text ?? ""
                                                    // Update the tableview location
                                                    self!.reustableTable.reload(items: self!.cellTitles, itemsSelected: self!.cellTitlesSelected)
                                                }
                                                vc.locationRank = item
                                                self.navigationController?.pushViewController(vc, animated: true)
                                                })
            view.addSubview(reustableTable)
            let g = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                reustableTable.leadingAnchor.constraint(equalTo: g.leadingAnchor),
                reustableTable.trailingAnchor.constraint(equalTo: g.trailingAnchor),
                reustableTable.topAnchor.constraint(equalTo: g.topAnchor, constant: 36),
                reustableTable.heightAnchor.constraint(equalToConstant: 100)
            ])
    }
    
    // Settings for the niko calendar
    private func setCellsViewCalendar() {
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.sectionInset.left = 0
        flowLayout.sectionInset.right = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        let width = (collectionView.frame.size.width - 2 ) / 9
        let height = (collectionView.frame.size.height - 2 ) / 9
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
        databaseManager.requestRecordUserRetrievelocalisationData(uid: userUID, selectedDate: selectedDate, location: cellTitlesSelected, personnal: personnalCalendarSwitch, monthVsYear: true) { (result) in
            switch result {
            case .success(let data):
                self.dataTCDMonth = data
                self.collectionView.reloadData()
            case .failure(let error):
                self.presentFirebaseAlert(typeError: error, message: "")
            }
        }
    }
    
    private func setPieChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry1 = ChartDataEntry(x: Double(i), y: values[i], data: dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry1)
        }
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "")
        let c1 = UIColor.green
        let c2 = UIColor.yellow
        let c3 = UIColor.red
        
        pieChartDataSet.colors = [c1, c2, c3,]
        pieChartDataSet.valueTextColor = .black
        
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let pFormatter = NumberFormatter()
        pFormatter.maximumFractionDigits = 0
        pFormatter.zeroSymbol = ""          // don't display label if data = 0
        pieChartData.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        pieChartView.legend.enabled = false
        pieChartView.animate(yAxisDuration: 1)
        pieChartView.centerText = "Status"
        pieChartView.data = pieChartData
    }
    
    private func displayPieChart(index : Int) {
        if totalSquares[index] != "" {
            var nikoRanks = [Double]()
            let jour = Int(totalSquares[index])
            let nbSuper = dataTCDMonth[jour! - 1].nbSuper
            let nbNTR = dataTCDMonth[jour! - 1].nbNTR
            let nbTought = dataTCDMonth[jour! - 1].nbTought
            let nikoStatus = ["Super".localized(), "NTR".localized(), "Tought".localized()]
            nikoRanks.append(Double(nbSuper))
            nikoRanks.append(Double(nbNTR))
            nikoRanks.append(Double(nbTought))
            setPieChart(dataPoints: nikoStatus, values: nikoRanks)
        }
    }
    
    private func deleteRecord(uid: String, dateString: String) {
        // Retrieve the Firebase documentID for the userID and the date.
        
        // If document and Niko status exist ask if the user want to delete the Niko Status.
        
        // Delete the record if asked.
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
            let nikoRank = dataTCDMonth[jour! - 1].rankAverage
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
            // Calculate the date selected on the calendar
            //if totalSquares[indexPath.item] != "" {
                //let calendar = Calendar.current
                //guard let jour = Int(totalSquares[indexPath.item]) else { return }
                //let firstDayOfMonth = calendarHelper.firstOfMonth(date: selectedDate)
                //let date = calendar.date(byAdding: .day, value: jour - 1, to: firstDayOfMonth)!
                //let dateString = calendarHelper.dateString(date: date)
                //print("date sélectionnée: \(dateString)")
                //deleteRecord(uid: userUID, dateString: dateString)
            //}
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
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
