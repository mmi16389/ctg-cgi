//
//  Float.swift
//  neopixl_ext
//
//  Created by Joris Thiery on 22/02/2018.
//  Copyright © 2018 Joris Thiery. All rights reserved.
//

import UIKit

extension Float {
    /// to Int.
    public var int: Int {
        return Int(self)
    }
    
    /// to Double.
    public var double: Double {
        return Double(self)
    }
    
    /// to CGFloat.
    public var cgFloat: CGFloat {
        return CGFloat(self)
    }
    
    /// Radian value of degree input.
    public var degreesToRadians: Float {
        return Float.pi * self / Float(180)
    }

    /// Degree value of radian input.
    public var radiansToDegrees: Float {
        return self * Float(180) / Float.pi
    }
}
