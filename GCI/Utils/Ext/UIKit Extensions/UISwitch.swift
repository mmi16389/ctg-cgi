//
//  UISwitch.swift
//  neopixl_ext
//
//  Created by Joris Thiery on 15/12/2017.
//  Copyright © 2017 Joris Thiery. All rights reserved.
//

import UIKit

extension UISwitch {
    
    public func toggle(animated: Bool = true) {
        setOn(!isOn, animated: animated)
    }
}
