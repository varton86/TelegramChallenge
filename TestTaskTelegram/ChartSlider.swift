//
//  ChartSlider.swift
//  TestTaskTelegram
//
//  Created by Oleg Soloviev on 13.03.2019.
//  Copyright © 2019 varton. All rights reserved.
//

import UIKit

final class ChartSlider: UIControl {
    
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    
    var lowerValue: CGFloat = 0.35 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var upperValue: CGFloat = 0.65 {
        didSet {
            updateLayerFrames()
        }
    }

    var dayChartMode = true {
        didSet {
            changeImages()
            updateLayerFrames()
        }
    }
    
    private let minimumValue: CGFloat = 0
    private let maximumValue: CGFloat = 1
    private var previousLocation = CGPoint()

    private let lowerBoxImageView: CALayer = CALayer()
    private let upperBoxImageView: CALayer = CALayer()

    private let middleThumbImageView: CALayer = CALayer()
    private var middleThumbImageViewIsHighlighted = false
    
    private let lowerThumbImageView: CALayer = CALayer()
    private var lowerThumbImageViewIsHighlighted = false
    
    private let upperThumbImageView: CALayer = CALayer()
    private var upperThumbImageViewIsHighlighted = false

    private enum DayModeImages {
        static let lowerThumbImage = UIImage(named: "leftSlider")!
        static let middleThumbImage = UIImage(named: "sliderBox")!
        static let upperThumbImage = UIImage(named: "rightSlider")!
        static let boxThumbImage = UIImage(named: "Box")!
    }
    
    private enum NightModeImages {
        static let lowerThumbImage = UIImage(named: "nightLeftSlider")!
        static let middleThumbImage = UIImage(named: "nightSliderBox")!
        static let upperThumbImage = UIImage(named: "nightRightSlider")!
        static let boxThumbImage = UIImage(named: "nightBox")!
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        lowerBoxImageView.contents = DayModeImages.boxThumbImage.cgImage
        layer.addSublayer(lowerBoxImageView)

        upperBoxImageView.contents = DayModeImages.boxThumbImage.cgImage
        layer.addSublayer(upperBoxImageView)

        middleThumbImageView.contents = DayModeImages.middleThumbImage.cgImage
        layer.addSublayer(middleThumbImageView)

        lowerThumbImageView.contents = DayModeImages.lowerThumbImage.cgImage
        layer.addSublayer(lowerThumbImageView)

        upperThumbImageView.contents = DayModeImages.upperThumbImage.cgImage
        layer.addSublayer(upperThumbImageView)

    }    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)

        let lowerUpperSize = CGSize(width: DayModeImages.lowerThumbImage.size.width, height: bounds.height + 4.0)
        lowerThumbImageView.frame = CGRect(origin: thumbOriginForValue(lowerValue), size: lowerUpperSize)
        upperThumbImageView.frame = CGRect(origin: thumbOriginForValue(upperValue), size: lowerUpperSize)
        let middleSize = CGSize(width: upperThumbImageView.frame.minX - lowerThumbImageView.frame.maxX, height: bounds.height + 4.0)
        middleThumbImageView.frame = CGRect(origin: CGPoint(x: lowerThumbImageView.frame.maxX, y: -2), size: middleSize)
                

        if lowerThumbImageView.frame.minX < 0 {
            lowerBoxImageView.frame = CGRect.zero
        } else {
            let lowerBoxSize = CGSize(width: lowerThumbImageView.frame.minX, height: bounds.height)
            lowerBoxImageView.frame = CGRect(origin: CGPoint.zero, size: lowerBoxSize)
        }

        if upperThumbImageView.frame.maxX > bounds.width {
            upperBoxImageView.frame = CGRect.zero
        } else {
            let upperBoxSize = CGSize(width: bounds.width - upperThumbImageView.frame.maxX, height: bounds.height)
            upperBoxImageView.frame = CGRect(origin: CGPoint(x: min(bounds.width, upperThumbImageView.frame.maxX), y: 0), size: upperBoxSize)
        }
        
        CATransaction.commit()
    }

    private func thumbOriginForValue(_ value: CGFloat) -> CGPoint {
        let x = positionForValue(value) - DayModeImages.lowerThumbImage.size.width / 2.0
        return CGPoint(x: x, y: -2)
    }

    private func positionForValue(_ value: CGFloat) -> CGFloat {
        return bounds.width * value
    }
    
    private func changeImages() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if dayChartMode {
            lowerBoxImageView.contents = DayModeImages.boxThumbImage.cgImage
            upperBoxImageView.contents = DayModeImages.boxThumbImage.cgImage
            middleThumbImageView.contents = DayModeImages.middleThumbImage.cgImage
            lowerThumbImageView.contents = DayModeImages.lowerThumbImage.cgImage
            upperThumbImageView.contents = DayModeImages.upperThumbImage.cgImage
        } else {
            lowerBoxImageView.contents = NightModeImages.boxThumbImage.cgImage
            upperBoxImageView.contents = NightModeImages.boxThumbImage.cgImage
            middleThumbImageView.contents = NightModeImages.middleThumbImage.cgImage
            lowerThumbImageView.contents = NightModeImages.lowerThumbImage.cgImage
            upperThumbImageView.contents = NightModeImages.upperThumbImage.cgImage
        }
        CATransaction.commit()
    }

}

extension ChartSlider {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)

        if lowerThumbImageView.frame.contains(previousLocation) {
            lowerThumbImageViewIsHighlighted = true
        } else if upperThumbImageView.frame.contains(previousLocation) {
            upperThumbImageViewIsHighlighted = true
        } else if middleThumbImageView.frame.contains(previousLocation) {
            middleThumbImageViewIsHighlighted = true
        }

        return lowerThumbImageViewIsHighlighted || upperThumbImageViewIsHighlighted || middleThumbImageViewIsHighlighted
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        let deltaLocation = location.x - previousLocation.x
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / bounds.width

        previousLocation = location
        
        let gap: CGFloat = 0.1
        if lowerThumbImageViewIsHighlighted {
            lowerValue += deltaValue
            lowerValue = boundValue(lowerValue, toLowerValue: minimumValue, upperValue: upperValue - gap)
        } else if upperThumbImageViewIsHighlighted {
            upperValue += deltaValue
            upperValue = boundValue(upperValue, toLowerValue: lowerValue + gap, upperValue: maximumValue)
        } else if middleThumbImageViewIsHighlighted {
            lowerValue += deltaValue
            lowerValue = boundValue(lowerValue, toLowerValue: minimumValue, upperValue: upperValue - gap)
            upperValue += deltaValue
            upperValue = boundValue(upperValue, toLowerValue: lowerValue + gap, upperValue: maximumValue)
        }

        sendActions(for: .valueChanged)
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        lowerThumbImageViewIsHighlighted = false
        upperThumbImageViewIsHighlighted = false
        middleThumbImageViewIsHighlighted = false
    }
    
    private func boundValue(_ value: CGFloat, toLowerValue lowerValue: CGFloat, upperValue: CGFloat) -> CGFloat {
        return min(max(value, lowerValue), upperValue)
    }
}
