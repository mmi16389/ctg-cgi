//
//  EditTaskActionExecutor.swift
//  GCI
//
//  Created by Florian ALONSO on 6/4/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class EditTaskActionExecutor: TaskActionExecutor {
    
    var taskId: Int?
    
    let offlineEnabled = false
    var neededDataType: ActionDataType {
        guard let taskId = self.taskId, taskId > 0 else {
            return .taskEdit
        }
        return .none
    }
    let successMessage = "task_action_edit_success".localized
    
    func reset() {
        taskId = nil
    }
    
    func checkOrApplyChange(forTask task: TaskViewModel) -> Bool {
        return false
    }
    
    func setNeededData(fromParams params: ActionParams) {
        self.taskId = params[ActionParamType.taskId] as? Int
    }
    
    func prefilledObject(fromTask task: TaskViewModel) -> Any? {
        guard let currentTaskId = taskId, task.id == currentTaskId else {
            return nil
        }
        
        return task
    }
    
    func execute(withWorkflowService workflowService: WorkflowDataService, andWithTaskService taskService: TaskDataService, onTask task: TaskViewModel, withCompletion completion: @escaping TaskActionCompletion) {
        guard let prefilled = prefilledObject(fromTask: task) as? TaskViewModel else {
            DispatchQueue.main.async {
                completion(.failed(.error))
            }
            return
        }
        
        SynchronizationService.shared.startSynchronizationForTaskChange(withCompletion: { (result) in
            switch result {
            case .success:
                taskService.task(byId: prefilled.id, withAForcedRefresh: false, completion: { (result) in
                    switch result {
                    case .value(let refreshtask):
                        completion(.value(refreshtask))
                    case .failed(let error):
                        completion(.failed(error))
                    }
                })
            case .noInternet:
                completion(.failed(.noNetwork))
            default:
                completion(.failed(.error))
            }
        })
    }
}
