//
//  Collection.swift
//  neopixl_ext
//
//  Created by Joris Thiery on 15/12/2017.
//  Copyright © 2017 Joris Thiery. All rights reserved.
//

import UIKit

extension Collection {
    
    // Returns the element at the specified index only if it is within bounds, otherwise nil. (great for iflet an index of array)
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
