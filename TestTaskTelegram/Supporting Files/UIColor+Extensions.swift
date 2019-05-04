//
//  UIColor+Extensions.swift
//  TestTaskTelegram
//
//  Created by Oleg Soloviev on 11.03.2019.
//  Copyright © 2019 varton. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let hex = hex.replacingOccurrences(of: "#", with: "")
        
        guard hex.count == 6 else {
            self.init(white: 1.0, alpha: 1.0)
            return
        }
        
        self.init(
            red:   CGFloat((Int(hex, radix: 16)! >> 16) & 0xFF) / 255.0,
            green: CGFloat((Int(hex, radix: 16)! >> 8) & 0xFF) / 255.0,
            blue:  CGFloat((Int(hex, radix: 16)!) & 0xFF) / 255.0, alpha: alpha
        )
    }
}
