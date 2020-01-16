//
//  KLSource.swift
//  KLine
//
//  Created by 123 on 2020/1/15.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit


struct KLConfig {
    private(set) var macd_long: CGFloat = 26
    private(set) var macd_short: CGFloat = 12
    private(set) var macd_Nine: CGFloat = 9
    private(set) var rsi_p1: Int = 6
    private(set) var rsi_p2: Int = 12
    private(set) var rsi_p3: Int = 24
    private(set) var rsi_df: CGFloat = 100
    private(set) var boll_param: CGFloat = 2
    private(set) var boll_period: Int = 20
    private(set) var wr_p: Int = 9
    private(set) var kdj_p: Int = 9
    private(set) var kdj_p2: CGFloat = 3
    private(set) var kdj_p3: CGFloat = 3
    private(set) var MA_p7: Int = 7
    private(set) var MA_p30: Int = 30
    private(set) var volumn_p1: Int = 5
    private(set) var volumn_p2: Int = 10
    private(set) var volumn_p3: Int = 0
    private(set) var amount_p1: Int = 5
    private(set) var amount_p2: Int = 10
    private(set) var amount_p3: Int = 0
    
    
    static let `default` = KLConfig()
    
}

struct KLBoll {
    let ma: CGFloat
    let up: CGFloat
    let down: CGFloat
    
    static let zero = KLBoll(ma: 0, up: 0, down: 0)
}

struct KLMacd {
    let dif: CGFloat
    let dea: CGFloat
    let macd: CGFloat
    let longEma: CGFloat
    let shortEma: CGFloat
    
    static let zero = KLMacd(dif: 0, dea: 0, macd: 0, longEma: 0, shortEma: 0)
}

struct KLKDJ {
    let k: CGFloat
    let d: CGFloat
    let j: CGFloat
    
    static let zero = KLKDJ(k: 0, d: 0, j: 0)
}

class KLData {
    let time: CGFloat
    let open: CGFloat
    let close: CGFloat
    let top: CGFloat
    let bottom: CGFloat
    let vol: CGFloat
    let idx: Int
    let timeStr: String
    
    var boll: KLBoll = .zero
    var macd: KLMacd = .zero
    var kdj: KLKDJ = .zero
    var ma7: CGFloat = 0
    var ma30: CGFloat = 0
    var rsi1: CGFloat = 0
    var rsi2: CGFloat = 0
    var rsi3: CGFloat = 0
    
    static let zero = KLData(time: 0, open: 0, close: 0, top: 0, bottom: 0, vol: 0, idx: 0)
    static let huge = KLData(time: 0, open: 0, close: 0, top: 0, bottom: .greatestFiniteMagnitude, vol: 0, idx: 0)
    
    init(time: CGFloat, open: CGFloat, close: CGFloat, top: CGFloat, bottom: CGFloat, vol: CGFloat, idx: Int) {
        self.time = time
        self.open = open
        self.close = close
        self.top = top
        self.bottom = bottom
        self.vol = vol
        self.idx = idx
        self.timeStr = DateFormatter.coordinateX.string(from: Date(timeIntervalSince1970: TimeInterval(time / 1000.0)))
    }
}



struct KLResponse: Decodable {
    let code: Int
    let message: String
    let timestamp: TimeInterval
    let data: KLSource
}

struct KLSource: Decodable {
    let time: String
    let list: [[CGFloat?]]
}
