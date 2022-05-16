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
                    self.reustableTable.reload(items: self.cellTitles, itemsSelected: self.cellTitlesSelected)
                    self.setBarChart()
                    self.setBarMonthView()
                    self.setLineChart()
                    self.setLineYearView()
                case .failure(let error):
                    self.presentFirebaseAlert(typeError: error, message: error.description)
                }
            }
        }
    }
    

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
                        self!.setBarMonthView()
                    }
                    vc.locationRank = item
                    self.navigationController?.pushViewController(vc, animated: true)
                })
        view.addSubview(reustableTable)
        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            reustableTable.leadingAnchor.constraint(equalTo: g.leadingAnchor),
            reustableTable.trailingAnchor.constraint(equalTo: g.trailingAnchor),
            reustableTable.topAnchor.constraint(equalTo: g.topAnchor, constant: 0),
            reustableTable.heightAnchor.constraint(equalToConstant: 100)
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

        databaseManager.requestRecordUserRetrievelocalisationData(uid: userUID, selectedDate: selectedBarDate, location: cellTitlesSelected, personnal: false, monthVsYear: true) { (result) in
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
    
    private func setBarChart() {
        barChartView.maxVisibleCount = 40
        barChartView.drawBarShadowEnabled = false
        barChartView.drawValueAboveBarEnabled = false
        barChartView.highlightFullBarEnabled = false
        barChartView.rightAxis.enabled = false
        barChartView.fitBars = true
        barChartView.legend.enabled = false
        barChartView.backgroundColor = .systemBlue
        
        let leftAxis = barChartView.leftAxis
        leftAxis.axisMinimum = 0
        leftAxis.labelTextColor = .white
        leftAxis.gridColor = .white
        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = .white
        xAxis.gridColor = .clear
    }
    
    private func setBarChartData(niKoRecords: [NikoTCD]) {
        let yVals = (0..<niKoRecords.count).map { (i) -> BarChartDataEntry in
            let val1 = Double(niKoRecords[i].nbSuper)
            let val2 = Double(niKoRecords[i].nbNTR)
            let val3 = Double(niKoRecords[i].nbTought)
            return BarChartDataEntry(x: Double(i), yValues: [val1, val2, val3])
        }
        let set = BarChartDataSet(entries: yVals, label: "Niko Niko survey")
        set.drawIconsEnabled = false
        set.colors = [UIColor.green, UIColor.yellow, UIColor.red]
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
    // Year Line Chart
    //

    private func setLineYearView() {
        let year = calendarHelper.yearString(date: selectedLineDate)
        yearLabel.text =  year

        databaseManager.requestRecordUserRetrievelocalisationData(uid: userUID, selectedDate: selectedLineDate, location: cellTitlesSelected, personnal: false, monthVsYear: false) { (result) in
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
    
    private func setLineChart() {
        let xAxis = lineChartView.xAxis
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.labelTextColor = .white
        xAxis.drawAxisLineEnabled = false
        xAxis.labelPosition = .bottom
        xAxis.axisMinimum = 0
        xAxis.granularityEnabled = true
        let leftAxis = lineChartView.leftAxis
        leftAxis.axisMinimum = 0
        leftAxis.labelTextColor = .white
        leftAxis.gridColor = .white
        
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:months)
        lineChartView.xAxis.granularity = 1
        lineChartView.backgroundColor = .systemBlue
        lineChartView.rightAxis.enabled = false
        lineChartView.legend.enabled = false
        lineChartView.animate(xAxisDuration: 1)
        lineChartView.setScaleEnabled(true)
    }

    private func setLineChartData(niKoRecords: [NikoTCD]) {
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
