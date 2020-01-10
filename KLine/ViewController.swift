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
    
    var isV = true
    var processing = true
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if processing {
//            return
//        }
//        processing = true
//        KL.update(frame: CGRect(x: 50, y: 50, width: self.view.bounds.height - 60, height: self.view.bounds.width - 40))
//        KL.backgroundColor = .black
//        UIView.animate(withDuration: 0.3, animations: {
//            self.KL.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
//            self.KL.center = self.view.center
//        }) { (_) in
//            self.processing = false
//        }
//        UIView.animate(withDuration: 0.3) {
//           // self.view.setNeedsLayout()
//            
//            //self.view.window?.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
//         //   self.view.window?.center = (UIApplication.shared.keyWindow?.center)!
//        }
//        isV = false
      //  KL.update(frame: CGRect(x: <#T##CGFloat#>, y: <#T##CGFloat#>, width: <#T##CGFloat#>, height: <#T##CGFloat#>))
    }
}

