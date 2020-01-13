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
        kl = KLLayout.portrait(height: frame.height)
        queue = KLQueue(source: datasource)
        totalNodesCount = datasource.count
        addSubview(table)
        addSubview(scrollView)
        addGestures()
        reload()
        draw()
        
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
    
//    func update(frame: CGRect) {
//        self.frame = frame
//        kl = KLLayout.portrait(height: frame.height)
//        scrollView.frame = bounds
//        table = KLineTable(frame: bounds)
//        reload()
//        draw()
//    }
//    
//    func update(datasource: [KLData]) {
//        queue = KLQueue(source: datasource)
//        totalNodesCount = datasource.count
//        reload()
//        draw()
//    }
    
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
        let point = tap.location(in: scrollView)
        print(point)
        
    }
    
    @objc private func longPress(_ lp: UILongPressGestureRecognizer) {
        
    }
}

extension KLineView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isZoomming { return }
        let idx = Int((scrollView.contentSize.width - scrollView.contentOffset.x - scrollView.frame.width) / kl.unit.width)
        if currentIdx == idx { return }
        currentIdx = idx
        draw()
    }
    
}
