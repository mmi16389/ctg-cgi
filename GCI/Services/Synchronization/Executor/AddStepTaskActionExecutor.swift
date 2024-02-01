//
//  addStepTaskActionExecutor.swift
//  GCI
//
//  Created by Anthony Chollet on 24/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class AddStepTaskActionExecutor: TaskActionExecutor {
    var title: String?
    var date: Date?
    var attachmentPath: URL?
    var comment: String?
    
    let offlineEnabled = true
    var neededDataType: ActionDataType {
        guard let _ = title, let _ = date, let _ = comment else {
            return .stepAdd
        }
        return .none
    }
    let successMessage = "task_action_step_custom_success".localized
    
    func reset() {
        title = nil
        date = nil
        attachmentPath = nil
        comment = nil
    }
    
    func checkOrApplyChange(forTask task: TaskViewModel) -> Bool {
        return true
    }
    
    func setNeededData(fromParams params: ActionParams) {
        title = params[ActionParamType.title] as? String
        comment = params[ActionParamType.description] as? String
        attachmentPath = params[ActionParamType.filePath] as? URL
        date = params[ActionParamType.date] as? Date
    }
    
    func prefilledObject(fromTask task: TaskViewModel) -> Any? {
        guard let title = self.title, let comment = self.comment, let date = self.date else {
            return nil
        }
        
        var createdAttachment: CreatedAttachmentViewModel?
        if let attachmentPath = attachmentPath {
            createdAttachment = CreatedAttachmentViewModel(fileName: attachmentPath.lastPathComponent)
        }
        let step = CreatedStepViewModel(taskId: task.id, action: .standard, date: date, title: title, description: comment, createdAttachment: createdAttachment)
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
                    taskService.task(byId: task.id, withAForcedRefresh: false, completion: { (result) in
                            switch result {
                            case .value(let task):
                                completion(.value(task))
                            case .failed(let error):
                                completion(.failed(error))
                            }
                    })
                    
                default :
                    completion(.failed(.error))
                }
            }
        }
    }
}
