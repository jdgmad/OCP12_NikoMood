//
//  NikoSuiviViewController.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 17/04/2022.
//

import UIKit
import Charts

class NikoSuiviViewController: UIViewController {
    
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
    var selectedLineDate = Date()
 
    // MARK: - IBOutlets
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var lineChartView: LineChartView!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        getUserData()
        locationTableView.delegate = self
        locationTableView.dataSource = self
  

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
    
    @IBAction func previousYearButtonTapped(_ sender: UIButton) {
        selectedLineDate = calendarHelper.minusYear(date: selectedLineDate)
        setLineYearView()
    }
    
    @IBAction func nextYearButtonTapped(_ sender: UIButton) {
        selectedLineDate = calendarHelper.plusYear(date: selectedLineDate)
        setLineYearView()
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
                    self.setBarChart()
                    self.setBarMonthView()
                    self.setLineChart()
                    self.setLineYearView()
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
    // Bar Chart
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
        
        barChartView.fitBars = true
        barChartView.legend.enabled = false
        
        barChartView.backgroundColor = .systemBlue
    }
    
    func setBarChartData(niKoRecords: [NikoTCD]) {
        let yVals = (0..<niKoRecords.count).map { (i) -> BarChartDataEntry in
            let val1 = Double(niKoRecords[i].nbSuper)
            let val2 = Double(niKoRecords[i].nbNTR)
            let val3 = Double(niKoRecords[i].nbTought)
            return BarChartDataEntry(x: Double(i), yValues: [val1, val2, val3])
        }
        let set = BarChartDataSet(entries: yVals, label: "Niko Niko survey")
        set.drawIconsEnabled = false
        set.colors = [UIColor.green, UIColor.yellow, UIColor.red]
        //set.fillAlpha = 65/255
        set.stackLabels = ["Super", "Normal", "Dificille"]
        
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
    // Line Chart
    //

    func setLineYearView()
    {
        let year = calendarHelper.yearString(date: selectedLineDate)
        yearLabel.text =  year

        databaseManager.requestRecordUserRetrievelocalisationData(uid: userUID, selectedDate: selectedLineDate, location: cellTitlesSelected, personnal: false, monthVsYear: false, ishikawa: false) { (result) in
            switch result {
            case .success(let data):
                // update display bar Charts
                print("update display bar Charts")
                self.setLineChartData(niKoRecords: data)
            case .failure(let error):
                self.presentFirebaseAlert(typeError: error, message: "")
            }
        }

    }
    func setLineChart() {

        lineChartView.setScaleEnabled(true)

        let xAxis = lineChartView.xAxis
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.labelTextColor = .white
        xAxis.drawAxisLineEnabled = false
        xAxis.labelPosition = .bottom
        xAxis.axisMinimum = 0

        xAxis.granularityEnabled = true
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:months)
        lineChartView.xAxis.granularity = 1
        
        let leftAxis = lineChartView.leftAxis
        leftAxis.axisMinimum = 0
        leftAxis.labelTextColor = .white
        leftAxis.gridColor = .white
        
        lineChartView.backgroundColor = .systemBlue
        lineChartView.rightAxis.enabled = false
        lineChartView.legend.enabled = false

        lineChartView.animate(xAxisDuration: 1)
    }

    func setLineChartData(niKoRecords: [NikoTCD]) {

        let yVals1 = (0..<niKoRecords.count).map { (i) -> ChartDataEntry in
            let val1 = Double(niKoRecords[i].nbNTR)
            return ChartDataEntry(x: Double(i), y: val1 )
        }
        let yVals2 = (0..<niKoRecords.count).map { (i) -> ChartDataEntry in
            let val2 = Double(niKoRecords[i].nbTought)
            return ChartDataEntry(x: Double(i), y: val2 )
        }
        let yVals3 = (0..<niKoRecords.count).map { (i) -> ChartDataEntry in
            let val3 = Double(niKoRecords[i].nbSuper)
            return ChartDataEntry(x: Double(i), y: val3 )
        }
        
        let set1 = LineChartDataSet(entries: yVals1, label: "NTR")
        set1.axisDependency = .left
        set1.setColor(.yellow)
        set1.setCircleColor(.white)
        set1.lineWidth = 2
        set1.circleRadius = 3
        set1.fillAlpha = 65/255
        set1.drawCircleHoleEnabled = false
        set1.axisDependency = Charts.YAxis.AxisDependency.left

        let set2 = LineChartDataSet(entries: yVals2, label: "Tought")
        set2.axisDependency = .right
        set2.setColor(.red)
        set2.setCircleColor(.white)
        set2.lineWidth = 2
        set2.circleRadius = 3
        set2.fillAlpha = 65/255
        set2.drawCircleHoleEnabled = false
        set2.axisDependency = Charts.YAxis.AxisDependency.left

        let set3 = LineChartDataSet(entries: yVals3, label: "Super")
        set3.axisDependency = .right
        set3.setColor(.green)
        set3.setCircleColor(.white)
        set3.lineWidth = 2
        set3.circleRadius = 3
        set3.fillAlpha = 65/255
        set3.drawCircleHoleEnabled = false
        set3.axisDependency = Charts.YAxis.AxisDependency.left

        let data = LineChartData(dataSets: [set1, set2, set3])
        data.setValueTextColor(.white)
        data.setValueFont(.systemFont(ofSize: 9))
        let pFormatter = NumberFormatter()
        pFormatter.maximumFractionDigits = 0
        pFormatter.zeroSymbol = ""          // don't display label if data = 0
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))

        lineChartView.data = data
    }
    
}

//
// Extension Delegate et DataSource pour la la table locationTableView
//
extension NikoSuiviViewController: UITableViewDelegate, UITableViewDataSource {
    
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
                self!.setLineYearView()
            }
            vc.locationRank = buttonNumber
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
