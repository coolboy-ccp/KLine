//
//  KLUtils.swift
//  KLine
//
//  Created by 123 on 2020/1/16.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit

extension CGPoint {
    func move(x: CGFloat = 0, y: CGFloat = 0) -> CGPoint {
        var pt = self
        pt.x = self.x + x
        pt.y = self.y + y
        return pt
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

extension String {
    func path(font: UIFont, point: CGPoint) -> CGMutablePath {
        let attr = NSAttributedString(string: self, attributes: [.font : font])
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
                    let transform = CGAffineTransform(translationX: position.x + point.x, y: position.y + point.y)
                    letters.addPath(letterPath, transform: transform)
                    paths.append(letterPath)
                }
            }
        }
        return letters
    }
}
