//
//  KLMarkLayer.swift
//  KLine
//
//  Created by 123 on 2020/1/17.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit

class KLMarkLine {
    
    static func draw(at point: CGPoint, queue: KLQueue, scrollView: UIScrollView) -> (CGMutablePath, CAShapeLayer, CAShapeLayer)? {
        if point.y < portrait.padding + .boxInsetV + 1 {
            return nil
        }
        let first = queue.current.first!
        let last = queue.current.last!
        var idx = queue.totalCount - Int(ceil(point.x / portrait.unit.width))
        idx = idx > last.idx ? last.idx : idx
        let current = queue.current[idx - first.idx]
        let firstX = scrollView.contentOffset.x + scrollView.bounds.width
        let lastX = scrollView.contentOffset.x
        let currentX = scrollView.contentSize.width - CGFloat(idx + 1) * portrait.unit.width
        let isLeft = last.idx - idx > idx - first.idx
        let lineTableHeight = portrait.lineHeight + portrait.lineInsetB + portrait.lineInsetT
        let verticalBaseY = portrait.padding + lineTableHeight
        let yValuePath = String(format: "%.2f", current.top).path(font: .markLine, point: .zero)
        if verticalBaseY - yValuePath.boundingBox.maxY / 2 - .boxInsetV - 1 < point.y { return nil }
        let xValuePath = current.timeStr.path(font: .markLine, point: .zero)
        let boxBgPath = CGMutablePath()
        let path = CGMutablePath()
        let xValueRect = xValuePath.boundingBox
        let yValueRect = yValuePath.boundingBox
        let verticalMidX = currentX + (portrait.unit.line - .markLineWidth) / 2
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
            let y = verticalBaseY + (portrait.xPadding + xValueRect.maxY) / 2
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
            let y = verticalBaseY + (portrait.xPadding - boxHeight) / 2
            path.move(to: CGPoint(x: verticalMidX, y: portrait.padding))
            path.addLine(to: CGPoint(x: verticalMidX, y: y))
            let rect = CGRect(x: verticalX, y: y, width: boxWidth, height: boxHeight)
            path.addRect(rect)
            path.move(to: CGPoint(x: verticalMidX, y: y + boxHeight))
            path.addLine(to: CGPoint(x: verticalMidX, y: scrollView.bounds.height))
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
        return (path, textLayer, BGLayer())
        
    }

}
