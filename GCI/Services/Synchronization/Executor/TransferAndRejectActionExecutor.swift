//
//  TransferAndRejectActionExecutor.swift
//  GCI
//
//  Created by gilson quentin on 11/10/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class TransferAndRejectActionExecutor: TaskActionExecutor {
    
    var title: String?
    var description: String?
    var service: ServiceViewModel?
    
    let offlineEnabled = false
    var neededDataType: ActionDataType {
        guard let _ = title, let _ = description, let _ = service else {
            return .rejectAndTransfer
        }
        return .none
    }
    //TODO - check if it's the same message as the reject action
    let successMessage = "task_action_reject_success".localized
    
    func reset() {
        title = nil
        description = nil
        service = nil
    }
    
    func checkOrApplyChange(forTask task: TaskViewModel) -> Bool {
        // Do nothing
        return false
    }
    
    func setNeededData(fromParams params: ActionParams) {
        title = params[ActionParamType.title] as? String
        description = params[ActionParamType.description] as? String
        service = params[ActionParamType.service] as? ServiceViewModel
    }
    
    func prefilledObject(fromTask task: TaskViewModel) -> Any? {
        guard let title = self.title, let description = self.description, let service = self.service else {
            return nil
        }
        return service
    }
    
    func execute(withWorkflowService workflowService: WorkflowDataService, andWithTaskService taskService: TaskDataService, onTask task: TaskViewModel, withCompletion completion: @escaping TaskActionCompletion) {
        guard let prefilled = prefilledObject(fromTask: task) as? ServiceViewModel else {
            DispatchQueue.main.async {
                completion(.failed(.error))
            }
            return
        }
        
        taskService.changeService(forTask: task, title: self.title, description: self.description, toService: prefilled) { (result) in
            switch result {
            case .value(let task):
                completion(.value(task))
            case .failed(let error):
                completion(.failed(error))
            }
        }
    }
}
