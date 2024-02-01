//
//  Dictionnary.swift
//  neopixl_ext
//
//  Created by Joris Thiery on 22/02/2018.
//  Copyright © 2018 Joris Thiery. All rights reserved.
//

import UIKit

extension Dictionary {
    
    /// Check if key exists in dictionary.
    public func has(key: Key) -> Bool {
        return index(forKey: key) != nil
    }
}
