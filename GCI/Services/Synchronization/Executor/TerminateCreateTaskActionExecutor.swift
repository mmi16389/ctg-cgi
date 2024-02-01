//
//  TerminateCreateTaskActionExecutor.swift
//  GCI
//
//  Created by Florian ALONSO on 6/6/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class TerminateCreateTaskActionExecutor: TaskActionExecutor {
    
    var createdTask: CreatedTaskViewModel?
    
    let offlineEnabled = false
    var neededDataType: ActionDataType {
        guard self.createdTask != nil else {
            return .taskNew
        }
        return .none
    }
    let successMessage = "task_action_close_and_create_success".localized
    
    func reset() {
        createdTask = nil
    }
    
    func checkOrApplyChange(forTask task: TaskViewModel) -> Bool {
        // Do nothing
        return false
    }
    
    func setNeededData(fromParams params: ActionParams) {
        self.createdTask = params[ActionParamType.createdTask] as? CreatedTaskViewModel
    }
    
    func prefilledObject(fromTask task: TaskViewModel) -> Any? {
        guard task.canClose, createdTask != nil else {
            return nil
        }
        
        let workflow = ActionWorkflowViewModel(taskId: task.id, workflowAction: .next, taskAction: .close)
        workflow.createdTask = createdTask
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
