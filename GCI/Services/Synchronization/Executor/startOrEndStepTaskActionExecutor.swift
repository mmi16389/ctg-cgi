//
//  startOrEndStepTaskActionExecutor.swift
//  GCI
//
//  Created by Anthony Chollet on 24/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class StartOrEndStepTaskActionExecutor: TaskActionExecutor {
    var date: Date?
    var isStart: Bool
    
    init(isStart: Bool) {
        self.isStart = isStart
    }
    
    let offlineEnabled = true
    var neededDataType: ActionDataType {
        guard let _ = date else {
            return .stepChooser
        }
        return .none
    }
    let successMessage = "task_action_step_custom_success".localized
    
    func reset() {
        date = nil
    }
    
    func checkOrApplyChange(forTask task: TaskViewModel) -> Bool {
        return true
    }
    
    func setNeededData(fromParams params: ActionParams) {
        date = params[ActionParamType.date] as? Date
    }
    
    func prefilledObject(fromTask task: TaskViewModel) -> Any? {
        guard let date = self.date else {
            return nil
        }
        
        var step: CreatedStepViewModel?
        if isStart {
            step = CreatedStepViewModel(taskId: task.id, action: .start, date: date, title: "", description: "", createdAttachment: nil)
        } else {
            step = CreatedStepViewModel(taskId: task.id, action: .end, date: date, title: "", description: "", createdAttachment: nil)
        }
        return step
    }
    
    func execute(withWorkflowService workflowService: WorkflowDataService, andWithTaskService taskService: TaskDataService, onTask task: TaskViewModel, withCompletion completion: @escaping TaskActionCompletion) {
        guard let prefilled = prefilledObject(fromTask: task) as? CreatedStepViewModel else {
            DispatchQueue.main.async {
                completion(.failed(.error))
            }
            return
        }
        
        taskService.addStep(fromCreatedStep: prefilled) { (result) in
            switch result {
            case .value(let task):
                
                completion(.value(task))
            case .failed(let error):
                
                switch error {
                case .noNetwork:
                    guard self.offlineEnabled else {
                        completion(.failed(.noNetwork))
                        return
                    }
                    completion(.value(task))
                    
                default :
                    completion(.failed(.error))
                }
            }
        }
    }
}
