//
//  ChangeServiceTaskActionExecutor.swift
//  GCI
//
//  Created by Florian ALONSO on 6/11/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class ChangeServiceTaskActionExecutor: TaskActionExecutor {
    
    var service: ServiceViewModel?
    
    let offlineEnabled = false
    var neededDataType: ActionDataType {
        guard let _ = service else {
            return .service
        }
        return .none
    }
    let successMessage = "task_action_transfer_success".localized
    
    func reset() {
        // Do nothing
    }
    
    func checkOrApplyChange(forTask task: TaskViewModel) -> Bool {
        // Do nothing
        return false
    }
    
    func setNeededData(fromParams params: ActionParams) {
        self.service = params[ActionParamType.service] as? ServiceViewModel
    }
    
    func prefilledObject(fromTask task: TaskViewModel) -> Any? {
        guard task.canValidate, let currentService =  task.service, currentService.type == .notOperational, let newService = self.service else {
            return nil
        }
        
        return newService
    }
    
    func execute(withWorkflowService workflowService: WorkflowDataService, andWithTaskService taskService: TaskDataService, onTask task: TaskViewModel, withCompletion completion: @escaping TaskActionCompletion) {
        guard let prefilled = prefilledObject(fromTask: task) as? ServiceViewModel else {
            DispatchQueue.main.async {
                completion(.failed(.error))
            }
            return
        }
        
        taskService.changeService(forTask: task, title: nil, description: nil, toService: prefilled) { (result) in
            switch result {
            case .value(let task):
                completion(.value(task))
            case .failed(let error):
                completion(.failed(error))
            }
        }
    }
}
