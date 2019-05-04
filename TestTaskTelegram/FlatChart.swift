//
//  FlatChart.swift
//  TestTaskTelegram
//
//  Created by Oleg Soloviev on 11.03.2019.
//  Copyright © 2019 varton. All rights reserved.
//

import UIKit

struct PointEntry {
    let value: [Int]
    let label: String
}

class FlatChart: UIView {

    var originDataEntries: [PointEntry]?
    var dataEntries: [PointEntry]? {
        didSet {
            if let entries = dataEntries, let linesArray = linesArray {
                let linesCounter = entries[0].value.count
                maxValue = 0
                minValue = Int.max
                for i in 0..<entries.count {
                    for j in 0..<linesCounter {
                        if linesArray[j] {
                            let value = entries[i].value[j]
                            maxValue = max(value, maxValue)
                            minValue = min(value, minValue)
                        }
                    }
                }
            }
            self.setSubview()
        }
    }
    var colorsDict: [String: Any]?
    var keysArray: [String]?
    var linesArray: [Bool]?
    var lowerValue: Int = 0

    var lineGap: CGFloat = 0.0
    var lineWidth: CGFloat = 1.0
    
    let mainLayer: CALayer = CALayer()
    let dataLayer: CALayer = CALayer()    

    var dataPoints: [[CGPoint]]?
    
    var maxValue: Int = 0
    var minValue: Int = 0
    
    var toggleLines = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setView()
    }

    override func layoutSubviews() {
        mainLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        dataLayer.frame = CGRect(x: 1, y: 3, width: mainLayer.frame.width - 2.0, height: mainLayer.frame.height - 6.0)
        setSubview()
    }
    
    func setView() {
        mainLayer.addSublayer(dataLayer)
        self.layer.addSublayer(mainLayer)
        dataLayer.masksToBounds = true
    }
    
    func setSubview() {
        if let dataEntries = dataEntries, dataEntries.count > 1 {
            lineGap = dataLayer.frame.width / CGFloat(dataEntries.count-1)
            dataPoints = convertDataEntriesToPoints(entries: originDataEntries)
            drawHorizontalLines()
            drawLabels()

            if let _ = dataLayer.sublayers {
                drawChangeChart()
            } else {
                drawChart()
            }
        }
    }
    
    func convertDataEntriesToPoints(entries: [PointEntry]?) -> [[CGPoint]] {
        var result = [[CGPoint]]()
        if let entries = entries, entries.count > 1 {
            let minMaxRange: CGFloat = maxValue != minValue ? CGFloat(maxValue - minValue) : 0.1
            for i in 0..<entries[0].value.count {
                var pointArray = [CGPoint]()
                for j in 0..<entries.count {
                    
                    let height = dataLayer.frame.height * (1 - ((CGFloat(entries[j].value[i]) - CGFloat(minValue)) / minMaxRange))
                    let point = CGPoint(x: CGFloat(j)*lineGap - CGFloat(lowerValue-1)*lineGap, y: height)
                    pointArray.append(point)
                }
                result.append(pointArray)
            }
        }
        return result
    }
    
    func drawChart() {
        if let dataPoints = dataPoints, dataPoints.count > 0, let colorsDict = colorsDict, let keysArray = keysArray {
            for i in 0..<dataPoints.count {
                if let linePath = createPath(dataPoints[i]) {
                    let lineLayer = CAShapeLayer()
                    lineLayer.path = linePath.cgPath
                    lineLayer.lineCap = .round
                    lineLayer.strokeColor = UIColor(hex: colorsDict[keysArray[i]] as! String).cgColor
                    lineLayer.lineWidth = lineWidth
                    lineLayer.fillColor = UIColor.clear.cgColor
                    
                    dataLayer.addSublayer(lineLayer)
                }
            }
        }
    }
    
    func drawChangeChart() {
        if let dataPoints = dataPoints, dataPoints.count > 0, let linesArray = linesArray, let sublayers = dataLayer.sublayers {
            for i in 0..<dataPoints.count {
                if let linePath = createPath(dataPoints[i]) {
                    if toggleLines {
                        CATransaction.begin()
                        CATransaction.setAnimationDuration(0.25)
                        sublayers[i].opacity = linesArray[i] ? 1 : 0
                        CATransaction.commit()
                    }
                    let animationPath = CABasicAnimation(keyPath: "path")
                    animationPath.toValue = linePath.cgPath
                    animationPath.fillMode = .both
                    animationPath.isRemovedOnCompletion = false
                    sublayers[i].add(animationPath, forKey: nil)
                }
            }
            toggleLines = false
        }
    }

    func createPath(_ dataPoints: [CGPoint]?) -> UIBezierPath? {
        guard let dataPoints = dataPoints, dataPoints.count > 0 else {
            return nil
        }
        let path = UIBezierPath()

        var points = dataPoints
        let first = points.removeFirst()
        
        path.move(to: first)
        points.forEach { path.addLine(to: $0) }

        return path
    }
    
    func drawHorizontalLines() {}
    func drawLabels() {}
}
