//
//  ViewController.swift
//  KLine
//
//  Created by 123 on 2020/1/3.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var KL: KLineView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        KL = KLineView(frame: CGRect(x: 10, y: 88, width: view.frame.width - 20, height: 400), datasource: KLData.from(json: jsonSource))
        self.view.addSubview(KL)
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

