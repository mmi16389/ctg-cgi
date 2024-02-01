//
//  Data+String.swift
//  GCI
//
//  Created by Florian ALONSO on 7/1/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

extension Data {
    
    var hexaString: String {
        return self.map { String(format: "%02.2hhx", $0) }.joined()
    }
    
    var hexaTokenLimitedString: String {
        return String(self.hexaString.prefix(120 - Constant.Notification.Tags.token.count))
    }
    
}
