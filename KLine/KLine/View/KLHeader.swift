//
//  KLineHeader.swift
//  KLine
//
//  Created by 123 on 2020/1/14.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit

protocol KLPeriodChanged where Self: AnyObject {
    func periodChanged(to period: KLPeriod)
}

protocol KLQuotaChanged where Self: AnyObject {
    func mainChanged(to quota: KLMainQuota)
    func subChanged(to quota: KLSubQuota)
}

class KLHeader: UIView {
    private let barView = UIView()
    
    var periodDelegate: KLPeriodChanged?
    var quotaDelegate: KLQuotaChanged?
    
    lazy private var periodBGView: UIView = {
        let v = UIView()
        v.backgroundColor = .headerPeriodBG
        addSubview(v)
        return v
    }()
    
    lazy private var quotaBGView: UIView = {
        let v = UIView()
        v.backgroundColor = .quotaBg
        addSubview(v)
        return v
    }()
    
    private var periodBtns = [UIButton]()
    private var mainQuotaBtns = [UIButton]()
    private var subQuotaBtns = [UIButton]()
    
    init(supWidth: CGFloat) {
        let frame = CGRect(x: 0, y: 0, width: supWidth, height: portrait.headerPeriodHeight)
        super.init(frame: frame)
        self.clipsToBounds = true
        periodView()
        quotaView()
    }
    
    private func periodView() {
        let count = klConfig.periods.count
        if count == 0 { return }
        periodBGView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: portrait.headerPeriodHeight)
        let width = bounds.width / CGFloat(count + 1)
        barView.backgroundColor = .headerStatusBar
        periodBGView.addSubview(barView)
        for (idx, period) in klConfig.periods.enumerated() {
            let x = CGFloat(idx) * width
            let periodBtn = periodButton()
            periodBtn.setTitle(period.title, for: .normal)
            periodBtn.tag = 101 + period.rawValue
            periodBGView.addSubview(periodBtn)
            periodBtn.frame = CGRect(x: x, y: 0, width: width, height: portrait.headerPeriodHeight)
            periodBtn.addTarget(self, action: #selector(periodAction(sender:)), for: .touchUpInside)
            periodBtns.append(periodBtn)
            if period == klConfig.defaultPeriod {
                barView.frame = CGRect(x: x, y: portrait.headerPeriodHeight - .headerStatusBarHeight, width: width, height: .headerStatusBarHeight)
                periodBtn.isSelected = true
            }
        }
        let quotaBtn = periodButton()
        quotaBtn.frame = CGRect(x: bounds.width - width, y: 0, width: width, height: portrait.headerPeriodHeight)
        quotaBtn.addTarget(self, action: #selector(quota(sender:)), for: .touchUpInside)
        quotaBtn.setTitle("指标", for: .normal)
        periodBGView.addSubview(quotaBtn)
    }
    
    
    private func quotaView() {
        quotaBGView.frame = CGRect(x: 0, y: portrait.headerPeriodHeight, width: bounds.width, height: portrait.quotaHeight * 2)
        addQuota(with: klConfig.mainQuotas, isMain: true)
        addQuota(with: klConfig.subQuotas, isMain: false)
    }
    
    private func addQuota(with quotas: [KLQuota], isMain: Bool) {
        let width: CGFloat = 60
        let padding: CGFloat = 10
        let y = isMain ? 0 : portrait.quotaHeight
        let height = portrait.quotaHeight
        let title = isMain ? "主图" : "副图"
        let label = UILabel(frame: CGRect(x: 0, y: y, width: width, height: height))
        label.font = .quota
        label.textColor = .quotaNormal
        label.text = title
        label.textAlignment = .center
        let line = UIView(frame: CGRect(x: width, y: y + 10, width: 0.5, height: height - 20))
        line.backgroundColor = .quotaNormal
        quotaBGView.addSubview(line)
        quotaBGView.addSubview(label)
        var quotaX = width + padding
        let df: KLQuota = isMain ? klConfig.defaultMainQuota : klConfig.defaultSubQuota
        for quota in quotas {
            let quotaBtn = UIButton(type: .custom)
            let width = (quota.title as NSString).boundingRect(with: CGSize(width: 100, height: 20), options: .usesFontLeading, attributes: [.font : UIFont.quota], context: nil).width
            quotaBtn.titleLabel?.font = .quota
            quotaBtn.setTitleColor(.quotaNormal, for: .normal)
            quotaBtn.setTitleColor(.quotaSelected, for: .selected)
            quotaBtn.setTitle(quota.title, for: .normal)
            quotaBtn.tag = isMain ? 101 + quota.rv : 201 + quota.rv
            quotaBtn.frame = CGRect(x: quotaX, y: y, width: width, height: height)
            quotaX += width + padding
            let sel = isMain ? #selector(mainQuota(sender:)) : #selector(subQuota(sender:))
            if df.rv == quota.rv {
                quotaBtn.isSelected = true
            }
            quotaBtn.addTarget(self, action: sel, for: .touchUpInside)
            quotaBGView.addSubview(quotaBtn)
            isMain ? mainQuotaBtns.append(quotaBtn) : subQuotaBtns.append(quotaBtn)
        }
        quotaBGView.alpha = 0
    }
    
    @objc func mainQuota(sender: UIButton) {
        if sender.isSelected { return }
        for btn in mainQuotaBtns {
            btn.isSelected = false
        }
        sender.isSelected = true
        let quota = KLMainQuota(rawValue: sender.tag - 101) ?? .sar
        quotaDelegate?.mainChanged(to: quota)
    }
    
    @objc func subQuota(sender: UIButton) {
        if sender.isSelected { return }
        for btn in subQuotaBtns {
            btn.isSelected = false
        }
        sender.isSelected = true
        let quota = KLSubQuota(rawValue: sender.tag - 201) ?? .vol
        quotaDelegate?.subChanged(to: quota)
    }
    
    private func periodButton() -> UIButton {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = .header
        btn.setTitleColor(.headerNormal, for: .normal)
        btn.setTitleColor(.headerSelected, for: .selected)
        return btn
    }
    
    @objc private func quota(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.frame.size.height = sender.isSelected ? portrait.headerPeriodHeight + portrait.quotaHeight * 2 : portrait.headerPeriodHeight
        UIView.animate(withDuration: 0.3, animations: {
            self.quotaBGView.alpha = sender.isSelected ? 1.0 : 0
        })
    }
    
    @objc private func periodAction(sender: UIButton) {
        if sender.isSelected { return }
        for btn in periodBtns {
            btn.isSelected = false
        }
        sender.isSelected = true
        UIView.animate(withDuration: 0.3) {
            self.barView.frame.origin.x = sender.frame.minX
        }
        let period = KLPeriod(rawValue: sender.tag - 101) ?? .min15
        periodDelegate?.periodChanged(to: period)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
