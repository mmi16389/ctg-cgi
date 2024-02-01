//
//  UserDaiService.swift
//  GCI
//
//  Created by Florian ALONSO on 5/10/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol MessageDaoService {
    
    typealias StateCallback = (_ result: Bool) -> Void
    typealias RejectMessagesCallbak = (_ result: [RejectMessage]) -> Void
    typealias CancelMessagesCallbak = (_ result: [CancelMessage]) -> Void
    
    func allRejectMessages(completion: @escaping RejectMessagesCallbak)
    func allCancelMessages(completion: @escaping CancelMessagesCallbak)
    func saveResponses(fromJson json: JSON, completion: @escaping MessageDaoService.StateCallback)
    func clearAllMessages(completion: @escaping MessageDaoService.StateCallback)
}
