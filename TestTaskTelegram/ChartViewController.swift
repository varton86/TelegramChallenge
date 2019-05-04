//
//  ViewController.swift
//  TestTaskTelegram
//
//  Created by Oleg Soloviev on 10.03.2019.
//  Copyright © 2019 varton. All rights reserved.
//

import UIKit

class ChartViewController: UITableViewController {
    
    var columnsArray = [[Any]]()
    var typesDict = [String: Any]()
    var namesDict = [String: Any]()
    var colorsDict = [String: Any]()

    var keysArray = [String]()
    var linesArray = [Bool]()
    var dayChartMode = true
    var toggleLines = true

    private let chartSlider = ChartSlider(frame: .zero)
    private var lowerValue: Int = 0
    private var upperValue: Int = 0
    private var originDataEntries: [PointEntry]?

    enum ModeColor {
        static var tableViewBackgroundColor = UIColor.clear
        static var tableViewSeparatorColor = UIColor.clear
        static var tableViewCellBackgroundColor = UIColor.clear
        static var tableViewHeaderTextColor = UIColor.clear
        static var lineChartTextColor = UIColor.clear
        static var textColor = UIColor.clear
        static var lineChartGridColor = UIColor.clear
        static var statusBarStyle: UIBarStyle = .default
    }

    private enum DayModeColor {
        static let tableViewBackgroundColor = UIColor(hex: "#EFEFF4")
        static let tableViewSeparatorColor = UIColor(hex: "#C8C7CC")
        static let tableViewCellBackgroundColor = UIColor.white
        static let tableViewHeaderTextColor = UIColor(hex: "#4A4A50")
        static let lineChartTextColor = UIColor(hex: "#8A9197")
        static let lineChartGridColor = UIColor.lightGray
        static let textColor = UIColor.black
        static let statusBarStyle: UIBarStyle = .default
    }
    
    private enum NightModeColor {
        static let tableViewBackgroundColor = UIColor(hex: "#19222D")
        static let tableViewSeparatorColor = UIColor(hex: "#19222D")
        static let tableViewCellBackgroundColor = UIColor(hex: "#222F3E")
        static let tableViewHeaderTextColor = UIColor(hex: "#5F7083")
        static let lineChartTextColor = UIColor(hex: "#5F7083")
        static let lineChartGridColor = UIColor(hex: "#19222D")
        static let textColor = UIColor.white
        static let statusBarStyle: UIBarStyle = .black
    }

    @IBOutlet weak var lineChart: LineChart!
    @IBOutlet weak var flatChart: FlatChart!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setView()
        setViewColorMode()
        showSlider()
        setMinMaxValueChart()
        showChart()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setViewColorTheme()
    }

    override func viewDidLayoutSubviews() {
        chartSlider.frame = CGRect(x: 0, y: 0, width: flatChart.frame.width, height: flatChart.frame.height)
    }
    
}

extension ChartViewController {

    func setView() {
        keysArray = generateKeys()
        linesArray = Array(repeating: true, count: keysArray.count)
        originDataEntries = generateEntries(1, columnsArray[0].count)

        lineChart.lineWidth = 2.0
        lineChart.keysArray = keysArray
        lineChart.colorsDict = colorsDict
        lineChart.originDataEntries = originDataEntries
        
        flatChart.keysArray = keysArray
        flatChart.colorsDict = colorsDict
        flatChart.originDataEntries = originDataEntries
    }
    
    func showChart() {
        lineChart.toggleLines = toggleLines
        lineChart.linesArray = linesArray
        lineChart.lowerValue = lowerValue
        lineChart.dataEntries = generateEntries(lowerValue, upperValue)
        
        if toggleLines {
            flatChart.toggleLines = toggleLines
            flatChart.linesArray = linesArray
            flatChart.lowerValue = 1
            flatChart.dataEntries = originDataEntries
            toggleLines = false
        }
    }

    func setViewColorMode() {
        ModeColor.tableViewBackgroundColor = dayChartMode ? DayModeColor.tableViewBackgroundColor : NightModeColor.tableViewBackgroundColor
        ModeColor.tableViewSeparatorColor = dayChartMode ? DayModeColor.tableViewSeparatorColor : NightModeColor.tableViewSeparatorColor
        ModeColor.tableViewCellBackgroundColor = dayChartMode ? DayModeColor.tableViewCellBackgroundColor : NightModeColor.tableViewCellBackgroundColor
        ModeColor.tableViewHeaderTextColor = dayChartMode ? DayModeColor.tableViewHeaderTextColor : NightModeColor.tableViewHeaderTextColor
        ModeColor.lineChartTextColor = dayChartMode ? DayModeColor.lineChartTextColor : NightModeColor.lineChartTextColor
        ModeColor.lineChartGridColor = dayChartMode ? DayModeColor.lineChartGridColor : NightModeColor.lineChartGridColor
        ModeColor.textColor = dayChartMode ? DayModeColor.textColor : NightModeColor.textColor
        ModeColor.statusBarStyle = dayChartMode ? DayModeColor.statusBarStyle : NightModeColor.statusBarStyle
    }
    
    func setViewColorTheme() {
        tableView.backgroundColor = ModeColor.tableViewBackgroundColor
        lineChart.backgroundColor = ModeColor.tableViewCellBackgroundColor
        tableView.separatorColor = ModeColor.tableViewSeparatorColor
        flatChart.backgroundColor = ModeColor.tableViewCellBackgroundColor
        lineChart.textColor =  ModeColor.lineChartTextColor
        lineChart.gridColor = ModeColor.lineChartGridColor
        chartSlider.dayChartMode = dayChartMode
        for i in 0..<keysArray.count+2 {
            let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0))
            cell?.backgroundColor = ModeColor.tableViewCellBackgroundColor
            cell?.tintColor = view.tintColor
            cell?.textLabel?.backgroundColor = ModeColor.tableViewCellBackgroundColor
            cell?.textLabel?.textColor = ModeColor.textColor
            if i > 1 {
                cell?.imageView?.backgroundColor = UIColor(hex: colorsDict[keysArray[i-2]] as! String)
                cell?.imageView?.layer.cornerRadius = 2.0
                cell?.textLabel?.text = namesDict[keysArray[i-2]] as? String
            }
        }
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1))
        cell?.backgroundColor = ModeColor.tableViewCellBackgroundColor
        cell?.tintColor = view.tintColor
        cell?.textLabel?.backgroundColor = ModeColor.tableViewCellBackgroundColor
        cell?.textLabel?.textColor = view.tintColor
        
        navigationController?.navigationBar.barTintColor = ModeColor.tableViewCellBackgroundColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key(rawValue:
            NSAttributedString.Key.foregroundColor.rawValue): ModeColor.textColor]
        navigationController?.navigationBar.barStyle = ModeColor.statusBarStyle
        tableView.reloadData()
    }

}

private extension ChartViewController {

    func generateKeys() -> [String] {
        var keyArray = [String]()

        for i in 1..<columnsArray.count {
            keyArray.append(columnsArray[i][0] as! String)
        }
        
        return keyArray
    }

    func generateEntries(_ lowerValue: Int, _ upperValue: Int) -> [PointEntry] {
        var result = [PointEntry]()
        
        for i in lowerValue..<upperValue {

            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMM dd"
            let date = Date(timeIntervalSince1970: (columnsArray[0][i] as! Double) / 1000)

            var value = [Int]()
            for j in 1..<columnsArray.count {
                value.append(columnsArray[j][i] as! Int)
            }
            result.append(PointEntry(value: value, label: formatter.string(from: date)))
        }
        return result
    }
    
    func showSlider() {
        flatChart.addSubview(chartSlider)
        chartSlider.addTarget(self, action: #selector(chartSliderValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func chartSliderValueChanged(_ chartSlider: ChartSlider) {
        setMinMaxValueChart()
        showChart()
    }

    func setMinMaxValueChart() {
        lowerValue = Int(chartSlider.lowerValue * CGFloat(columnsArray[0].count))
        lowerValue = lowerValue == 0 ? 1 : lowerValue
        upperValue = Int(chartSlider.upperValue * CGFloat(columnsArray[0].count))
    }
    
}
