//
//  IshikawaViewController.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 19/04/2022.
//

import UIKit
import Charts

class IshikawaViewController: UIViewController {

    
    // MARK: - Properties
    
    //let nikoFirestoreManager =  NikoFirestoreManager.shared
    let calendarHelper = CalendarHelper()
    var userUID = String()
    var locationSelected = String()
    private let authService: AuthService = AuthService()
    private let databaseManager: DatabaseManager = DatabaseManager()
    var currentNiko = NikoRecord(userID: "", firstname: "", lastname: "", position: "", plant: "", department: "", workshop: "", shift: "", nikoStatus: "", nikoRank: 0, niko5M: "", nikoCause: "", nikoComment: "", permission: 0, date: Date(), formattedMonthString: "", formattedDateString : "", formattedYearString: "", error: "")
    
    //  Properties for locationTableView
    var locationTableView = UITableView()
    var cellTitles = [ "Plant".localized(), "Workshop".localized(), "Shift".localized()]
    var cellTitlesSelected = ["", "", ""]
    
    //  Properties for Charts
    var selectedBarDate = Date()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var barChartView: BarChartView!
    
    @IBOutlet weak var horizontalBarChartView: HorizontalBarChartView!
    
    @IBOutlet weak var causeBarChartView: BarChartView!
    
    @IBOutlet weak var monthLabel: UILabel!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        getUserData()
        locationTableView.delegate = self
        locationTableView.dataSource = self
        barChartView.delegate = self

        setBarChart()
        setBarMonthView()
        setHorizontalBarChartView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        locationTableView.reloadData()
        //collectionView.reloadData()

    }

    // MARK: - IBActions
    
    @IBAction func previousMonthButtonTapped(_ sender: UIButton) {
        selectedBarDate = calendarHelper.minusMonth(date: selectedBarDate)
        setBarMonthView()
    }
    
    @IBAction func nextMonthButtonTapped(_ sender: UIButton) {
        selectedBarDate = calendarHelper.plusMonth(date: selectedBarDate)
        setBarMonthView()
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
                    self.locationTableView.reloadData()
                case .failure(let error):
                    self.presentFirebaseAlert(typeError: error, message: "Erreur récupération user Data")
                }
            }
        }
    }
    
    //
    // Location table View
    //
    
    // Global settings for tableview locationTableView
    private func setLocationTableView() {
        cellTitlesSelected[0] = currentNiko.plant
        cellTitlesSelected[1] = currentNiko.workshop
        cellTitlesSelected[2] = currentNiko.shift
        locationTableView.register(LocationTableCell.self, forCellReuseIdentifier: "locationTableCell")
        locationTableView.translatesAutoresizingMaskIntoConstraints = false
        locationTableView.rowHeight = 35
        locationTableView.backgroundColor = .none
        view.addSubview(locationTableView)
        
        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            locationTableView.leadingAnchor.constraint(equalTo: g.leadingAnchor),
            locationTableView.trailingAnchor.constraint(equalTo: g.trailingAnchor),
            locationTableView.topAnchor.constraint(equalTo: g.topAnchor, constant: 0),
            locationTableView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    //
    // Bar Chart 5M
    //
    
    func setBarMonthView()
    {
        let month = calendarHelper.monthString(date: selectedBarDate)
        let year = calendarHelper.yearString(date: selectedBarDate)
        monthLabel.text = month + " " + year

        databaseManager.requestRecordUserRetrievelocalisationData(uid: userUID, selectedDate: selectedBarDate, location: cellTitlesSelected, personnal: false, monthVsYear: true, ishikawa: false) { (result) in
            switch result {
            case .success(let data):
                // update display bar Charts
                print("update display bar Charts")
                self.setBarChartData(niKoRecords: data)
            case .failure(let error):
                self.presentFirebaseAlert(typeError: error, message: "")
            }
        }
    }
    
    func setBarChart() {
        
        let category5M = ["Methode", "Matiere", "Machine", "MO", "Milieu"]
        
        //barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: nikoFirestoreManager.category5M)
        //chartView.chartDescription.enabled = false
        barChartView.maxVisibleCount = 40
        barChartView.drawBarShadowEnabled = false
        barChartView.drawValueAboveBarEnabled = false
        barChartView.highlightFullBarEnabled = false
        
        let leftAxis = barChartView.leftAxis
        leftAxis.axisMinimum = 0
        leftAxis.labelTextColor = .white
        leftAxis.gridColor = .white
        
        barChartView.rightAxis.enabled = false
        
        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = .white
        xAxis.gridColor = .clear
        xAxis.valueFormatter = IndexAxisValueFormatter(values: category5M)
        
        barChartView.fitBars = true
        barChartView.legend.enabled = false
        
        barChartView.backgroundColor = .systemBlue
        
//        barChartView.xAxis.gridColor = .clear
//        barChartView.leftAxis.gridColor = .clear
//        barChartView.rightAxis.gridColor = .clear
        
        barChartView.xAxis.gridColor = .clear
        barChartView.leftAxis.gridColor = .white
        
    }
    
    func setBarChartData(niKoRecords: [NikoTCD]) {

        var val5M = [Double]()
        let recordsMethode = niKoRecords.map({$0.nbMethod})
        let sumRecordsMethode = Double(recordsMethode.reduce(0,+))
        val5M.append(sumRecordsMethode)
        let recordsMatiere = niKoRecords.map({$0.nbMatiere})
        let sumRecordsMatiere = Double(recordsMatiere.reduce(0,+))
        val5M.append(sumRecordsMatiere)
        let recordsMachine = niKoRecords.map({$0.nbMachine})
        let sumrecordsMachine = Double(recordsMachine.reduce(0,+))
        val5M.append(sumrecordsMachine)
        let recordsMaindoeuvre = niKoRecords.map({$0.nbMaindoeuvre})
        let sumrecordsMaindoeuvre = Double(recordsMaindoeuvre.reduce(0,+))
        val5M.append(sumrecordsMaindoeuvre)
        let recordsMilieu = niKoRecords.map({$0.nbMilieu})
        let sumrecordsMilieu = Double(recordsMilieu.reduce(0,+))
        val5M.append(sumrecordsMilieu)
        
        
        let yVals = (0..<5).map { (i) -> BarChartDataEntry in
            let val = val5M[i]
            return BarChartDataEntry(x: Double(i), yValues: [val])
        }

        
        let set = BarChartDataSet(entries: yVals, label: "Ishikawa 5M")
        set.drawIconsEnabled = false
        set.colors = [UIColor.green, UIColor.orange, UIColor.blue, UIColor.yellow, UIColor.red]
        //set.fillAlpha = 65/255
        set.stackLabels = databaseManager.category5M
        
        let data = BarChartData(dataSet: set)
        
        data.setValueFont(.systemFont(ofSize: 7, weight: .light))
        data.setValueTextColor(.black)
        let pFormatter = NumberFormatter()
        pFormatter.maximumFractionDigits = 0
        pFormatter.zeroSymbol = ""          // don't display label if data = 0
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        barChartView.data = data
        }
 
    //
    // Bar Chart Cause (horizontal)
    //
    func setHorizontalBarChartView() {
        
        horizontalBarChartView.legend.enabled = false
        horizontalBarChartView.xAxis.granularityEnabled = true
        horizontalBarChartView.xAxis.granularity = 1
        horizontalBarChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        horizontalBarChartView.animate(xAxisDuration: 0.0, yAxisDuration: 0.5, easingOption: .linear)
        horizontalBarChartView.chartDescription?.text = ""

        let rightAxis = horizontalBarChartView.rightAxis
        rightAxis.drawGridLinesEnabled = false
        
        let leftAxis = horizontalBarChartView.leftAxis
        leftAxis.drawGridLinesEnabled = false

        
        let xAxis = horizontalBarChartView.xAxis
        xAxis.drawGridLinesEnabled = false
        
        horizontalBarChartView.setVisibleXRange(minXRange: 6.0, maxXRange: 6.0)
        
        horizontalBarChartView.setExtraOffsets (left: 30.0, top: 20.0, right:30.0, bottom: 20.0)
    }
    
    func drawHorizontalBarChartView(valCategory5M: Int) {

        databaseManager.requestRecordUserRetrieveIshikawaData(uid: userUID, selectedDate: selectedBarDate, location: cellTitlesSelected, personnal: false, monthVsYear: true, category5MSelected: valCategory5M) { (result) in
            switch result {
            case .success(let data):
                // update display bar Charts
//                print ("data ishi")
//                print(data.count)
                var dataEntries = [ChartDataEntry]()
                var labels = [String] ()
                
                if data.count > 0 {
                (0...data.count - 1).forEach { n in
                    //let val = data[n].value
                    labels.append(data[n].key)
                    let entry = BarChartDataEntry(x: Double(n), y: Double(data[n].value))
                    dataEntries.append(entry)
                    let barChartDataSet = BarChartDataSet(entries: dataEntries, label: "")
                    barChartDataSet.drawValuesEnabled = false
                    barChartDataSet.colors = ChartColorTemplates.joyful()
                    let barChartData = BarChartData(dataSet: barChartDataSet)
                    
                    let pFormatter = NumberFormatter()
                    pFormatter.maximumFractionDigits = 0
                    pFormatter.zeroSymbol = ""          // don't display label if data = 0
                    barChartData.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
                    
                    self.horizontalBarChartView.data = barChartData
                        
                    self.horizontalBarChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
                    }
                }
                
//                for (key, value) in data
//                {
//                   // data[key] = value.sorted(by: { $0.pri < $1.pri })
//                    print("Key: \(key) value: \(value)")
//                }
//
//                var dataEntries = [ChartDataEntry]()
//                for i in 0..<data.count {
//                    let entry = BarChartDataEntry(x: Double(i), y: Double(data[i]))
//                    dataEntries.append(entry)
//                }
            case .failure(let error):
                self.presentFirebaseAlert(typeError: error, message: "")
            }
        }
    }
    
}
    

//
// Extension Delegate et DataSource pour la la table locationTableView
//
extension IshikawaViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        if currentNiko.permission >= 4  {
            cell.isUserInteractionEnabled = true
            button.isHidden = false
        } else {
            cell.isUserInteractionEnabled = false
            button.isHidden = true
        }
        case 1:
        if currentNiko.permission >= 3   {
            cell.isUserInteractionEnabled = true
            button.isHidden = false
        } else {
            cell.isUserInteractionEnabled = false
            button.isHidden = false
            button.isHidden = true
        }
        case 2:
        if currentNiko.permission >= 2   {
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
                print("Action suite selection location")
                self!.setBarMonthView()
                //self!.setLineYearView()
            }
            vc.locationRank = buttonNumber
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension IshikawaViewController : ChartViewDelegate {

    /// - Parameters:
    ///   - entry: The selected Entry.
    ///   - highlight: The corresponding highlight object that contains information about the highlighted position such as dataSetIndex etc.
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight){
        print("Point: \(entry.x) Value: \(entry.y)")
        drawHorizontalBarChartView(valCategory5M: Int(entry.x))
    }

}
