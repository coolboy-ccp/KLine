//
//  KLineChart.swift
//  KLine
//
//  Created by 123 on 2020/1/6.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit


class KLineTable: UIView {
    
    private var top: KLData!
    private var bottom: KLData!
    private var first: KLData!
    private var last: KLData!
    
    private var maRatio: CGFloat = 0
    
    private var yPoints: [CGFloat] = []
    private var xLayer: CAShapeLayer?
    private var yLayer: CAShapeLayer?
    
    private var yNoChange: Bool = false
    
    
    //table-------------------------
    private func drawTable() {
        let paths = CGMutablePath()
        // MA
        let maPath = CGMutablePath()
        maPath.addRect(CGRect(x: 0, y: kl.vertical.topMargin, width: frame.width, height: kl.vertical.maTableHeight))
        for i in (1 ... .numberOfGridLines) {
            let path = CGMutablePath()
            let y = kl.vertical.maTableHeight / CGFloat((.numberOfGridLines + 1)) * CGFloat(i) + kl.vertical.topMargin
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: frame.width, y: y))
            maPath.addPath(path.copy(dashingWithPhase: 0, lengths: [10, 3]))
            paths.addPath(maPath)
            yPoints.append(y)
        }
        yPoints.append(kl.vertical.maTableHeight + kl.vertical.topMargin)
        
        // VOL
        let volPath = CGMutablePath()
        volPath.addRect(CGRect(x: 0, y: frame.height - kl.vertical.volTableHeight, width: frame.width, height: kl.vertical.volTableHeight))
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
        let topYValue = (kl.vertical.maHeight + kl.vertical.topInset) / maRatio + bottom.bottom
        let bottomYValue = bottom.bottom - kl.vertical.bottomInset / maRatio
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
            let subPath = CGMutablePath.path(text: yValues[idx], font: .coordinateY, extPoint: CGPoint(x: 2, y: -point + 2))
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
        let extPoint = CGPoint(x: 0, y: -(kl.vertical.maTableHeight + kl.vertical.padding + kl.vertical.topMargin))
        let pth = CGMutablePath.path(text: last.timeStr, font: .coordinateX, extPoint: extPoint)
        let pth1 = CGMutablePath.path(text: first.timeStr, font: .coordinateX, extPoint: CGPoint(x: frame.width - pth.boundingBox.width - 5, y: extPoint.y))
        pth.addPath(pth1)
        let ext = (kl.vertical.padding - pth.boundingBox.height) / 2.0
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

extension CAShapeLayer {
    convenience init(at point: CGPoint, color: UIColor) {
        self.init()
        self.fillColor = color.cgColor
        self.position = point
        self.isGeometryFlipped = true
    }
}

extension CGMutablePath {
    /*
       * extPoint.y需要取负值，因为镜像
       */
      static func path(text: String, font: UIFont, extPoint: CGPoint) -> CGMutablePath {
          let attr = NSAttributedString(string: text, attributes: [.font : font])
          let line = CTLineCreateWithAttributedString(attr)
          let runs = CTLineGetGlyphRuns(line) as! [CTRun]
          let letters = CGMutablePath()
          for run in runs {
              let attr = CTRunGetAttributes(run) as NSDictionary
              let font = attr[kCTFontAttributeName as String] as! CTFont
              let count = CTRunGetGlyphCount(run)
              var paths = [CGPath]()
              for index in 0 ..< count
              {
                  let range = CFRangeMake(index, 1)
                  var glyph = CGGlyph()
                  CTRunGetGlyphs(run, range, &glyph)
                  var position = CGPoint()
                  CTRunGetPositions(run, range, &position)
                  if let letterPath = CTFontCreatePathForGlyph(font, glyph, nil) {
                      let transform = CGAffineTransform(translationX: position.x + extPoint.x, y: position.y + extPoint.y)
                      letters.addPath(letterPath, transform: transform)
                      paths.append(letterPath)
                  }
              }
          }
          return letters
      }
}
