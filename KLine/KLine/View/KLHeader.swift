//
//  KLineHeader.swift
//  KLine
//
//  Created by 123 on 2020/1/14.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit

class KLHeader: UIView {
    private let titles: [String] = KLHeaderTitle.allCases.map { $0.rawValue }
    private let barView = UIView()
    private let titleBGView = UIView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTitle()
    }
    
    private func setupTitle() {
        if titles.count == 0 { return }
        titleBGView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: .headerTitleHeight)
        titleBGView.backgroundColor = .headerTitleBG
        
        self.addSubview(titleBGView)
        let width = bounds.width / CGFloat(titles.count)
        let barView = UIView(frame: CGRect(x: 0, y: .headerTitleHeight - .headerStatusBarHeight, width: width, height: .headerStatusBarHeight))
        titleBGView.addSubview(barView)
        
        for (idx, title) in titles.enumerated() {
            let x = CGFloat(idx) * width
            let btn = UIButton(type: .custom)
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(.headerNormal, for: .normal)
            btn.setTitleColor(.headerSelected, for: .normal)
            btn.tag = 101 + idx
            titleBGView.addSubview(btn)
            btn.frame = CGRect(x: x, y: 0, width: width, height: .headerTitleHeight)
            btn.addTarget(self, action: #selector(btnAction(sender:)), for: .touchUpInside)
        }
    }
    
    @objc private func btnAction(sender: UIButton) {
        barView.frame.origin.x = sender.frame.minX
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
