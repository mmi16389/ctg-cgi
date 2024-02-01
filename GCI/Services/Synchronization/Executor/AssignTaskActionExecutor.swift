//
//  AssignTaskActionExecutor.swift
//  GCI
//
//  Created by Florian ALONSO on 6/6/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class AssignTaskActionExecutor: TaskActionExecutor {
    
    var userId: String?
    
    let offlineEnabled = false
    var neededDataType: ActionDataType {
        guard let userId = userId, !userId.isEmpty else {
            return .assign
        }
        return .none
    }
    let successMessage = "task_action_assign_success".localized
    
    func reset() {
        userId = nil
    }
    
    func checkOrApplyChange(forTask task: TaskViewModel) -> Bool {
        // Do nothing
        return false
    }
    
    func setNeededData(fromParams params: ActionParams) {
        userId = params[ActionParamType.userId] as? String
    }
    
    func prefilledObject(fromTask task: TaskViewModel) -> Any? {
        guard let userId = userId, (task.canAssign || task.canChangeAssign) else {
            return nil
        }
        
        let workflow = ActionWorkflowViewModel(taskId: task.id, workflowAction: .next, taskAction: .assign)
        workflow.userId = userId
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
