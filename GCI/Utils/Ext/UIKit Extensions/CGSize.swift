//
//  CGSize.swift
//  neopixl_ext
//
//  Created by Joris Thiery on 22/02/2018.
//  Copyright © 2018 Joris Thiery. All rights reserved.
//

import UIKit

extension CGSize {
    
    /// Aspect fit CGSize.
    public func aspectFit(to boundingSize: CGSize) -> CGSize {
        let minRatio = min(boundingSize.width / width, boundingSize.height / height)
        return CGSize(width: width * minRatio, height: height * minRatio)
    }
    
    /// Aspect fill CGSize.
    public func aspectFill(to boundingSize: CGSize) -> CGSize {
        let minRatio = max(boundingSize.width / width, boundingSize.height / height)
        let w = min(width * minRatio, boundingSize.width)
        let h = min(height * minRatio, boundingSize.height)
        return CGSize(width: w, height: h)
    }
}
