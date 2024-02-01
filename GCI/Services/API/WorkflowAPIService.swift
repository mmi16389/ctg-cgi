//
//  WorkflowAPIService.swift
//  GCI
//
//  Created by Florian ALONSO on 5/23/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol WorkflowAPIService {
    
    func next(forViewModel viewModel: ActionWorkflowViewModel, completionHandler: @escaping RequestJSONCallback)
    
    func cancel(forViewModel viewModel: ActionWorkflowViewModel, completionHandler: @escaping RequestJSONCallback)
    
    func reject(forViewModel viewModel: ActionWorkflowViewModel, completionHandler: @escaping RequestJSONCallback)
    
    func undo(forViewModel viewModel: ActionWorkflowViewModel, completionHandler: @escaping RequestJSONCallback)
}
