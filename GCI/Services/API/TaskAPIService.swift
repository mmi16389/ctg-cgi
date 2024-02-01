//
//  TaskAPIService.swift
//  GCI
//
//  Created by Florian ALONSO on 5/8/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol TaskAPIService {
    
    typealias ServiceListCallback = (_ servicesIds: [Int], _ requestStatus: RequestStatus) -> Void
    
    func taskList(alreadyKnowsIds: [Int], completionHandler: @escaping RequestJSONCallback)
    func task(byId id: Int, completionHandler: @escaping RequestJSONCallback)
    func create(fromViewModel viewModel: CreatedTaskViewModel, completionHandler: @escaping RequestJSONCallback)
    func update(fromViewModel viewModel: TaskViewModel, completionHandler: @escaping RequestJSONCallback)
    func assignableUser(forTaskId id: Int, completionHandler: @escaping RequestJSONCallback)
    func changeService(forTaskId id: Int, toServiceId serviceId: Int, title: String?, description: String?, completionHandler: @escaping RequestJSONCallback)
    func availableServices(forTaskId id: Int, completionHandler: @escaping ServiceListCallback)
    
}
