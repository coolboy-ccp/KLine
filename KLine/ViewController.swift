//
//  ViewController.swift
//  KLine
//
//  Created by 123 on 2020/1/3.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let kline = KLContainer(superWidth: self.view.bounds.width, y: 88, data: KLCaculator.datas(from: jsonSource))
        self.view.addSubview(kline)
    }
    
    
    private func dispaly(_ handler: @autoclosure @escaping () -> ()) {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (_) in
            if let sublayers = self.view.layer.sublayers {
                for layer in sublayers {
                    layer.removeFromSuperlayer()
                }
            }
            handler()
        }
        
    }

}

