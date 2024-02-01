//
//  NotificationDataService.swift
//  GCI
//
//  Created by Florian ALONSO on 7/1/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

protocol NotificationDataService {
    
    typealias StatusCallback = (_ result: UIResult) -> Void
    
    func subscribe(completionHanlder: @escaping StatusCallback)
    func unsubscribe(completionHanlder: @escaping StatusCallback)
    func refreshSubscription(completionHanlder: @escaping StatusCallback)
    func updateSubscription(withNotificationCode codes: [Constant.Notification.Code], completionHanlder: @escaping StatusCallback)
}
