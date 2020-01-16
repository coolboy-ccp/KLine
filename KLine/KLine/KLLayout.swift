//
//  KLLayout.swift
//  KLine
//
//  Created by 123 on 2020/1/9.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit

var portrait = KLPortrait()
var landscape = KLLandscape()

struct KLPortrait: KLPortraitConvertible {}
struct KLLandscape: KLLandscapeConvertible {}

public protocol KLLayoutConvertible {
    var headerTitleHeight: CGFloat { get }
    var padding: CGFloat { get }
    var lineInsetT: CGFloat { get }
    var lineHeight: CGFloat { get }
    var lineInsetB: CGFloat { get }
    var xPadding: CGFloat { get }
    var volInset: CGFloat { get }
    var volHeight: CGFloat { get }
    var marginH: CGFloat { get }
    var unit: KLUnit { set get }
    var unitMax: KLUnit { get }
    var unitMin: KLUnit { get }
}


/*
 _________________________________
 |                                 |
 |         headerTitleHeight       |
 |_________________________________|
 padding
 _________________________________
 |          lineInsetT             |
 |              |                  |
 |              |                  |
 |          lineHeight             |
 |              |                  |
 |              |                  |
 |          lineInsetB             |
 ---------------------------------
 xPadding
 _________________________________
 |           volInset              |
 |              |                  |
 |           volHeight             |
 |              |                  |
 ---------------------------------
 
 -----|----------------------------|------marginH----|
 
 */
public protocol KLPortraitConvertible: KLLayoutConvertible {}


private var unitPortrait = KLUnit(line: 5)
public extension KLPortraitConvertible {

    var headerTitleHeight: CGFloat {
        return 35
    }
    
    var padding: CGFloat {
        return 20
    }
    
    var lineInsetT: CGFloat {
        return 20
    }
    
    var lineHeight: CGFloat {
        return 250
    }
    
    var lineInsetB: CGFloat {
        return 20
    }
    
    var xPadding: CGFloat {
        return 20
    }
    
    var volInset: CGFloat {
        return 20
    }
    
    var volHeight: CGFloat {
        return 70
    }
    
    var marginH: CGFloat {
        return 10
    }
    
    var unit: KLUnit {
        set {
            unitPortrait = newValue
        }
        get {
            return unitPortrait
        }
    }
    
    var unitMax: KLUnit {
        return KLUnit(line: 15)
    }
    
    var unitMin: KLUnit {
        return KLUnit(line: 1)
    }
}

public protocol KLLandscapeConvertible: KLLayoutConvertible {}

private var unitLandscape = KLUnit(line: 10)

public extension KLLandscapeConvertible {
    var headerTitleHeight: CGFloat {
        return 35
    }
    
    var padding: CGFloat {
        return 20
    }
    
    var lineInsetT: CGFloat {
        return 20
    }
    
    var lineHeight: CGFloat {
        return 250
    }
    
    var lineInsetB: CGFloat {
        return 20
    }
    
    var xPadding: CGFloat {
        return 20
    }
    
    var volInset: CGFloat {
        return 20
    }
    
    var volHeight: CGFloat {
        return 70
    }
    
    var marginH: CGFloat {
        return 10
    }
    
    var unit: KLUnit {
        set {
            unitLandscape = newValue
        }
        get {
            return unitLandscape
        }
    }
    
    var unitMax: KLUnit {
        return KLUnit(line: 30)
    }
    
    var unitMin: KLUnit {
        return KLUnit(line: 2)
    }
}

/*
         | <--drew       |
        _|_             _|_
       |   |           |   |
       |   |<-padding->|   | <--line
       |_ _|           |_ _|
         |               |
         |               |
      |______width_____|_|_|___________
                          |gap
 */

public struct KLUnit {
    let drew: CGFloat
    let line: CGFloat
    let padding: CGFloat
    let width: CGFloat
    let gap: CGFloat
    
    init(line: CGFloat, drew: CGFloat = 0.5, padding: CGFloat = 2) {
        self.line = line
        self.drew = drew
        self.padding = padding
        self.width = line + padding
        self.gap = (line - drew) / 2
    }
}

extension KLUnit: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.line < rhs.line
    }
    
    public static func <= (lhs: Self, rhs: Self) -> Bool {
        return lhs.line <= rhs.line
    }
    
    public static func >= (lhs: Self, rhs: Self) -> Bool {
        return lhs.line >= rhs.line
    }
}

extension KLUnit {
    public static func * (lhs: Self, rhs: CGFloat) -> Self {
        return KLUnit(line: lhs.line * rhs, drew: lhs.drew, padding: lhs.padding * rhs)
    }
    
    public static func *= (lhs: inout Self, rhs: CGFloat) {
        lhs = lhs * rhs
    }
}


