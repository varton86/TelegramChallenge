//
//  ChartViewController + Extension.swift
//  TestTaskTelegram
//
//  Created by Oleg Soloviev on 16.03.2019.
//  Copyright © 2019 varton. All rights reserved.
//

import UIKit

extension ChartViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row > (keysArray.count + 1) {
            return 0
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 2...):
            let cell = tableView.cellForRow(at: indexPath)
            if cell?.accessoryType == .checkmark {
                cell?.accessoryType = .none
                cell?.imageView?.isHidden = true
                linesArray[indexPath.row - 2] = false
            } else {
                cell?.accessoryType = .checkmark
                cell?.imageView?.isHidden = false
                linesArray[indexPath.row - 2] = true
            }
            toggleLines = true
            let linesVisible = linesArray.filter{$0}
            if linesVisible.count > 0 {
                lineChart.isHidden = false
                flatChart.isHidden = false
            } else {
                lineChart.isHidden = true
                flatChart.isHidden = true
            }
            showChart()
        case (1, 0):
            let cell = tableView.cellForRow(at: indexPath)
            cell?.textLabel!.text = dayChartMode ? "Switch to Day Mode" : "Switch to Night Mode"            
            dayChartMode = !dayChartMode
            setViewColorMode()
            setViewColorTheme()
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let view = UIView()
            view.backgroundColor = ModeColor.tableViewBackgroundColor
            
            let label = UILabel()
            label.frame = CGRect(x: 15, y: 23, width: 100, height: 35)
            label.text = "FOLLOWERS"
            label.font = UIFont.preferredFont(forTextStyle: .subheadline)
            label.textColor = ModeColor.tableViewHeaderTextColor
            
            view.addSubview(label)
            return view
        }
        return super.tableView(tableView, viewForHeaderInSection: section)
    }

}
