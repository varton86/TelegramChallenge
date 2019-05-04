//
//  Chart.swift
//  TestTaskTelegram
//
//  Created by Oleg Soloviev on 11.03.2019.
//  Copyright © 2019 varton. All rights reserved.
//

import UIKit

class LineChart: FlatChart {
    
    var textColor = UIColor.lightGray {
        didSet {
            drawLabels()
        }
    }
    var gridColor = UIColor.lightGray {
        didSet {
            drawHorizontalLines()
        }
    }
    let gridLayer: CALayer = CALayer()
    let dateLayer: CALayer = CALayer()

    private let bottomSpace: CGFloat = 30.0    

    override func layoutSubviews() {
        mainLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        dateLayer.frame = CGRect(x: 0, y: 0, width: mainLayer.frame.width, height: mainLayer.frame.height)
        dataLayer.frame = CGRect(x: 0, y: -2, width: mainLayer.frame.width, height: mainLayer.frame.height - bottomSpace)
        gridLayer.frame = CGRect(x: 0, y: 0, width: mainLayer.frame.width, height: mainLayer.frame.height - bottomSpace)
        setSubview()
    }

    override func setView() {
        mainLayer.addSublayer(dataLayer)
        self.layer.addSublayer(dateLayer)
        self.layer.addSublayer(gridLayer)
        self.layer.addSublayer(mainLayer)
        dataLayer.masksToBounds = true
    }
    
    override func drawLabels() {
        guard let dataEntries = dataEntries, dataEntries.count > 0 else {
            return
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        dateLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
        let dateGap = dateLayer.frame.size.width/CGFloat(5)
        for i in 0...4 {
            let step = i == 4 ? dataEntries.count-1 : i * Int(dataEntries.count/4)
            drawLabel(x: CGFloat(i) * dateGap, text: dataEntries[step].label)
        }
        
        CATransaction.commit()
    }
    
    func drawLabel(x: CGFloat, text: String) {
        let textLayer = CATextLayer()
        textLayer.frame = CGRect(x: x, y: dateLayer.frame.size.height - bottomSpace/2 - 6, width: dateLayer.frame.size.width/CGFloat(5), height: 16)
        textLayer.foregroundColor = textColor.cgColor
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
        textLayer.fontSize = 11
        textLayer.string = text
        dateLayer.addSublayer(textLayer)
    }

    override func drawHorizontalLines() {
        guard let dataEntries = dataEntries else {
            return
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        gridLayer.sublayers?.forEach({$0.removeFromSuperlayer()})

        var gridValues: [CGFloat]? = nil
        if dataEntries.count > 0 && dataEntries.count < 6 {
            gridValues = [0, 1]
        } else if dataEntries.count >= 6 {
            gridValues = [0, 0.10, 0.28, 0.46, 0.64, 0.82, 1]
        }
        if let gridValues = gridValues {
            for value in gridValues where value > 0 {
                let height = value * gridLayer.frame.size.height
                
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 0, y: height))
                path.addLine(to: CGPoint(x: gridLayer.frame.size.width, y: height))
                
                let lineLayer = CAShapeLayer()
                lineLayer.path = path.cgPath
                lineLayer.fillColor = UIColor.clear.cgColor
                lineLayer.strokeColor = gridColor.cgColor
                lineLayer.lineWidth = value == 1 ? 0.5 : 0.3

                gridLayer.addSublayer(lineLayer)
                
                let minMaxGap = CGFloat(maxValue - minValue)
                let lineValue = Int((1-value) * minMaxGap) + Int(minValue)
                
                let textLayer = CATextLayer()
                textLayer.frame = CGRect(x: 0, y: height - 16, width: 60, height: 16)
                textLayer.foregroundColor = textColor.cgColor
                textLayer.backgroundColor = UIColor.clear.cgColor
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
                textLayer.fontSize = 11
                textLayer.string = "\(lineValue)"
                
                gridLayer.addSublayer(textLayer)
            }
        }
        
        CATransaction.commit()
    }

}
