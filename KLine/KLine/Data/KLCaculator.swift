//
//  KLCaculator.swift
//  KLine
//
//  Created by 123 on 2020/1/16.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit


class KLCaculator {
    
    static func boll(_ datas: [KLData]) {
        let params = klConfig.boll_param
        let reversed = Array(datas.reversed())
        for (idx, data) in reversed.enumerated() {
            if idx == 0 {
                data.boll = KLBoll(ma: data.close, up: data.close, down: data.close)
                continue
            }
            var period = klConfig.boll_period
            if idx + 1 < period {
                period = idx + 1
            }
            let start = idx + 1 - period
            let end = idx + 1
            let close: CGFloat = (start ..< end).reduce(0) { return $0 + datas[$1].close }
            let ma = close / CGFloat(period)
            let variance = (start ..< end).reduce(0) { return $0 + pow(datas[$1].close - ma, 2) }
            let md = sqrt(variance / CGFloat(idx))
            let up = ma + params * md
            let down = ma - params * md
            data.boll = KLBoll(ma: ma, up: up, down: down)
        }
    }
    
    static func macd(_ datas: [KLData]) {
        let reversed = Array(datas.reversed())
        let short = klConfig.macd_short
        let long = klConfig.macd_long
        let nine = klConfig.macd_Nine
        for (idx, data) in reversed.enumerated() {
            if idx == 0 {
                data.macd = KLMacd(dif: 0, dea: 0, macd: 0, longEma: data.close, shortEma: data.close)
                continue
            }
            let lastMacd = reversed[idx - 1].macd
            let shortEma = lastMacd.shortEma * (short - 1) / (short + 1) + data.close / (short + 1) * 2
            let longEma = lastMacd.longEma * (long - 1) / (long + 1) + data.close / (long + 1) * 2
            let dif = shortEma - longEma
            let dea = lastMacd.dea * (nine - 1) / (nine + 1) + dif * 2 / (nine + 1)
            let macd = (dif - dea) * 2
            data.macd = KLMacd(dif: dif, dea: dea, macd: macd, longEma: longEma, shortEma: shortEma)
        }
    }
    
    static func ma(_ datas: [KLData]) {
        let reversed = Array(datas.reversed())
        for (idx, data) in reversed.enumerated() {
            data.ma7 = ma(datas, idx, period: klConfig.MA_p7)
            data.ma30 = ma(datas, idx, period: klConfig.MA_p30)
        }
    }
    
    private static func ma(_ datas: [KLData], _ idx: Int, period: Int) -> CGFloat {
        if idx + 1 < period { return 0 }
        let start = idx + 1 - period
        let end = idx + 1
        return (start ..< end).reduce(0) { return datas[$1].close + $0 } / CGFloat(period)
    }
    
    static func kdj(_ datas: [KLData]) {
        
        let reversed = Array(datas.reversed())
        let period = klConfig.kdj_p
        for (idx, data) in reversed.enumerated() {
            if idx == 0 {
                data.kdj = .zero
                continue
            }
            var start = idx + 1 - period
            start = start < 0 ? 0 : start
            let end = idx + 1
            let highLow = (start ..< end).reduce((0, CGFloat.greatestFiniteMagnitude)) { (rlt, i) -> (CGFloat, CGFloat) in
                let high = rlt.0 > reversed[i].top ? rlt.0 : reversed[i].top
                let low = rlt.1 < reversed[i].bottom ? rlt.1 : reversed[i].bottom
                return (high, low)
            }
            let dif = highLow.0 - highLow.1
            let rsv = dif == 0 ? 50 : (data.close - highLow.1) / dif
            let lastKdj = datas[idx - 1].kdj
            let k = lastKdj.k * (klConfig.kdj_p2 - 1) / klConfig.kdj_p2 + rsv / klConfig.kdj_p2
            let d = lastKdj.d * (klConfig.kdj_p3 - 1) / klConfig.kdj_p3 + k / klConfig.kdj_p3
            var j = k * 3 - d * 2
            j = j > 100 ? 100 : j
            data.kdj = KLKDJ(k: k, d: d, j: j)
        }
        
    }
    
    static func datas(from json: String) -> [KLData] {
        guard let data = json.data(using: .utf8) else {
            return []
        }
        do {
            let rsp = try JSONDecoder().decode(KLResponse.self, from: data)
            var idx: Int = 0
            let list = rsp.data.list
            let datas = list.compactMap { (e) -> KLData? in
                if e.count < 6 { return nil }
                defer {
                    idx += 1
                }
                return KLData(time: e[0]!, open: e[1]!, close: e[2]!, top: e[4]!, bottom: e[3]!, vol: e[5]!, idx: idx)
            }
            boll(datas)
            macd(datas)
            ma(datas)
            kdj(datas)
            return datas
           
        }
        catch {
            return []
        }
    }
}
