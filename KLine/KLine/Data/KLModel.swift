//
//  KLinePoint.swift
//  KLine
//
//  Created by 123 on 2020/1/3.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit

struct KLModel {
    
    let idx: Int
    let color: UIColor
    let isTop: Bool
    let isBottom: Bool
    let start: Int
    let end: Int
    let data: KLData
    let x: CGFloat
    
    private(set) var topPoint: CGPoint = .zero
    private(set) var bottomPoint: CGPoint = .zero
    private(set) var maPoints: [CGPoint] = []
    private(set) var volPoints: [CGPoint] = []
    
    init(data: KLData, width: CGFloat, maRatio: CGFloat, volRatio: CGFloat, maBottom: CGFloat, volBottom: CGFloat, maTop: CGFloat, start: Int, end: Int) {
        self.color = data.close >= data.open ? .KLGrow : .KLFall
        self.idx = data.idx
        self.isBottom = maBottom == data.bottom
        self.isTop = maTop == data.top
        self.start = start
        self.data = data
        self.end = end
        self.x = width - CGFloat(idx + 1) * portrait.unit.width
        self.topPoint = CGPoint(x: x + portrait.unit.gap, y: yTransfer(data.top, maBottom, maRatio))
        self.bottomPoint = CGPoint(x: x + portrait.unit.gap, y: yTransfer(data.bottom, maBottom, maRatio))
        self.volPoints = volPoints(data: data, x: x, volRatio: volRatio, volBottom: volBottom)
        self.maPoints = maPoints(data: data, maRatio: maRatio, maBottom: maBottom)
    }
    
    
    private func yTransfer(_ value: CGFloat, _ maBottom: CGFloat, _ maRatio: CGFloat) -> CGFloat {
        return portrait.padding + portrait.lineInsetT + portrait.lineHeight - (value - maBottom) * maRatio
    }
    
    private func maPoints(data: KLData, maRatio: CGFloat, maBottom: CGFloat) -> [CGPoint] {
        let open = CGPoint(x: x, y: yTransfer(data.open, maBottom, maRatio))
        let closeTmp = CGPoint(x: x, y: yTransfer(data.close, maBottom, maRatio))
        let close = data.open == data.close ? CGPoint(x: closeTmp.x, y: closeTmp.y + 0.5) : closeTmp
        
        let openPt = close.y > open.y ? open : close
        let closePT = close.y > open.y ? close : open
        return [
            openPt,
            openPt.move(x: portrait.unit.gap),
            topPoint,
            topPoint.move(x: portrait.unit.drew),
            openPt.move(x: portrait.unit.drew + portrait.unit.gap),
            openPt.move(x: portrait.unit.line),
            closePT.move(x: portrait.unit.line),
            closePT.move(x: portrait.unit.drew + portrait.unit.gap),
            bottomPoint.move(x: portrait.unit.drew),
            bottomPoint,
            closePT.move(x: portrait.unit.gap),
            closePT,
        ]
    }
    
    private func volPoints(data: KLData, x: CGFloat, volRatio: CGFloat, volBottom: CGFloat) -> [CGPoint] {
        //maYBase + bottomInset + padding + volInset + volHeight
        let yBase = portrait.padding + portrait.lineInsetT + portrait.lineHeight + portrait.lineInsetB + portrait.xPadding + portrait.volInset + portrait.volHeight
        let vol = CGPoint(x: x, y: yBase - (data.vol - volBottom) * volRatio)
        return [
            vol,
            vol.move(x: portrait.unit.line),
            vol.move(x: portrait.unit.line, y: yBase - vol.y),
            vol.move(y: yBase - vol.y)
        ]
    }
}

struct VolNode {
    let idx: Int
    let color: UIColor
    let vol: CGFloat
}



