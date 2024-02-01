//
//  UIFont.swift
//  neopixl_ext
//
//  Created by Joris Thiery on 15/12/2017.
//  Copyright © 2017 Joris Thiery. All rights reserved.
//

import UIKit

extension UIFont {
    
    static func printAllFonts() {
        print("All fonts : \n\n \(UIFont.familyNames)")
    }
    
    static func gciFont(_ size: Int) -> UIFont {
        return UIFont(name: "HelveticaNeue", size: CGFloat(size))!
    }
    
    static func gciFontBold(_ size: Int) -> UIFont {
        return UIFont(name: "HelveticaNeue-Bold", size: CGFloat(size))!
    }
    
    static func gciFontLight(_ size: Int) -> UIFont {
        return UIFont(name: "HelveticaNeue-Light", size: CGFloat(size))!
    }
    
    static func gciFontRegular(_ size: Int) -> UIFont {
        return UIFont(name: "HelveticaNeue", size: CGFloat(size))!
    }
    
    static func gciFontMedium(_ size: Int) -> UIFont {
        return UIFont(name: "HelveticaNeue-Medium", size: CGFloat(size))!
    }
}
