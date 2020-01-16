//
//  KLConfig.swift
//  KLine
//
//  Created by 123 on 2020/1/7.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit

/*
  ————————————————————————
 |                        |
 |                        |
 |     one grid line      |
 |-- -- -- -- -- -- -- ---|
 |                        |
 |                        |
 |                        |
 |                        |
  ————————————————————————
 */

extension Int {
    static let numberOfGridLines = 3
}

extension UIColor {
    //只考虑六位数
    convenience init(hex: String) {
        var str = hex as NSString
        if hex.hasPrefix("#") {
            str = str.substring(from: 1) as NSString
        }
        else if hex.hasPrefix("0X") {
            str = str.substring(from: 2) as NSString
        }
        var rgb: [CGFloat] = [0, 0, 0]
        rgb = (0 ... 2).map {
            return CGFloat(Int(str.substring(with: NSRange(location: $0 * 2, length: 2)), radix: 16) ?? 0) / 255.0
        }
        self.init(red: rgb[0], green: rgb[1], blue: rgb[2], alpha: 1.0)
    }
    
    static let KLGrow = UIColor(hex: "22BA24")
    static let KLFall = UIColor(hex: "EE2323")
    static let KLMA1 = UIColor.purple
    static let KLMA2 = UIColor.orange
    static let KLMA3 = UIColor.blue
    static let coordinateY = UIColor.gray
    static let coordinateX = UIColor.gray
    static let topBottom = UIColor.black
    static let markLine = UIColor.red
    static let bgColor = UIColor.white
    static let headerNormal = UIColor.black
    static let headerSelected = UIColor.blue
    static let headerTitleBG = UIColor.white
    static let headerStatusBar = UIColor.blue
}

extension UIFont {
    static let coordinateY = UIFont.systemFont(ofSize: 10)
    static let coordinateX = UIFont.systemFont(ofSize: 12)
    static let topBottom = UIFont.systemFont(ofSize: 10)
    static let markLine = UIFont.systemFont(ofSize: 10)
    static let header = UIFont.systemFont(ofSize: 14)

}

extension CGFloat {
    static let markLineWidth: CGFloat = 0.8
    static let boxInsetH: CGFloat = 2
    static let boxInsetV: CGFloat = 3
    static let headerStatusBarHeight: CGFloat = 2
    static let headerTitleHeight: CGFloat = 35
}

extension DateFormatter {
    
    static let coordinateX = DateFormatter(format: "yyyy/MM/dd HH:mm")
    
    convenience init(format: String) {
        self.init()
        self.dateFormat = format
    }
}

enum KLHeaderTitle: String, CaseIterable {
    case min5 = "5分"
    case min15 = "15分"
    case min30 = "30分"
    case hour1 = "1小时"
    case hour6 = "6小时"
    case day1 = "1天"
    case quota = "指标"
}

