//
//  KLineChart.swift
//  KLine
//
//  Created by 123 on 2020/1/6.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit


class KLTable: UIView {
    
    private var top: KLData!
    private var bottom: KLData!
    private var first: KLData!
    private var last: KLData!
    private var maRatio: CGFloat = 0
    private var yPoints: [CGFloat] = []
    private var xLayer: CAShapeLayer?
    private var yLayer: CAShapeLayer?
    private var yNoChange: Bool = false
    
    private let lineTableHeight = portrait.lineHeight + portrait.lineInsetB + portrait.lineInsetT
    
    //table-------------------------
    private func drawTable() {
        let paths = CGMutablePath()
        // MA
        let maPath = CGMutablePath()
        
        maPath.addRect(CGRect(x: 0, y: portrait.padding, width: frame.width, height: lineTableHeight))
        for i in (1 ... .numberOfGridLines) {
            let path = CGMutablePath()
            let y = lineTableHeight / CGFloat((.numberOfGridLines + 1)) * CGFloat(i) + portrait.padding
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: frame.width, y: y))
            maPath.addPath(path.copy(dashingWithPhase: 0, lengths: [10, 3]))
            paths.addPath(maPath)
            yPoints.append(y)
        }
        yPoints.append(lineTableHeight + portrait.padding)
        
        // VOL
        let volPath = CGMutablePath()
        
        volPath.addRect(CGRect(x: 0, y: frame.height - portrait.volHeight, width: frame.width, height: portrait.volHeight))
        paths.addPath(volPath)
        
        let tableLayer = CAShapeLayer()
        tableLayer.lineWidth = 1
        tableLayer.strokeColor = UIColor.lightGray.cgColor
        tableLayer.path = paths
        tableLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(tableLayer)
    }
    
    //y-------------------------
    private func yCoordinates() -> [String] {
        
        let topYValue = (portrait.lineHeight + portrait.lineInsetT) / maRatio + bottom.bottom
        let bottomYValue = bottom.bottom - portrait.lineInsetB / maRatio
        if Int.numberOfGridLines < 1 { return [] }
        let distance = topYValue - bottomYValue
        let padding = distance / CGFloat(Int.numberOfGridLines + 1)
        return (1 ... .numberOfGridLines).map {
            return String(format: "%.2f", topYValue - padding * CGFloat($0))
            } + [String(format: "%.2f", bottomYValue)]
    }
    
    private func drawYPoints() {
        if yNoChange { return }
        let pth = CGMutablePath()
        let yValues = yCoordinates()
        for (idx, point) in yPoints.enumerated() {
            let subPath = yValues[idx].path(font: .coordinateY, point: CGPoint(x: 2, y: -point + 2))
            pth.addPath(subPath)
        }
        if self.yLayer == nil {
            self.yLayer = CAShapeLayer(at: .zero, color: .coordinateY)
            self.layer.addSublayer(self.yLayer!)
        }
        self.yLayer?.path = pth
    }
    
    //x-------------------------
    private func drawXPoints() {
        let extPoint = CGPoint(x: 0, y: -(lineTableHeight + portrait.xPadding + portrait.padding))
        let pth = last.timeStr.path(font: .coordinateX, point: extPoint)
        let pth1 = last.timeStr.path(font: .coordinateX, point: CGPoint(x: frame.width - pth.boundingBox.width - 5, y: extPoint.y))
        pth.addPath(pth1)
        let ext = (portrait.xPadding - pth.boundingBox.height) / 2.0
        if self.xLayer == nil {
            self.xLayer = CAShapeLayer(at: CGPoint(x: 0, y: -ext), color: .coordinateX)
            self.layer.addSublayer(self.xLayer!)
            
        }
        self.xLayer?.path = pth
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        drawTable()
    }
    
    func update(first: KLData?, last: KLData?, bottom: KLData, top: KLData, maRatio: CGFloat) {
        guard let first = first, let last = last else {
            return
        }
        if let oldTop = self.top, let oldBottom = self.bottom {
            yNoChange = top.top == oldTop.top && bottom.bottom == oldBottom.bottom
        }
        self.first = first
        self.last = last
        self.top = top
        self.bottom = bottom
        self.maRatio = maRatio
        drawYPoints()
        drawXPoints()
    }
    
    func update(frame: CGRect) {
        self.frame = frame
        drawTable()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


