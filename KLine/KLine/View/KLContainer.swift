//
//  KLContainer.swift
//  KLine
//
//  Created by 123 on 2020/1/16.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit

class KLContainer: UIView {
    
    private var line: KLine!
    private var header: KLHeader!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(superWidth: CGFloat, y: CGFloat, data: [KLData]) {
        let height = portrait.headerPeriodHeight + portrait.padding + portrait.lineInsetT + portrait.lineHeight + portrait.lineInsetB + portrait.xPadding + portrait.volInset + portrait.volHeight
        let width = superWidth - 2 * portrait.marginH
        let rect = CGRect(x: portrait.marginH, y: y, width: width, height: height)
        self.init(frame: rect)
        header = KLHeader(supWidth: width)
        
        line = KLine(frame: CGRect(x: 0, y: portrait.headerPeriodHeight, width: width, height: height - portrait.headerPeriodHeight), datasource: data)
        self.addSubview(line)
        self.addSubview(header)
    }
}
