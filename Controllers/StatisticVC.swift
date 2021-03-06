import UIKit
import CorePlot
var historyDataStruct = [HistoryDataStruct]()
var selectedCategoryName = ""
var sum = 0.0
class StatisticVC: UIViewController, CALayerDelegate {
    @IBOutlet weak var hostView: CPTGraphHostingView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControll: UISegmentedControl!
    @IBOutlet weak var titleLabel: UILabel!
    var allData = [GraphDataStruct]()
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        deselectAllCells()
    }
    func deselectAllCells() {
        for i in 0..<allData.count {
            let indexPath = IndexPath(row: i, section: 0)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    func hideandShowGrapg() {
        hostView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.hostView.alpha = 1
        }
    }
    func getMaxSum() {
        for i in 0..<allData.count {
            sum += allData[i].value
        }
    }
    func getPercent(n: Double) -> Double {
        if allData.count != 0 {
            let biggest = sum
            let results = ((100 * n) / biggest)
            return results
        } else { return 0.0 }
    }
    func updateUI() {
        sum = 0.0
        tableView.delegate = self
        tableView.dataSource = self
        if expenseLabelPressed == true {
            segmentControll.selectedSegmentIndex = 0
        } else { segmentControll.selectedSegmentIndex = 1 }
        allData = createTableData()
        getMaxSum()
        initPlot()
    }
    func createTableData() -> [GraphDataStruct] {
        allData = []
        if segmentControll.selectedSegmentIndex == 0 {
            for (key, value) in sumAllCategories {
                if (sumAllCategories[key] ?? 0.0) < 0.0 {
                    allData.append(GraphDataStruct(category: key, value: value))
                }
            }
            titleLabel.text = "Expenses for \(selectedPeroud)"
            ifNoData()
            return allData.sorted(by: { $1.value > $0.value})
        } else {
            for (key, value) in sumAllCategories {
                if (sumAllCategories[key] ?? 0.0) > 0.0 {
                    allData.append(GraphDataStruct(category: key, value: value))
                }
            }
            titleLabel.text = "Incomes for \(selectedPeroud)"
            ifNoData()
            return allData.sorted(by: { $0.value > $1.value})
        }
    }
    func ifNoData() {
        if allData.count == 0 {
            titleLabel.textAlignment = .center
            titleLabel.text = "No " + (titleLabel.text ?? "Data")
        } else {
            titleLabel.textAlignment = .left
        }
    }
    @IBAction func selectedSegment(_ sender: UISegmentedControl) {
        allData = createTableData()
        sum = 0.0
        getMaxSum()
        initPlot()
        tableView.reloadData()
        hideandShowGrapg()
    }
    @IBAction func clodePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    func getHistoryScruct(indexPathRow: Int) {
        for i in 0..<allSelectedTransactionsData.count {
            if allData[indexPathRow].category == allSelectedTransactionsData[i].category {
                let data = allSelectedTransactionsData[i]
                historyDataStruct.append(HistoryDataStruct(value: data.value, date: data.date ?? ""))
            }
        }
        selectedCategoryName = allData[indexPathRow].category
    }
    func initPlot() {
        hostView.allowPinchScaling = false
        configureGraph()
        configureChart()
    }
    func configureGraph() {
        let graph = CPTXYGraph(frame: hostView.bounds)
        hostView.hostedGraph = graph
        graph.paddingLeft = 0.0
        graph.paddingTop = 0.0
        graph.paddingRight = 0.0
        graph.paddingBottom = 0.0
        graph.axisSet = nil
    }
    func configureChart() {
        let graph = hostView.hostedGraph!
        let pieChart = CPTPieChart()
        pieChart.delegate = self
        pieChart.dataSource = self
        pieChart.pieRadius = (min(hostView.bounds.size.width, hostView.bounds.size.height) * 0.7) / 2
        pieChart.sliceDirection = .clockwise
        pieChart.labelOffset = -0.7 * pieChart.pieRadius
        let borderStyle = CPTMutableLineStyle()
        borderStyle.lineWidth = 1.5
        pieChart.borderLineStyle = borderStyle
        let textStyle = CPTMutableTextStyle()
        textStyle.textAlignment = .left
        textStyle.fontSize = 15
        pieChart.labelTextStyle = textStyle
        graph.add(pieChart)
    }
    func colorComponentsFrom(number:Int,maxCount:Int) -> (Int,Int,Int){
        let maxColor = Double(0xFFFFFF - 0x222222);
        let ratio = maxColor / Double(maxCount);
        let intColor = lround(ratio * Double(number)) ;
        let redComponent =      ((intColor & 0xFFAFAF) >> (2*8)) & 0xff;
        let greenComponent =    ((intColor & 0xAFFFAF) >> (1*8)) & 0xff;
        let blueComponent =     ((intColor & 0x9B9BFF) >> (0*8)) & 0xff;
        return (redComponent,greenComponent,blueComponent);
    }
    func setupColorView(_ view: UIView, indexPath: Int) {
        var n = indexPath
        if indexPath == 0 { n = 100 }
        let colorComponents = colorComponentsFrom(number: Int(String(n)) ?? 0, maxCount: Int(allData[0].value))
        view.backgroundColor = UIColor(displayP3Red: CGFloat(colorComponents.0)/255, green: CGFloat(colorComponents.1)/255, blue: CGFloat(colorComponents.2)/255, alpha: 0.7)
        view.layer.cornerRadius = 3
    }
    var selectedIndexPath = 0
    @objc func deselectRow() {
        let indexPax = IndexPath(row: selectedIndexPath, section: 0)
        tableView.deselectRow(at: indexPax, animated: true)
    }
}
extension StatisticVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.statisticCellIdent, for: indexPath) as! StatisticCell
        let data = allData[indexPath.row]
        if data.value > 0.0 {
            cell.amountLabel.textColor = K.Colors.category
        } else { cell.amountLabel.textColor = K.Colors.negative }
        if data.value < Double(Int.max) {
            cell.amountLabel.text = "\(Int(data.value))"
        } else {
            cell.amountLabel.text = "\(data.value)"
        }
        cell.categoryLabel.text = "\(data.category.capitalized)"
        cell.percentLabel.text = "\(String(format: "%.2f", getPercent(n: data.value)))%"
        setupColorView(cell.colorView, indexPath: indexPath.row)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        historyDataStruct = [HistoryDataStruct]()
        DispatchQueue.init(label: "sort", qos: .userInteractive).async {
            self.getHistoryScruct(indexPathRow: indexPath.row)
            DispatchQueue.main.sync {
                self.performSegue(withIdentifier: K.historySeque, sender: self)
            }
        }
    }
}
extension StatisticVC: CPTPieChartDataSource, CPTPieChartDelegate {
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return UInt(allData.count)
    }
    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
        let cell = allData[Int(idx)].value
        return cell
    }
    func sliceFill(for pieChart: CPTPieChart, record idx: UInt) -> CPTFill? {
        var n = idx
        if idx == 0 { n = 100 }
        let colorComponents = colorComponentsFrom(number: Int(String(n)) ?? 0, maxCount: Int(allData[0].value))
        return CPTFill(color: CPTColor(componentRed: CGFloat(colorComponents.0)/255, green: CGFloat(colorComponents.1)/255, blue: CGFloat(colorComponents.2)/255, alpha: 0.7))
    }
    func dataLabel(for plot: CPTPlot, record idx: UInt) -> CPTLayer? {
        let value = getPercent(n: allData[Int(idx)].value)
        if value > 10.0 {
            let layer = CPTTextLayer(text: "\(Int(value))%")
            layer.textStyle = plot.labelTextStyle
            return layer
        } else {
            let layer = CPTTextLayer(text: "")
            return layer
        }
    }
    func pieChart(_ plot: CPTPieChart, sliceWasSelectedAtRecord idx: UInt) {
        selectedIndexPath = Int(idx)
        let indexPath = IndexPath(row: Int(idx), section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
        Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(deselectRow), userInfo: nil, repeats: false)
    }
}
struct GraphDataStruct {
    var category: String
    var value: Double
}
struct HistoryDataStruct {
    var value: Double
    var date: String
}
