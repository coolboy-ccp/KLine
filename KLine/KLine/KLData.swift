//
//  KLData.swift
//  KLine
//
//  Created by 123 on 2020/1/6.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit

struct KLData {
    let time: CGFloat
    let open: CGFloat
    let close: CGFloat
    let top: CGFloat
    let bottom: CGFloat
    let vol: CGFloat
    let idx: Int
    let timeStr: String
    
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
    
    static func from(json: String) -> [KLData] {
        guard let data = jsonSource.data(using: .utf8) else {
            return []
        }
        do {
            let rsp = try JSONDecoder().decode(KLResponse.self, from: data)
            var idx: Int = 0
            return rsp.data.list.compactMap { (e) -> KLData? in
                if e.count == 6 {
                    defer {
                        idx += 1
                    }
                    return KLData(time: e[0]!, open: e[1]!, close: e[2]!, top: e[4]!, bottom: e[3]!, vol: e[5]!, idx: idx)
                }
                return nil
            }
        }
        catch {
            return []
        }
        
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

