//
//  NSNotification+Name.swift
//  GCI
//
//  Created by Florian ALONSO on 3/11/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let applicationShouldLogout = NSNotification.Name("notificationLogoutIdentifier")
    static let licenceExpired = NSNotification.Name("licenceExpired")
    static let appConfigurationChanged = NSNotification.Name("appConfigurationChanged")
    static let pushNotificationReceived = NSNotification.Name("PushNotificationReceived")
}
