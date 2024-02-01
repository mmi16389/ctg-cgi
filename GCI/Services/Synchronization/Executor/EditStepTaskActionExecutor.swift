//
//  editStepExecutor.swift
//  GCI
//
//  Created by Anthony Chollet on 26/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class EditStepTaskActionExecutor: TaskActionExecutor {
    var title: String?
    var date: Date?
    var attachmentPath: URL?
    var oldAttachment: AttachmentViewModel?
    var comment: String?
    var step: ViewableStep?
    
    let offlineEnabled = true
    var neededDataType: ActionDataType {
        guard let _ = step, let _ = title, let _ = date, let _ = comment else {
            return .stepEdit
        }
        return .none
    }
    let successMessage = "task_action_step_edit_success".localized
    
    func reset() {
        title = nil
        date = nil
        attachmentPath = nil
        comment = nil
        step = nil
        oldAttachment = nil
    }
    
    func checkOrApplyChange(forTask task: TaskViewModel) -> Bool {
        return true
    }
    
    func setNeededData(fromParams params: ActionParams) {
        title = params[ActionParamType.title] as? String
        comment = params[ActionParamType.description] as? String
        attachmentPath = params[ActionParamType.filePath] as? URL
        date = params[ActionParamType.date] as? Date
        step = params[ActionParamType.viewableStep] as? ViewableStep
        oldAttachment = params[ActionParamType.oldAttachment] as? AttachmentViewModel
    }
    
    func prefilledObject(fromTask task: TaskViewModel) -> Any? {
        guard let vieawableStep = self.step, let title = self.title, let comment = self.comment, let date = self.date else {
            return nil
        }
        
        var createdAttachment: CreatedAttachmentViewModel?
        if let attachmentPath = attachmentPath {
            createdAttachment = CreatedAttachmentViewModel(fileName: attachmentPath.lastPathComponent)
        }
        
        if vieawableStep.isPendingStep, let vieawableStep = vieawableStep as? CreatedStepViewModel {
            return CreatedStepViewModel(internalId: vieawableStep.internalId, taskId: task.id, action: vieawableStep.action, date: date, title: title, description: comment, createdAttachment: createdAttachment)
        } else if let vieawableStep = vieawableStep as? StepViewModel {
            return StepViewModel(id: vieawableStep.id, date: date, title: title, description: comment, action: vieawableStep.action, attachment: oldAttachment, createdAttachment: createdAttachment)
        }
        
        return nil
    }
    
    func execute(withWorkflowService workflowService: WorkflowDataService, andWithTaskService taskService: TaskDataService, onTask task: TaskViewModel, withCompletion completion: @escaping TaskActionCompletion) {
        guard let prefilled = prefilledObject(fromTask: task) as? ViewableStep else {
            DispatchQueue.main.async {
                completion(.failed(.error))
            }
            return
        }
        
        let completion: (_ result: ViewModelResult<TaskViewModel>) -> Void = { result in
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
        
        if prefilled.isPendingStep, let prefilled = prefilled as? CreatedStepViewModel {
            taskService.update(createdStep: prefilled, completion: completion)
        } else if let prefilled = prefilled as? StepViewModel {
            taskService.update(step: prefilled, oldAttachment: oldAttachment, completion: completion)
        }
    }
}
