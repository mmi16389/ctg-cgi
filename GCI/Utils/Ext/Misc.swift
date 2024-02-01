//
//  Misc.swift
//  neopixl_ext
//
//  Created by Joris Thiery on 22/02/2018.
//  Copyright © 2018 Joris Thiery. All rights reserved.
//

import UIKit

public struct NeopixlExt {

    /// App current build number (if applicable).
    public static var appBuild: String? {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    }
    
    /// App's current version (if applicable).
    public static var appVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    /// Current battery level.
    public static var batteryLevel: Float {
        return UIDevice.current.batteryLevel
    }
    
    /// Screen height.
    public static var screenHeight: CGFloat {
        #if os(iOS) || os(tvOS)
            return UIScreen.main.bounds.height
        #elseif os(watchOS)
            return currentDevice.screenBounds.height
        #endif
    }
    
    /// Screen width.
    public static var screenWidth: CGFloat {
        #if os(iOS) || os(tvOS)
            return UIScreen.main.bounds.width
        #elseif os(watchOS)
            return currentDevice.screenBounds.width
        #endif
    }
    
    /// Check if device is iPad.
    public static var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    /// Check if device is iPhone.
    public static var isPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    /// Delay function or closure call.
    @discardableResult public static func delay(milliseconds: Double, queue: DispatchQueue = .main, completion: @escaping () -> Void) -> DispatchWorkItem {
        let task = DispatchWorkItem { completion() }
        queue.asyncAfter(deadline: .now() + (milliseconds/1000), execute: task)
        return task
    }
}

enum UIUserInterfaceIdiom: Int {
    case unspecified
    case phone
    case pad
}

struct ScreenSize {
    static let screenWidth        = UIScreen.main.bounds.size.width
    static let screenHeight       = UIScreen.main.bounds.size.height
    static let screenMaxLenght    = max(ScreenSize.screenWidth, ScreenSize.screenHeight)
    static let screenMinLenght    = min(ScreenSize.screenWidth, ScreenSize.screenHeight)
}

struct DeviceType {
    static let isIphone4OrLess  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.screenMaxLenght < 568.0
    static let isIphone5        = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.screenMaxLenght == 568.0
    static let isIphone6        = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.screenMaxLenght == 667.0
    static let isIphone6p       = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.screenMaxLenght == 736.0
    static let isIphone6pOrMore = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.screenMaxLenght >= 736.0
    static let isIpad           = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.screenMaxLenght >= 1024.0
    static let isIpadLandscape  = UIDevice.current.userInterfaceIdiom == .pad && UIDevice.current.orientation.isLandscape
}
