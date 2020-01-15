//
//  KLineView.swift
//  KLine
//
//  Created by 123 on 2020/1/6.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit

var kl = KLLayout.inital

class KLineView: UIView {
    
    private var totalNodesCount = 0
    private var queue = KLQueue.empty
    private var currentIdx = 0
    private var markLineLayer: CAShapeLayer?
    
    private lazy var openScreenButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "screenOpen"), for: .normal)
        btn.setImage(UIImage(named: "screenClose"), for: .selected)
        btn.frame = CGRect(x: self.bounds.width - 29, y: kl.vertical.maTableHeight + kl.vertical.topMargin - 24 - 5, width: 24, height: 24)
        btn.layer.cornerRadius = 12
        btn.backgroundColor = UIColor(red: 10 / 255.0, green: 110 / 255.0, blue: 225 / 255.0, alpha: 0.7)
        btn.addTarget(self, action: #selector(openScreen(sender:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scr = UIScrollView(frame: self.bounds)
        scr.bounces = false
        scr.showsHorizontalScrollIndicator = false
        scr.bouncesZoom = false
        scr.delegate = self
        scr.backgroundColor = .clear
        return scr
    }()
    
    private lazy var table: KLineTable = {
        return KLineTable(frame: bounds)
    }()
    
    private var klayers = [CAShapeLayer]() {
        didSet {
            for old in oldValue {
                old.removeFromSuperlayer()
            }
            for new in klayers {
                self.scrollView.layer.addSublayer(new)
            }
        }
    }
    
    private var numberOfNodes: Int {
        return Int(scrollView.frame.width / (kl.unit.width))
    }
        
    private var nodes: [KLNode] = [] {
        didSet {
            var layers = [CAShapeLayer]()
            for node in nodes {
                layers.append(contentsOf: KLineLayer.layers(node: node))
            }
            klayers = layers
        }
    }
    
    init(frame: CGRect, datasource: [KLData]) {
        super.init(frame: frame)
        setup(datasource: datasource)
        reload()
        draw()
    }
    
    @objc private func openScreen(sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    private func setup(datasource: [KLData]) {
        kl = KLLayout(height: bounds.height)
        queue = KLQueue(source: datasource)
        totalNodesCount = datasource.count
        addSubview(table)
        addSubview(scrollView)
        addSubview(openScreenButton)
        addGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addGestures() {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(_:)))
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        scrollView.addGestureRecognizer(pinch)
        scrollView.addGestureRecognizer(tap)
        scrollView.addGestureRecognizer(longPress)
        
    }
    
    private func reload() {
        scrollView.contentSize = CGSize(width: kl.unit.width * CGFloat(totalNodesCount), height: scrollView.frame.height)
        queue.update(limitNum: numberOfNodes, size: CGSize(width: scrollView.contentSize.width, height: scrollView.frame.height))
        scrollView.setContentOffset(CGPoint(x: scrollView.contentSize.width - scrollView.frame.width - CGFloat(currentIdx) * kl.unit.width, y: 0), animated: false)
    }
    
    private func draw() {
        queue.extract(from: currentIdx)
        nodes = queue.nodes
        table.update(first: queue.current.first, last: queue.current.last, bottom: queue.smallMA, top: queue.bigMA, maRatio: queue.maRatio)
    }
}


//gestures
private var lastScale: CGFloat = 1.0
private var isZoomming: Bool = false
extension KLineView {
    
    @objc private func pinchAction(_ pinch: UIPinchGestureRecognizer) {
        if pinch.state == .began {
            lastScale = 1.0
            isZoomming = true
        }
        else if pinch.state == .ended {
            isZoomming = false
        }
        var scale: CGFloat = 0
        if pinch.scale < 1.0 && kl.unit <= .min { return }
        if pinch.scale > 1.0 && kl.unit >= .max { return }
        scale =  pinch.scale / lastScale
        kl.unit *= scale
        lastScale = pinch.scale
        reload()
        draw()
    }
    
    @objc private func tapAction(_ tap: UITapGestureRecognizer) {
        addMarkLine(at: tap.location(in: scrollView))
    }
    
    @objc private func longPress(_ lp: UILongPressGestureRecognizer) {
        addMarkLine(at: lp.location(in: scrollView))
    }
    
    private func addMarkLine(at point: CGPoint) {
        let first = queue.current.first!
        let last = queue.current.last!
        var idx = totalNodesCount - Int(ceil(point.x / kl.unit.width))
        idx = idx > last.idx ? last.idx : idx
        let current = queue.current[idx - first.idx]
        let firstX = scrollView.contentOffset.x + bounds.width
        let lastX = scrollView.contentOffset.x
        let currentX = scrollView.contentSize.width - CGFloat(idx + 1) * kl.unit.width
        let isLeft = last.idx - idx > idx - first.idx
        let verticalBaseY = kl.vertical.topMargin + kl.vertical.maTableHeight
        
        let boxBgPath = CGMutablePath()
        let path = CGMutablePath()
        let xValuePath = current.timeStr.path(font: .markLine, point: .zero)
        let yValuePath = String(format: "%.2f", current.top).path(font: .markLine, point: .zero)
        let xValueRect = xValuePath.boundingBox
        let yValueRect = yValuePath.boundingBox
        let verticalMidX = currentX + (kl.unit.line - .markLineWidth) / 2
        var verticalX = verticalMidX - xValueRect.midX - .boxInsetH
        verticalX = verticalX < lastX + 1 ? lastX + 1 : verticalX
        verticalX = verticalX > firstX - 1 - .boxInsetH * 2 - xValueRect.maxX ? firstX - .boxInsetH * 2 - xValueRect.maxX - 1 : verticalX
        let horizontalBoxWidth = yValueRect.maxX + .boxInsetH * 2
                
        func drawYValuePath() -> CGMutablePath {
            let x = isLeft ? lastX + .boxInsetH + 1: firstX - yValueRect.width - .boxInsetH - 1
            let y = point.y + yValueRect.maxY / 2
            return yValuePath.move(offset: CGPoint(x: x, y: -y))
        }
        
        func drawXValuePath() -> CGMutablePath {
            var x = verticalX - xValueRect.midX
            x = x < lastX + 1 + .boxInsetH ? lastX + 1 + .boxInsetH : x
            x = x > firstX - 1 - .boxInsetH - xValueRect.maxX ? firstX - 1 - .boxInsetH - xValueRect.maxX: x
            let y = verticalBaseY + (kl.vertical.padding + xValueRect.maxY) / 2
            return xValuePath.move(offset: CGPoint(x: verticalX + .boxInsetH, y: -y))
        }
        
        var yValuePathRect = CGRect.zero
        func drawTextLayer() -> CAShapeLayer {
            let textPath = drawYValuePath()
            yValuePathRect = textPath.boundingBox
            textPath.addPath(drawXValuePath())
            let textLayer = CAShapeLayer(at: .zero, color: .markLine)
            textLayer.path = textPath
            return textLayer
        }

        func drawHorizontal() {
            let boxWidth = yValueRect.maxX + .boxInsetH * 2
            let boxHeight = yValueRect.maxY + .boxInsetV * 2
            let boxY = point.y - boxHeight / 2
            let x0 = isLeft ? firstX : firstX - boxWidth - 1
            let x1 = isLeft ? lastX + boxWidth + 1 : lastX
            let x2 = isLeft ? lastX + 1 : x0
            let rect = CGRect(x: x2, y: boxY, width: boxWidth, height: boxHeight)
            path.move(to: CGPoint(x: x0, y: point.y))
            path.addLine(to: CGPoint(x: x1, y: point.y))
            path.addRect(rect)
            boxBgPath.addRect(rect)
        }
        
        func drawVertical() {
            let boxWidth = xValueRect.width + .boxInsetH * 2
            let boxHeight = xValueRect.maxY + .boxInsetV * 2
            let y = verticalBaseY + (kl.vertical.padding - boxHeight) / 2
            path.move(to: CGPoint(x: verticalMidX, y: kl.vertical.topMargin))
            path.addLine(to: CGPoint(x: verticalMidX, y: y))
            let rect = CGRect(x: verticalX, y: y, width: boxWidth, height: boxHeight)
            path.addRect(rect)
            path.move(to: CGPoint(x: verticalMidX, y: y + boxHeight))
            path.addLine(to: CGPoint(x: verticalMidX, y: bounds.height))
            boxBgPath.addRect(rect)
        }
        
        func BGLayer() -> CAShapeLayer {
            let bgLayer = CAShapeLayer()
            bgLayer.fillColor = UIColor.bgColor.cgColor
            bgLayer.path = boxBgPath
            return bgLayer
        }
        
        let textLayer = drawTextLayer()
        drawHorizontal()
        drawVertical()
        initMarkLine()
        markLineLayer?.path = path
        markLineLayer?.addSublayer(BGLayer())
        markLineLayer?.addSublayer(textLayer)
    }
    
    private func initMarkLine() {
        if markLineLayer == nil {
            markLineLayer = CAShapeLayer()
            markLineLayer?.lineWidth = .markLineWidth
            markLineLayer?.strokeColor = UIColor.markLine.cgColor
            scrollView.layer.addSublayer(markLineLayer!)
            markLineLayer?.fillColor = UIColor.clear.cgColor
            return
        }
        for layer in markLineLayer!.sublayers! {
            layer.removeFromSuperlayer()
        }
    }
    
    private func removeMarkLine() {
        markLineLayer?.removeFromSuperlayer()
        markLineLayer = nil
    }    
}

extension KLineView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isZoomming { return }
        let idx = Int((scrollView.contentSize.width - scrollView.contentOffset.x - scrollView.frame.width) / kl.unit.width)
        if currentIdx == idx { return }
        currentIdx = idx
        draw()
        removeMarkLine()
    }
    
}
