//
//  WorkflowDataService.swift
//  GCI
//
//  Created by Florian ALONSO on 5/23/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

protocol WorkflowDataService {
    typealias StatusCallback = (_ result: UIResult) -> Void
    
    func launchActionWorkflow(withOfflineEnabled offlineEnabled: Bool, onViewModel viewModel: ActionWorkflowViewModel, completion: @escaping StatusCallback)
    
    func forceSynchronization(forAction action: ActionWorkflow, completion: @escaping StatusCallback)
    
}
