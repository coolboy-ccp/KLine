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


extension CGFloat {
    func yTransfer(bottom: CGFloat, ratio: CGFloat) -> CGFloat {
        return kl.vertical.maYBase - (self - bottom) * ratio
    }
}

struct KLNode {
    
    let idx: Int
    let color: UIColor
//    let maRatio: CGFloat
//    let maBottom: CGFloat
    let isTop: Bool
    let isBottom: Bool
    let start: Int
    let end: Int
    let data: KLData
    
    private(set) var topPoint: CGPoint = .zero
    private(set) var bottomPoint: CGPoint = .zero
    private(set) var maPoints: [CGPoint] = []
    private(set) var volPoints: [CGPoint] = []
    
    init(data: KLData, width: CGFloat, maRatio: CGFloat, volRatio: CGFloat, maBottom: CGFloat, volBottom: CGFloat, maTop: CGFloat, start: Int, end: Int) {
        self.color = data.close >= data.open ? .KLGrow : .KLFall
        self.idx = data.idx
//        self.maRatio = maRatio
//        self.maBottom = maBottom
        self.isBottom = maBottom == data.bottom
        self.isTop = maTop == data.top
        self.start = start
        self.data = data
        self.end = end
        let x = width - CGFloat(idx + 1) * kl.unit.width
        self.topPoint = CGPoint(x: x + kl.unit.gap, y: yTransfer(data.top, maBottom, maRatio))
        self.bottomPoint = CGPoint(x: x + kl.unit.gap, y: yTransfer(data.bottom, maBottom, maRatio))
        self.volPoints = volPoints(data: data, x: x, volRatio: volRatio, volBottom: volBottom)
        self.maPoints = maPoints(data: data, x: x, maRatio: maRatio, maBottom: maBottom)
    }
    
    
    private func yTransfer(_ value: CGFloat, _ maBottom: CGFloat, _ maRatio: CGFloat) -> CGFloat {
        return value.yTransfer(bottom: maBottom, ratio: maRatio)
    }
    
    private func maPoints(data: KLData, x: CGFloat, maRatio: CGFloat, maBottom: CGFloat) -> [CGPoint] {
        let open = CGPoint(x: x, y: yTransfer(data.open, maBottom, maRatio))
        let closeTmp = CGPoint(x: x, y: yTransfer(data.close, maBottom, maRatio))
        let close = data.open == data.close ? CGPoint(x: closeTmp.x, y: closeTmp.y + 0.5) : closeTmp
        
        let openPt = close.y > open.y ? open : close
        let closePT = close.y > open.y ? close : open
        return [
            openPt,
            openPt.move(x: kl.unit.gap),
            topPoint,
            topPoint.move(x: kl.unit.drew),
            openPt.move(x: kl.unit.drew + kl.unit.gap),
            openPt.move(x: kl.unit.line),
            closePT.move(x: kl.unit.line),
            closePT.move(x: kl.unit.drew + kl.unit.gap),
            bottomPoint.move(x: kl.unit.drew),
            bottomPoint,
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
}

struct VolNode {
    let idx: Int
    let color: UIColor
    let vol: CGFloat
}



