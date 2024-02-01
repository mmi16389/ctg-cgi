//
//  UIViewController.swift
//  neopixl_ext
//
//  Created by Joris Thiery on 15/12/2017.
//  Copyright © 2017 Joris Thiery. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func changeStatusBarColor(color: UIColor) {
        
        let statusBarView = UIView()
        
        if #available(iOS 11.0, *) {
            statusBarView.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: self.view.safeAreaInsets.top)
        } else {
            statusBarView.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 20)
        }
        statusBarView.backgroundColor = color
        self.view.addSubview(statusBarView)
    }
}
