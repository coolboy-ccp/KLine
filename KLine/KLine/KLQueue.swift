//
//  KLQueue.swift
//  KLine
//
//  Created by 123 on 2020/1/7.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit



class KLQueue {
    var bigMA: KLData = .zero
    var smallMA: KLData = .huge
    var bigVol: CGFloat = 0
    var smallVol: CGFloat = 0
    var maRatio: CGFloat = 0
    
    var current: [KLData] = []
    private var total: [KLData] = []
    private var limitNum: Int = 0
    private var size: CGSize = .zero
    
    init(source: [KLData]) {
        self.total = source
    }
    
    func update(limitNum: Int, size: CGSize) {
        self.limitNum = limitNum
        self.size = size
    }
    
    private func setup() {
        current = []
        bigVol = 0
        bigMA = .zero
        smallVol = .greatestFiniteMagnitude
        smallMA = .huge
    }
    
    func extract(from idx: Int) {
        setup()
        for i in (idx ..< limitNum + idx) {
            let data = total[i]
            extractBigger(data)
            extractSmaller(data)
            current.append(data)
        }
    }
    
    private func extractBigger(_ data: KLData) {
        if data.top > bigMA.top {
            bigMA = data
        }
        if data.vol > bigVol {
            bigVol = data.vol
        }
    }
    
    private func extractSmaller(_ data: KLData) {
        if data.bottom < smallMA.bottom {
            smallMA = data
        }
        if data.vol < smallVol {
            smallVol = data.vol
        }
    }
    
    var nodes: [KLNode] {
        maRatio = kl.vertical.maHeight / (bigMA.top - smallMA.bottom)
        let volRatio: CGFloat = (kl.vertical.volHeight - kl.vertical.volBase) / (bigVol - smallVol)
        return current.map {
            return KLNode(data: $0, width: size.width, maRatio: maRatio, volRatio: volRatio, maBottom: smallMA.bottom, volBottom: smallVol, maTop: bigMA.top, start: current.first!.idx, end: current.last!.idx)
        }
    }
            
    static let empty = KLQueue(source: [])

}
