//
//  BundleHelper.swift
//  GCI
//
//  Created by Anthony Chollet on 06/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: Int? {
        return Int(infoDictionary?["CFBundleVersion"] as? String ?? "")
    }
}
