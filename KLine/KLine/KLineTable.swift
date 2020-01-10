//
//  KLineChart.swift
//  KLine
//
//  Created by 123 on 2020/1/6.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit


extension CGPath {
    static func path(text: String, font: UIFont) -> CGMutablePath {
        let attr = NSAttributedString(string: text, attributes: [.font : font])
        let line = CTLineCreateWithAttributedString(attr)
        let runs = CTLineGetGlyphRuns(line) as! [CTRun]
        let letters = CGMutablePath()
        for run in runs {
            
            let attr = CTRunGetAttributes(run) as NSDictionary
            let font = attr[kCTFontAttributeName as String] as! CTFont
            let count = CTRunGetGlyphCount(run)
            for index in 0 ..< count
            {
                let range = CFRangeMake(index, 1)
                var glyph = CGGlyph()
                CTRunGetGlyphs(run, range, &glyph)
                var position = CGPoint()
                CTRunGetPositions(run, range, &position)
                let letterPath = CTFontCreatePathForGlyph(font, glyph, nil)
                let transform = CGAffineTransform(translationX: position.x + 3, y: 3 + position.y)
                letters.addPath(letterPath!, transform: transform)
            }
        }
        return letters
    }
}


class KLineTable: UIView {

    var top: KLData? {
        didSet {
            
        }
    }
    
    var bottom: KLData? {
        didSet {
            
        }
    }
    
    var currentNode: KLNode? {
        didSet {
            
        }
    }
    
    private var firstNode: KLNode? {
        didSet {
            drawYPoints()
        }
    }
    
    private var lastNode: KLNode? {
        didSet {
            
        }
    }
    
    private var yPoints: [CGPoint] = []
    private var yPointsLayer: [Int : CAShapeLayer] = [:]
    private var xPointsLayer: [CAShapeLayer] = []
    
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
            yPoints.append(CGPoint(x: 0, y: y))
        }
        yPoints.append(CGPoint(x: 0, y: kl.vertical.maTableHeight + kl.vertical.topMargin))
        
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
    
    private func label() -> UILabel {
        let label = UILabel()
        label.textAlignment = .left
        label.sizeToFit()
        return label
    }
    
    private func drawYPoints() {
        if firstNode == nil { return }
        for (idx, point) in yPoints.enumerated() {
            if let layer = yPointsLayer[idx] {
                layer.path = CGPath.path(text: firstNode!.yCoordinates[idx], font: .coordinateY)
                continue
            }
            let textLayer = layer(at: point, color: .coordinateY)
            textLayer.path = CGPath.path(text: firstNode!.yCoordinates[idx], font: .coordinateY)
            self.layer.addSublayer(textLayer)
            yPointsLayer[idx] = textLayer
        }
        
    }
    
    private func layer(at point: CGPoint, color: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = color.cgColor
        layer.position = point
        layer.isGeometryFlipped = true
        return layer
    }
    
    private func drawXPoints() {
        if firstNode == nil || lastNode == nil { return }
        if xPointsLayer.count > 0 {
          //  xPointsLayer.first?.path = CGPath.path(text: firstNode!.tim, font: <#T##UIFont#>)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        drawTable()
    }
    
    func update(firstNode: KLNode?, lastNode: KLNode?) {
        self.firstNode = firstNode
        self.lastNode = lastNode
    }
    
    func update(frame: CGRect) {
        self.frame = frame
        drawTable()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
