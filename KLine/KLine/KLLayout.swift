//
//  KLLayout.swift
//  KLine
//
//  Created by 123 on 2020/1/9.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit


struct KLLayout {
    let vertical: KLVertical
    var unit: KLUnit
    
    static let inital = KLLayout(vertical: .zero, unit: .zero)
    
    static func portrait(height: CGFloat, line: CGFloat = 5) -> KLLayout {
        let v = KLVertical.portrait(height: height)
        let unit = KLUnit.portait(line: line)
        return KLLayout(vertical: v, unit: unit)
    }
    
    static func landscape(height: CGFloat, line: CGFloat = 5) -> KLLayout {
        let v = KLVertical.landscape(height: height)
        let unit = KLUnit.landscape(line: line)
        return KLLayout(vertical: v, unit: unit)
    }
}

/*
 portrait
  ______________________________________________________________________
            topMargin                                  |
  ________________________________________             |
 |          topInset               |                   |
 |              |                  |                   |
 |              |                  |                   |
 |              |   maHeight       | maTableHeight     |
 |              |                  |                   |
 |              |                  |                   |
 |              |                  |                   |
 |          bottomInset            |                   |
  -----------------------------------------            | height
            padding                                    |
  _________________________________________            |
 |           volInset              |                   |
 |              |                  |   volTableHeight  |
 |              |   volHeight      |                   |
 |              |                  |                   |
  ---------------------------------                    |
              bottomMargin                             |
  --------------------------------------------------------------------------
 
 landscape
 
 */


struct KLVertical {
    let topMargin: CGFloat
    let bottomMargin: CGFloat
    let padding: CGFloat
    
    let topInset: CGFloat
    let bottomInset: CGFloat
    let height: CGFloat
    let maHeight: CGFloat
    let maTableHeight: CGFloat
    
    let volInset: CGFloat
    let volTableHeight: CGFloat
    let volHeight: CGFloat
    //volBase是为了保证最高值和最低值差异过大，导致低值无法显示
    let volBase: CGFloat
    
    //坐标转换
    let maYBase: CGFloat
    let volYbase: CGFloat
    
    fileprivate static let zero = KLVertical(height: 0, topMargin: 0, padding: 0, volTableHeight: 0, topInset: 0, bottomInset: 0, volInset: 0, bottomMargin: 0, volBase: 0)
    
    fileprivate static func portrait(height: CGFloat) -> KLVertical {
        return KLVertical(height: height, topMargin: 20, padding: 20, volTableHeight: 70, topInset: 20, bottomInset: 20, volInset: 20, bottomMargin: 0, volBase: 10)
    }
    
    fileprivate static func landscape(height: CGFloat) -> KLVertical {
        return KLVertical(height: height, topMargin: 0, padding: 0, volTableHeight: 0, topInset: 20, bottomInset: 20, volInset: 0, bottomMargin: 0, volBase: 0)
    }
    
    private init(height: CGFloat, topMargin: CGFloat, padding: CGFloat, volTableHeight: CGFloat, topInset: CGFloat, bottomInset: CGFloat, volInset: CGFloat, bottomMargin: CGFloat, volBase: CGFloat) {
        self.height = height
        self.topMargin = topMargin
        self.padding = padding
        self.volTableHeight = volTableHeight
        self.topInset = topInset
        self.bottomInset = bottomInset
        self.volInset = volInset
        self.bottomMargin = bottomMargin
        self.volBase = volBase
        
        self.maTableHeight = height - topMargin - padding - volTableHeight
        self.maHeight = maTableHeight - topInset - bottomInset
        self.volHeight = volTableHeight - volInset
        self.maYBase = maHeight + topMargin + topInset
        self.volYbase = maYBase + bottomInset + padding + volInset + volHeight
        
        
    }
}


/*
         | <--drew       |
        _|_             _|_
       |   |           |   |
       |   |<-padding->|   | <--line
       |_ _|           |_ _|
         |               |
         |drew           |
      |______width______|_|_|___________
                          |gap
 */

struct KLUnit {
    let drew: CGFloat
    let line: CGFloat
    let padding: CGFloat
    let width: CGFloat
    let gap: CGFloat
    
    private init(line: CGFloat, drew: CGFloat = 0.5, padding: CGFloat = 2) {
        self.line = line
        self.drew = drew
        self.padding = padding
        self.width = line + padding
        self.gap = (line - drew) / 2
    }
    
    
}

extension KLUnit: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.line < rhs.line
    }
    
    static func <= (lhs: Self, rhs: Self) -> Bool {
        return lhs.line <= rhs.line
    }
    
    static func >= (lhs: Self, rhs: Self) -> Bool {
        return lhs.line >= rhs.line
    }
}

extension KLUnit {
    static func * (lhs: Self, rhs: CGFloat) -> Self {
        return KLUnit(line: lhs.line * rhs, drew: lhs.drew, padding: lhs.padding * rhs)
    }
    
    static func *= (lhs: inout Self, rhs: CGFloat) {
        lhs = lhs * rhs
    }
}

extension KLUnit {
    static let zero = KLUnit(line: 0, drew: 0, padding: 0)
    private(set) static var max = KLUnit.zero
    private(set) static var min = KLUnit.zero
    
    fileprivate static func portait(line: CGFloat) -> Self {
        max = KLUnit(line: 15)
        min = KLUnit(line: 1)
        return KLUnit(line: line)
    }
    
    fileprivate static func landscape(line: CGFloat) -> Self {
        max = KLUnit(line: 30)
        min = KLUnit(line: 1)
        return KLUnit(line: line)
    }
}

