//
//  TaskActionExecutor.swift
//  GCI
//
//  Created by Florian ALONSO on 5/20/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

enum ActionDataType {
    case none
    case cancel
    case reject
    case stepAdd
    case assign
    case service
    case stepChooser
    case stepEdit
    case taskNew
    case taskEdit
    case rejectAndTransfer
}

enum ActionParamType {
    case title
    case description
    case userId
    case date
    case stepId
    case pendingStep
    case filePath
    case oldAttachment
    case taskId
    case createdTask
    case service
    case viewableStep
}

protocol TaskActionExecutor {
    
    typealias TaskActionCompletion = (_ result: ViewModelResult<TaskViewModel>) -> Void
    typealias ActionParams = [ActionParamType: Any]
    
    var offlineEnabled: Bool { get }
    var neededDataType: ActionDataType { get }
    var successMessage: String { get }
    
    func reset()
    func checkOrApplyChange(forTask task: TaskViewModel) -> Bool
    func setNeededData(fromParams params: ActionParams)
    func prefilledObject(fromTask task: TaskViewModel) -> Any?
    
    func execute(withWorkflowService workflowService: WorkflowDataService, andWithTaskService taskService: TaskDataService, onTask task: TaskViewModel, withCompletion completion: @escaping TaskActionCompletion)
}

// MARK: Utils functions for Workflow
extension TaskActionExecutor {
    
    func launchActionWorkflow(forAction action: ActionWorkflowViewModel, withWorkflowService workflowService: WorkflowDataService, andWithTaskService taskService: TaskDataService, onTask task: TaskViewModel, withCompletion completion: @escaping TaskActionExecutor.TaskActionCompletion) {
        
        let hasSomeCreatedSteps = !task.createdSteps.isEmpty
        let isModified = task.isModified
        
        if action.taskAction == .finish && hasSomeCreatedSteps {
            // The created step should be uploaded first
            let syncCompletion = synchronizationCompletion(forAction: action, withWorkflowService: workflowService, andWithTaskService: taskService, onTask: task, withCompletion: completion)
            SynchronizationService.shared.startSynchronizationForStepChange(withCompletion: syncCompletion)
        } else if action.taskAction == .validate && isModified {
            // The modification should be uploaded be force validating
            let syncCompletion = synchronizationCompletion(forAction: action, withWorkflowService: workflowService, andWithTaskService: taskService, onTask: task, withCompletion: completion)
            SynchronizationService.shared.startSynchronizationForTaskChange(withCompletion: syncCompletion)
        } else {
            self.launchActionWorkflowWithoutSync(forAction: action, withWorkflowService: workflowService, andWithTaskService: taskService, onTask: task, withCompletion: completion)
        }
    }
    
    private func synchronizationCompletion(forAction action: ActionWorkflowViewModel, withWorkflowService workflowService: WorkflowDataService, andWithTaskService taskService: TaskDataService, onTask task: TaskViewModel, withCompletion completion: @escaping TaskActionExecutor.TaskActionCompletion) -> SynchronizationService.SynchronizationServiceCallback {
        return { (result) in
            
            switch result {
            case .success:
                self.launchActionWorkflowWithoutSync(forAction: action, withWorkflowService: workflowService, andWithTaskService: taskService, onTask: task, withCompletion: completion)
            default:
                if self.offlineEnabled {
                    self.launchActionWorkflowWithoutSync(forAction: action, withWorkflowService: workflowService, andWithTaskService: taskService, onTask: task, withCompletion: completion)
                } else {
                    completion(.failed(.denied))
                }
            }
        }
    }
    
    private func launchActionWorkflowWithoutSync(forAction action: ActionWorkflowViewModel, withWorkflowService workflowService: WorkflowDataService, andWithTaskService taskService: TaskDataService, onTask task: TaskViewModel, withCompletion completion: @escaping TaskActionExecutor.TaskActionCompletion) {
        
        workflowService.launchActionWorkflow(withOfflineEnabled: offlineEnabled, onViewModel: action) { (result) in
            
            switch result {
            case .success:
                taskService.task(byId: task.id, withAForcedRefresh: false, completion: { (viewModelResult) in
                    switch viewModelResult {
                    case .value(let task):
                        
                        let changeHasBeenMade = self.checkOrApplyChange(forTask: task)
                        if changeHasBeenMade {
                            // Should re save the task
                            taskService.updateWithoutEdition(task: task) { (result) in
                                completion(result)
                            }
                            
                        } else {
                            DispatchQueue.main.async {
                                completion(.value(task))
                            }
                        }
                        
                    case .failed(let error):
                        DispatchQueue.main.async {
                            completion(.failed(error))
                        }
                    }
                })
                
            case .failed(let error):
                DispatchQueue.main.async {
                    completion(.failed(error))
                }
            }
        }
    }
}
