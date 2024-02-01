//
//  NotificationAPIService.swift
//  GCI
//
//  Created by Florian ALONSO on 7/1/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol NotificationAPIService {
    typealias SubscriptionCallback = (_ subscriptionList: [Int], _ requestStatus: RequestStatus) -> Void
    
    func register(token: String, completionHandler: @escaping RequestStatusCallback)
    func unregister(token: String, completionHandler: @escaping RequestStatusCallback)
    func getSubscription(completionHandler: @escaping SubscriptionCallback)
    func updateSubscription(subscriptionList: [Int], completionHandler: @escaping SubscriptionCallback)
}
