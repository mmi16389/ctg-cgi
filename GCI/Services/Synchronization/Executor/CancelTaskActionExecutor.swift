//
//  CancelTaskActionExecutor.swift
//  GCI
//
//  Created by Florian ALONSO on 6/7/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class CancelTaskActionExecutor: TaskActionExecutor {
    
    var title: String?
    var description: String?
    
    let offlineEnabled = true
    var neededDataType: ActionDataType {
        guard let _ = title, let _ = description else {
            return .cancel
        }
        return .none
    }
    let successMessage = "task_action_cancel_success".localized
    
    func reset() {
        title = nil
        description = nil
    }
    
    func checkOrApplyChange(forTask task: TaskViewModel) -> Bool {
        task.isActivated = false
        task.status = .canceled
        return true
    }
    
    func setNeededData(fromParams params: ActionParams) {
        title = params[ActionParamType.title] as? String
        description = params[ActionParamType.description] as? String
    }
    
    func prefilledObject(fromTask task: TaskViewModel) -> Any? {
        guard let title = self.title, let description = self.description else {
            return nil
        }
        
        let workflow = ActionWorkflowViewModel(taskId: task.id, workflowAction: .cancel, taskAction: .cancel)
        workflow.title = title
        workflow.description = description
        return workflow
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
