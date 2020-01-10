//
//  KLineNode.swift
//  KLine
//
//  Created by 123 on 2020/1/3.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit

class KLineLayer: CAShapeLayer {
    
    private let node: KLNode
    
    init(node: KLNode) {
        self.node = node
        super.init()
//        self.fillColor = node.color.cgColor
//        self.path = path()
    }
    
//    static func twoLayer(node: KLNode) -> [KLineLayer] {
//        let layer1 = KLineLayer.init(node: node)
//        let path1 = UIBezierPath()
//        path1.move(to: node.open)
//        path1.addLine(to: node.close)
//        path1.lineWidth = 5
//        layer1.strokeColor = node.color.cgColor
//        layer1.path = path1.cgPath
//        
//        let layer2 = KLineLayer.init(node: node)
//        let path2 = UIBezierPath()
//        path2.move(to: node.high)
//        path2.addLine(to: node.low)
//        path2.lineWidth = 0.8
//        layer2.strokeColor = node.color.cgColor
//        layer2.path = path2.cgPath
//
//        return [layer1, layer2]
//    }
    
    static func oneLayer(node: KLNode) -> KLineLayer {
        let layer = KLineLayer(node: node)
        layer.fillColor = node.color.cgColor
        layer.path = layer.path()
        return layer
    }
    
    private func path() -> CGMutablePath {
        let path = CGMutablePath()
        path.addLines(between: node.maPoints)
        path.closeSubpath()
        path.addLines(between: node.volPoints)
        path.closeSubpath()
        return path
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
