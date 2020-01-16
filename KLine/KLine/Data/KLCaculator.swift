//
//  KLCaculator.swift
//  KLine
//
//  Created by 123 on 2020/1/16.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit

extension KLData {
    static func datas(from json: String, config: KLConfig = .default) -> [KLData] {
        guard let data = json.data(using: .utf8) else {
            return []
        }
        do {
            let rsp = try JSONDecoder().decode(KLResponse.self, from: data)
            var idx: Int = 0
            let list = rsp.data.list
            var datas = [KLData]()
            var las: CGFloat = 0
            var lam: CGFloat = 0
            for index in 0 ..< list.count {
                let idx = list.count - index - 1
                let e = list[idx]
                if e.count < 6 { continue }
                let last = datas.last
                func boll() -> KLBoll {
                    if index == 0 {
                        return KLBoll(ma: e[2]!, up: e[2]!, down: e[2]!)
                    }
                    let period = config.boll_period
                    let drop = (idx / period) * period
                    let periodDatas = datas.dropFirst(drop)
                    let ma: CGFloat = periodDatas.reduce(0) { return $0 + $1.close } / CGFloat(period)
                    let md: CGFloat = sqrt(periodDatas.reduce(0) { return $0 + pow($1.close - ma, 2) })
                    return KLBoll(ma: ma, up: ma + config.boll_param * md, down: ma - config.boll_param * md)
                }
                
                func macd() -> KLMacd {
                    if index == 0 {
                        return KLMacd(dif: 0, dea: 0, macd: 0, longEma: e[2]!, shortEma: e[2]!)
                    }
                    let short = config.macd_short
                    let long = config.macd_long
                    let nine = config.macd_Nine
                    let lastMacd = last!.macd
                    let shortEma = lastMacd.shortEma * (short - 1) / (short + 1) + e[2]! / (short + 1) * 2
                    let longEma = lastMacd.longEma * (long - 1) / (long + 1) + e[2]! / (long + 1) * 2
                    let dif = shortEma - longEma
                    let dea = lastMacd.dea * (nine - 1) / (nine + 1) + dif * 2 / (nine + 1)
                    let macd = (dif - dea) * 2
                    return KLMacd(dif: dif, dea: dea, macd: macd, longEma: longEma, shortEma: shortEma)
                }
                
                func ma(_ period: Int) -> CGFloat {
                    if idx < period - 1 { return 0 }
                    let drop = (idx / period) * period
                    let periodDatas = datas.dropFirst(drop)
                    return periodDatas.reduce(0) { $0 + $1.close } / CGFloat(period)
                }
                
                func rsi(_ period: Int) -> CGFloat {
                    if index == 0 {
                        return config.rsi_df
                    }
                    let dif = last!.close - e[2]!
                    let max = dif > 0 ? dif : 0
                    let smamax = (max + (CGFloat(period) - 1) * las) / CGFloat(period)
                    let smaAbs = (abs(dif) + (CGFloat(period) - 1) * lam) / CGFloat(period)
                    las = smamax
                    lam = smaAbs
                    if smaAbs == 0 { return config.rsi_df }
                    return config.rsi_df * (1 - smamax / smaAbs)
                }
                
                func kdj() -> KLKDJ {
                    if index == 0 {
                        return .zero
                    }
                    let period = config.kdj_p
                    var high: CGFloat = 0
                    var low: CGFloat = CGFloat.greatestFiniteMagnitude
                    let close = e[2]!
                    let drop = (idx / period) * period
                    for data in datas.dropLast(drop) {
                        if data.top > high {
                            high = data.top
                        }
                        if data.bottom < low {
                            low = data.bottom
                        }
                    }
                    let dif = high - low
                    let rsv = dif == 0 ? 50 : (close - low) / dif * 100
                    let lastKdj = last!.kdj
                    let k = lastKdj.k * (config.kdj_p2 - 1) / config.kdj_p2 + rsv / config.kdj_p2
                    let d = lastKdj.d * (config.kdj_p3 - 1) / config.kdj_p3 + k / config.kdj_p3
                    var j = k * 3 - d * 2
                    j = j > 100 ? 100 : j
                    return KLKDJ(k: k, d: d, j: j)
                }
                
                let data = KLData(time: e[0]!, open: e[1]!, close: e[2]!, top: e[4]!, bottom: e[3]!, vol: e[5]!, idx: idx)
                data.boll = boll()
                data.macd = macd()
                data.ma7 = ma(config.MA_p7)
                data.ma30 = ma(config.MA_p30)
                data.rsi1 = rsi(config.rsi_p1)
                data.rsi2 = rsi(config.rsi_p2)
                data.rsi3 = rsi(config.rsi_p3)
                data.kdj = kdj()
                datas.append(data)
            }
            return datas.reversed()
        }
        catch {
            return []
        }
    }
}
