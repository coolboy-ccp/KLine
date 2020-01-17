//
//  KLine.swift
//  KLine
//
//  Created by 123 on 2020/1/16.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit

class KLine: UIView {
    
    private var totalNodesCount = 0
    private(set) var queue = KLQueue.empty
    private var currentIdx = 0
    var markLineLayer: CAShapeLayer?
    
    private let lineTableHeight = portrait.lineHeight + portrait.lineInsetB + portrait.lineInsetT
    
    private lazy var openScreenButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "screenOpen"), for: .normal)
        btn.setImage(UIImage(named: "screenClose"), for: .selected)
        btn.frame = CGRect(x: self.bounds.width - 29, y: lineTableHeight + portrait.padding - 24 - 5, width: 24, height: 24)
        btn.layer.cornerRadius = 12
        btn.backgroundColor = UIColor(red: 10 / 255.0, green: 110 / 255.0, blue: 225 / 255.0, alpha: 0.7)
        btn.addTarget(self, action: #selector(openScreen(sender:)), for: .touchUpInside)
        return btn
    }()
    
    private(set) lazy var scrollView: UIScrollView = {
        let scr = UIScrollView(frame: self.bounds)
        scr.bounces = false
        scr.showsHorizontalScrollIndicator = false
        scr.bouncesZoom = false
        scr.delegate = self
        scr.backgroundColor = .clear
        return scr
    }()
    
    private lazy var table: KLTable = {
        return KLTable(frame: bounds)
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
        return Int(scrollView.frame.width / (portrait.unit.width))
    }
    
    private var nodes: [KLModel] = [] {
        didSet {
            var layers = [CAShapeLayer]()
            for node in nodes {
                layers.append(contentsOf: KLNode.layers(node: node))
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
    
    
    
    func reload() {
        scrollView.contentSize = CGSize(width: portrait.unit.width * CGFloat(totalNodesCount), height: scrollView.frame.height)
        queue.update(currentCount: numberOfNodes, size: CGSize(width: scrollView.contentSize.width, height: scrollView.frame.height))
        scrollView.setContentOffset(CGPoint(x: scrollView.contentSize.width - scrollView.frame.width - CGFloat(currentIdx) * portrait.unit.width, y: 0), animated: false)
    }
    
    func draw() {
        queue.extract(from: currentIdx)
        nodes = queue.nodes
        table.update(first: queue.current.first, last: queue.current.last, bottom: queue.smallMA, top: queue.bigMA, maRatio: queue.maRatio)
    }
    
    
}

extension KLine: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isZoomming { return }
        let idx = Int((scrollView.contentSize.width - scrollView.contentOffset.x - scrollView.frame.width) / portrait.unit.width)
        if currentIdx == idx { return }
        currentIdx = idx
        draw()
        removeMarkLine()
    }
    
}
