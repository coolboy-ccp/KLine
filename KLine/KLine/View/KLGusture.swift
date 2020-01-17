//
//  KLGusture.swift
//  KLine
//
//  Created by 123 on 2020/1/17.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit

//gestures
private var lastScale: CGFloat = 1.0
var isZoomming: Bool = false
extension KLine {
    
    func addGestures() {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(_:)))
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        scrollView.addGestureRecognizer(pinch)
        scrollView.addGestureRecognizer(tap)
        scrollView.addGestureRecognizer(longPress)
        
    }
    
    @objc private func pinchAction(_ pinch: UIPinchGestureRecognizer) {
        if pinch.state == .began {
            lastScale = 1.0
            isZoomming = true
        }
        else if pinch.state == .ended {
            isZoomming = false
        }
        var scale: CGFloat = 0
        if pinch.scale < 1.0 && portrait.unit <= portrait.unitMin { return }
        if pinch.scale > 1.0 && portrait.unit >= portrait.unitMax { return }
        scale =  pinch.scale / lastScale
        portrait.unit = portrait.unit * scale
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
        guard let pathLayer = KLMarkLine.draw(at: point, queue: queue, scrollView: scrollView) else {
            return
        }
        initMarkLine()
        markLineLayer?.path = pathLayer.0
        markLineLayer?.addSublayer(pathLayer.2)
        markLineLayer?.addSublayer(pathLayer.1)
        
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
    
    func removeMarkLine() {
        markLineLayer?.removeFromSuperlayer()
        markLineLayer = nil
    }
}
