//
//  IshikawaViewController.swift
//  NikoMood
//
//  Created by José DEGUIGNE on 19/04/2022.
//

import UIKit
import Charts

class IshikawaViewController: UIViewController {

    //Refactor the location table view in : Niko Record, Niko following and Ishikawa by creating a genericTableView
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
        barChartView.delegate = self

        setBarChart()
        setBarMonthView()
        setHorizontalBarChartView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    private func getUserData() {
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
            reustableTable.topAnchor.constraint(equalTo: g.topAnchor, constant: 0),
            reustableTable.heightAnchor.constraint(equalToConstant: 100)
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
        barChartView.maxVisibleCount = 40
        barChartView.drawBarShadowEnabled = false
        barChartView.drawValueAboveBarEnabled = false
        barChartView.highlightFullBarEnabled = false
        barChartView.fitBars = true
        barChartView.legend.enabled = false
        barChartView.backgroundColor = .systemBlue
        barChartView.xAxis.gridColor = .clear
        barChartView.leftAxis.gridColor = .white
        barChartView.rightAxis.enabled = false
        
        let leftAxis = barChartView.leftAxis
        leftAxis.axisMinimum = 0
        leftAxis.labelTextColor = .white
        leftAxis.gridColor = .white
        
        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = .white
        xAxis.gridColor = .clear
        xAxis.valueFormatter = IndexAxisValueFormatter(values: category5M)
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
print ("data ishi")
print(data)
print(data.count)
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
            case .failure(let error):
                self.presentFirebaseAlert(typeError: error, message: "")
            }
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
