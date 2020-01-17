//
//  KLConfig.swift
//  KLine
//
//  Created by 123 on 2020/1/17.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit

let klConfig = KLConfig.default

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
    private(set) var mainQuotas: [KLMainQuota] = KLMainQuota.allCases
    private(set) var subQuotas: [KLSubQuota] = KLSubQuota.allCases
    private(set) var periods: [KLPeriod] = KLPeriod.allCases
    private(set) var defaultPeriod = KLPeriod.min15
    private(set) var defaultSubQuota = KLSubQuota.vol
    private(set) var defaultMainQuota = KLMainQuota.none
    static let `default` = KLConfig()
    
}

protocol KLQuota {
    var title: String { get }
    var rv: Int { get }
}

enum KLMainQuota: Int, CaseIterable {
    case sar
    case ma
    case boll
    case none
}

extension KLMainQuota: KLQuota {
    var title: String {
        switch self {
        case .none:
            return "关闭"
        case .ma:
            return "MA"
        case .sar:
            return "SAR"
        case .boll:
            return "BOLL"
        }
    }
    
    var rv: Int {
        return self.rawValue
    }
    
}

enum KLSubQuota: Int, CaseIterable {
    case vol
    case macd
    case rsi
    case kdj
}

extension KLSubQuota: KLQuota {
    var title: String {
        switch self {
        case .vol:
            return "成交量"
        case .macd:
            return "MACD"
        case .rsi:
            return "RSI"
        case .kdj:
            return "KDJ"
        }
    }
    
    var rv: Int {
        return self.rawValue
    }
}

enum KLPeriod: Int, CaseIterable {
    case min5
    case min15
    case min30
    case hour1
    case hour6
    case day1
}

extension KLPeriod {
    var title: String {
        switch self {
        case .min5:
            return "5分"
        case .min15:
            return "15分"
        case .min30:
            return "30分"
        case .hour1:
            return "1小时"
        case .hour6:
            return "6小时"
        case .day1:
            return "1天"
        }
    }
}
