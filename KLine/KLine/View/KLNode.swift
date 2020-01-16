//
//  KLineNode.swift
//  KLine
//
//  Created by 123 on 2020/1/3.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit

/////
//////


/*
 有一个用空间换时间的优化，当layer被绘制后，再次进行绘制时不从window中移除，只更新path
 */
///

class KLNode {
    
    static func layers(node: KLModel) -> [CAShapeLayer] {
        var layers = [klineLayer(node: node)]
        if let top = topLayer(node: node) {
            layers.append(top)
        }
        if let bottom = bottomLayer(node: node) {
            layers.append(bottom)
        }
        return layers
    }
    
    private static func klineLayer(node: KLModel) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = node.color.cgColor
        let path = CGMutablePath()
        path.addLines(between: node.maPoints)
        path.closeSubpath()
        path.addLines(between: node.volPoints)
        path.closeSubpath()
        layer.path = path
        return layer
    }
    
    private static func bottomLayer(node: KLModel) -> CAShapeLayer? {
        if !node.isBottom { return nil }
        let isLeft = node.idx - node.start < node.end - node.idx
        let str = isLeft ? String(format: "%.2f->", node.data.bottom) : String(format: "<-%.2f", node.data.bottom)
        let layer = CAShapeLayer(at: .zero, color: .topBottom)
        let path = str.path(font: .topBottom, point: CGPoint(x: node.bottomPoint.x - portrait.unit.width / 2, y: -node.bottomPoint.y))
        let moveX = isLeft ? -path.boundingBox.width : portrait.unit.width / 2    
        layer.path = path.move(offset: CGPoint(x: moveX, y: -path.boundingBox.height))
        return layer
    }
        
    private static func topLayer(node: KLModel) -> CAShapeLayer? {
        if !node.isTop { return nil }
        let isLeft = node.idx - node.start < node.end - node.idx
        let str = isLeft ? String(format: "%.2f->", node.data.top) : String(format: "<-%.2f", node.data.top)
        let layer = CAShapeLayer(at: .zero, color: .topBottom)
        let path = str.path(font: .topBottom, point: CGPoint(x: node.topPoint.x, y: -node.topPoint.y))
        let mPath = CGMutablePath()
        let moveX = isLeft ? -path.boundingBox.width : 0
        let transform = CGAffineTransform(translationX: moveX, y: path.boundingBox.height / 2)
        mPath.addPath(path, transform: transform)
        layer.path = mPath
        return layer
    }
}

extension CGMutablePath {
    func move(offset: CGPoint) -> CGMutablePath {
        let mPath = CGMutablePath()
        let transform = CGAffineTransform(translationX: offset.x, y: offset.y)
        mPath.addPath(self, transform: transform)
        return mPath
    }
}
