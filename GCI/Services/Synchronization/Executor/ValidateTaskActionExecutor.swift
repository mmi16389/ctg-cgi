//
//  ValidateTaskActionExecutor.swift
//  GCI
//
//  Created by Florian ALONSO on 5/20/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class ValidateTaskActionExecutor: TaskActionExecutor {
    
    let offlineEnabled = false
    let neededDataType = ActionDataType.none
    let successMessage = "task_action_validate_success".localized
    
    func reset() {
        // Do nothing
    }
    
    func checkOrApplyChange(forTask task: TaskViewModel) -> Bool {
        // Do nothing
        return false
    }
    
    func setNeededData(fromParams params: ActionParams) {
        // Do nothing
    }
    
    func prefilledObject(fromTask task: TaskViewModel) -> Any? {
        guard task.canValidate && task.interventionType != nil else {
            return nil
        }
        
        return ActionWorkflowViewModel(taskId: task.id, workflowAction: .next, taskAction: .validate)
    }
    
    func execute(withWorkflowService workflowService: WorkflowDataService, andWithTaskService taskService: TaskDataService, onTask task: TaskViewModel, withCompletion completion: @escaping TaskActionCompletion) {
        guard let prefilled = prefilledObject(fromTask: task) as? ActionWorkflowViewModel else {
            DispatchQueue.main.async {
                completion(.failed(.error))
            }
            return
        }
        
        self.launchActionWorkflow(forAction: prefilled, withWorkflowService: workflowService, andWithTaskService: taskService, onTask: task, withCompletion: completion)
    }
}