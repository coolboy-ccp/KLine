//
//  KLinePoint.swift
//  KLine
//
//  Created by 123 on 2020/1/3.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit

extension CGPoint {
    func move(x: CGFloat = 0, y: CGFloat = 0) -> CGPoint {
        var pt = self
        pt.x = self.x + x
        pt.y = self.y + y
        return pt
    }
}


struct KLNode {
    
    let idx: Int
    let color: UIColor
    let time: String
    
    private(set) var maPoints: [CGPoint] = []
    private(set) var volPoints: [CGPoint] = []
    private(set) var yCoordinates: [String] = []
    
    
    init(data: KLData, width: CGFloat, maRatio: CGFloat, volRatio: CGFloat, maBottom: CGFloat, volBottom: CGFloat) {
        self.color = data.close >= data.open ? .KLGrow : .KLFall
        self.idx = data.idx
        let x = width - CGFloat(idx + 1) * kl.unit.width
        self.time = DateFormatter.coordinateX.string(from: Date(timeIntervalSince1970: TimeInterval(data.time)))
        self.volPoints = volPoints(data: data, x: x, volRatio: volRatio, volBottom: volBottom)
        self.maPoints = maPoints(data: data, x: x, maRatio: maRatio, maBottom: maBottom)
        self.yCoordinates = yCoordinates(maRatio: maRatio, maBottom: maBottom)
    }
    
    private func maPoints(data: KLData, x: CGFloat, maRatio: CGFloat, maBottom: CGFloat) -> [CGPoint] {
        let open = CGPoint(x: x, y: kl.vertical.maYBase - (data.open - maBottom) * maRatio)
        let high = CGPoint(x: x + kl.unit.gap, y: kl.vertical.maYBase - (data.top - maBottom) * maRatio)
        let low = CGPoint(x: x + kl.unit.gap, y: kl.vertical.maYBase - (data.bottom - maBottom) * maRatio)
        let closeTmp = CGPoint(x: x, y: kl.vertical.maYBase - (data.close - maBottom) * maRatio)
        let close = data.open == data.close ? CGPoint(x: closeTmp.x, y: closeTmp.y + 0.5) : closeTmp
        
        let openPt = close.y > open.y ? open : close
        let closePT = close.y > open.y ? close : open
        return [
            openPt,
            openPt.move(x: kl.unit.gap),
            high,
            high.move(x: kl.unit.drew),
            openPt.move(x: kl.unit.drew + kl.unit.gap),
            openPt.move(x: kl.unit.line),
            closePT.move(x: kl.unit.line),
            closePT.move(x: kl.unit.drew + kl.unit.gap),
            low.move(x: kl.unit.drew),
            low,
            closePT.move(x: kl.unit.gap),
            closePT,
        ]
    }
    
    private func volPoints(data: KLData, x: CGFloat, volRatio: CGFloat, volBottom: CGFloat) -> [CGPoint] {
        let vol = CGPoint(x: x, y: kl.vertical.volYbase - (data.vol - volBottom) * volRatio - kl.vertical.volBase)
        return [
            vol,
            vol.move(x: kl.unit.line),
            vol.move(x: kl.unit.line, y: kl.vertical.volYbase - vol.y),
            vol.move(y: kl.vertical.volYbase - vol.y)
        ]
    }
    
    private func yCoordinates(maRatio: CGFloat, maBottom: CGFloat) -> [String] {
        let topYValue = (kl.vertical.maHeight + kl.vertical.topInset) / maRatio + maBottom
        let bottomYValue = maBottom - kl.vertical.bottomInset / maRatio
        if Int.numberOfGridLines < 1 { return [] }
        let distance = topYValue - bottomYValue
        let padding = distance / CGFloat(Int.numberOfGridLines + 1)
        return (1 ... .numberOfGridLines).map {
            return String(format: "%.2f", topYValue - padding * CGFloat($0))
        } + [String(format: "%.2f", bottomYValue)]
    }
}

struct VolNode {
    let idx: Int
    let color: UIColor
    let vol: CGFloat
}



