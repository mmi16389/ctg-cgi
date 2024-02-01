//
//  TaskActionnableManager.swift
//  GCI
//
//  Created by Florian ALONSO on 5/24/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

protocol TaskActionnableDelegate: class {
    
    typealias RejectAndTransferData = ( _ title: String, _ description: String, _ service: ServiceViewModel?) -> Void
    
    func showConfirmation(withMessage message: String, andNeverAskCode dialogCode: DialogCode?, withFinishedCompletion completion: @escaping () -> Void)
    
    func didFinishTaskAction(withResult result: ViewModelResult<TaskViewModel>, withMessage message: String?)
    
    func askFor(userSelection userList: [TaskUserViewModel], withSelectCompletion completion: @escaping (_ user: TaskUserViewModel) -> Void)
    
    func askFor(serviceSelection serviceList: [ServiceViewModel], withSelectCompletion completion: @escaping (_ service: ServiceViewModel) -> Void)
    
    func askFor(rejectAndTransfer serviceList: [ServiceViewModel], rejectMessages: [PrefilledMessageViewModel], withSelectCompletion completion: @escaping RejectAndTransferData)

    func askForExplanation(withTitle title: String, withDescrtion description: String, andValidationText validationText: String, withPrefilledValues prefilledValues: [PrefilledMessageViewModel], hasToQuitAfter: Bool, withCompletion completion: @escaping (_ title: String, _ desription: String) -> Void)
    
    func askForAddStepInfo(withCompletion completion: @escaping (_ title: String, _ desription: String, _ date: Date, _ attachementUrl: URL?) -> Void)
    func askForEditStepInfo(withCompletion completion: @escaping (_ selectStep: ViewableStep, _ title: String, _ desription: String, _ date: Date, _ attachementUrl: URL?, _ oldAttachementUrl: AttachmentViewModel?) -> Void)
    func askForStartOrEndStep(withCompletion completion: @escaping (_ date: Date) -> Void)
    
    func askForTaskEdition(forTask task: TaskViewModel, withCompletion completion: @escaping (_ task: TaskViewModel) -> Void)
    
    func askForNewNotSynchronizedTask(forTask task: TaskViewModel, withCompletion completion: @escaping (_ createdTask: CreatedTaskViewModel) -> Void)
}

class TaskActionnableManager {
    
    weak var delegate: TaskActionnableDelegate?
    
    private var internalWorkflowDataService: WorkflowDataService?
    private var internalTaskDataService: TaskDataService?
    private var internalAttachmentDataService: AttachmentDataService?
    private var internalUserDataService: UserDataService?
    
    func workflowDataService() -> WorkflowDataService {
        if internalWorkflowDataService == nil {
            internalWorkflowDataService = WorkflowDataServiceImpl()
        }
        return internalWorkflowDataService!
    }
    
    func attachmentDataService() -> AttachmentDataService {
        if internalAttachmentDataService == nil {
            internalAttachmentDataService = AttachmentDataServiceImpl()
        }
        return internalAttachmentDataService!
    }
    
    func taskDataService() -> TaskDataService {
        if internalTaskDataService == nil {
            internalTaskDataService = TaskDataServiceImpl()
        }
        return internalTaskDataService!
    }
    
    func userDataService() -> UserDataService {
        if internalUserDataService == nil {
            internalUserDataService = UserDataServiceImpl()
        }
        return internalUserDataService!
    }
    
    func launch(action: TaskAction, forTask task: TaskViewModel) {
        guard let executor = action.executor else {
            delegate?.didFinishTaskAction(withResult: .failed(.canceled), withMessage: nil)
            return
        }
        
        guard let confirmationMessage = action.confirmationMessage else {
            launchWithouConfirmation(forExecutor: executor, withAction: action, forTask: task)

            return
        }
        
        delegate?.showConfirmation(withMessage: confirmationMessage, andNeverAskCode: action.confirmationCode) {
            
            self.launchWithouConfirmation(forExecutor: executor, withAction: action, forTask: task)
        }
    }
    
    private func launchWithouConfirmation(forExecutor executor: TaskActionExecutor, withAction action: TaskAction, forTask task: TaskViewModel) {
        
        if executor.neededDataType != .none {
            askData(forExecutor: executor, withAction: action, forTask: task)
            return
        }
        
        executor.execute(withWorkflowService: workflowDataService(), andWithTaskService: taskDataService(), onTask: task) { (result) in
            
            switch result {
            case .value(let task):
                self.delegate?.didFinishTaskAction(withResult: .value(task), withMessage: executor.successMessage)
            case .failed(let error):
                
                switch error {
                case .noNetwork:
                    if executor.offlineEnabled {
                        self.delegate?.didFinishTaskAction(withResult: .failed(.noNetwork), withMessage: nil)
                    } else {
                        self.delegate?.didFinishTaskAction(withResult: .failed(.offlineNotAuthorized), withMessage: nil)
                    }
                default:
                    self.delegate?.didFinishTaskAction(withResult: .failed(error), withMessage: nil)
                }
            }
            executor.reset()
        }
    }
    
    private func askData(forExecutor executor: TaskActionExecutor, withAction action: TaskAction, forTask task: TaskViewModel) {
        
        let dataNeeded = executor.neededDataType
        switch dataNeeded {
        case .assign:
            askForAssignation(forExecutor: executor, withAction: action, forTask: task)
        case .cancel:
            askForExplanation(forExecutor: executor, withAction: action, forTask: task)
        case .service:
            askForServiceChange(forExecutor: executor, withAction: action, forTask: task)
        case .reject:
            askForExplanation(forExecutor: executor, withAction: action, forTask: task)
        case .stepAdd:
            self.addStep(forExecutor: executor, withAction: action, forTask: task)
        case .stepChooser:
            self.addStartOrEndStep(forExecutor: executor, withAction: action, forTask: task)
        case .stepEdit:
            self.editStep(forExecutor: executor, whithAction: action, fortask: task)
        case .taskEdit:
            askForTaskEdition(forExecutor: executor, withAction: action, forTask: task)
        case .taskNew:
            askForNewNotSynchronizedTask(forExecutor: executor, withAction: action, forTask: task)
        case .none:
            delegate?.didFinishTaskAction(withResult: .failed(.error), withMessage: nil)
        case .rejectAndTransfer:
            self.askForRejectAndTransfer(forExecutor: executor, withAction: action, forTask: task)
        }
    }
    
    private func askForNewNotSynchronizedTask(forExecutor executor: TaskActionExecutor, withAction action: TaskAction, forTask task: TaskViewModel) {
        self.delegate?.askForNewNotSynchronizedTask(forTask: task, withCompletion: { (createdTask) in
            executor.setNeededData(fromParams: [
                ActionParamType.createdTask: createdTask
                ])
            self.launchWithouConfirmation(forExecutor: executor, withAction: action, forTask: task)
        })
    }
    
    private func addStartOrEndStep(forExecutor executor: TaskActionExecutor, withAction action: TaskAction, forTask task: TaskViewModel) {
        self.delegate?.askForStartOrEndStep(withCompletion: { (date) in
            executor.setNeededData(fromParams: [
                ActionParamType.date: date
                ])
            self.launchWithouConfirmation(forExecutor: executor, withAction: action, forTask: task)
        })
    }
    
    private func editStep(forExecutor executor: TaskActionExecutor, whithAction action: TaskAction, fortask task: TaskViewModel) {
        self.delegate?.askForEditStepInfo(withCompletion: { (step, title, description, date, attachment, oldAttachment) in
            executor.setNeededData(fromParams: [
                ActionParamType.viewableStep: step,
                ActionParamType.title: title,
                ActionParamType.description: description,
                ActionParamType.date: date,
                ActionParamType.filePath: attachment,
                ActionParamType.oldAttachment: oldAttachment
                ])
            self.launchWithouConfirmation(forExecutor: executor, withAction: action, forTask: task)
        })
    }
    
    private func addStep(forExecutor executor: TaskActionExecutor, withAction action: TaskAction, forTask task: TaskViewModel) {
        self.delegate?.askForAddStepInfo(withCompletion: { (title, description, date, attachment) in
            executor.setNeededData(fromParams: [
                ActionParamType.title: title,
                ActionParamType.description: description,
                ActionParamType.date: date,
                ActionParamType.filePath: attachment
                ])
            self.launchWithouConfirmation(forExecutor: executor, withAction: action, forTask: task)
        })
    }
    
    private func askForTaskEdition(forExecutor executor: TaskActionExecutor, withAction action: TaskAction, forTask task: TaskViewModel) {
        self.delegate?.askForTaskEdition(forTask: task, withCompletion: { (task) in
            executor.setNeededData(fromParams: [
                ActionParamType.taskId: task.id
                ])
            self.launchWithouConfirmation(forExecutor: executor, withAction: action, forTask: task)
        })
    }
    
    private func askForAssignation(forExecutor executor: TaskActionExecutor, withAction action: TaskAction, forTask task: TaskViewModel) {
        taskDataService().assignableUser(forTask: task) { (result) in
            switch result {
            case .value(let users):
                self.delegate?.askFor(userSelection: users, withSelectCompletion: { (userSelected) in
                    executor.setNeededData(fromParams: [
                        ActionParamType.userId: userSelected.id
                        ])
                    
                    self.launchWithouConfirmation(forExecutor: executor, withAction: action, forTask: task)
                })
            case .failed(let error):
                self.delegate?.didFinishTaskAction(withResult: .failed(error), withMessage: nil)
            }
        }
    }
    
    private func askForRejectAndTransfer(forExecutor executor: TaskActionExecutor, withAction action: TaskAction, forTask task: TaskViewModel) {
        let completion = { (prefilledValues: [PrefilledMessageViewModel]) in
            let servicesAvailable = task.transferableServices.sorted()
            
            self.delegate?.askFor(rejectAndTransfer: servicesAvailable, rejectMessages: prefilledValues, withSelectCompletion: { (title, description, service) in
                executor.setNeededData(fromParams: [
                    ActionParamType.service: service,
                    ActionParamType.title: title,
                    ActionParamType.description: description
                    ])
                
                self.launchWithouConfirmation(forExecutor: executor, withAction: action, forTask: task)
            })
        }
        
        userDataService().rejectMessages(completion: completion)
    }
    
    private func askForServiceChange(forExecutor executor: TaskActionExecutor, withAction action: TaskAction, forTask task: TaskViewModel) {
        let servicesAvailable = task.transferableServices.sorted()
        guard !servicesAvailable.isEmpty else {
            self.delegate?.didFinishTaskAction(withResult: .failed(.error), withMessage: nil)
            return
        }
        
        self.delegate?.askFor(serviceSelection: servicesAvailable, withSelectCompletion: { (serviceSelected) in
            
            let messageOpt: String?
            let permissionList = serviceSelected.permissions
            if !permissionList.contains(ServiceViewModel.Permission.validate) {
                messageOpt = "service_transfert_confirmation_no_validation".localized
            } else if permissionList.count == 0 { //.contains(ServiceViewModel.Permission.read)
                messageOpt = "service_transfert_confirmation_no_read".localized
            } else {
                messageOpt = nil
            }
            
            let actionAfterCompletion = {
                executor.setNeededData(fromParams: [
                    ActionParamType.service: serviceSelected
                    ])
                
                self.launchWithouConfirmation(forExecutor: executor, withAction: action, forTask: task)
            }
            
            if let message = messageOpt {
                self.delegate?.showConfirmation(withMessage: message, andNeverAskCode: nil, withFinishedCompletion: actionAfterCompletion)
            } else {
                actionAfterCompletion()
            }
            
        })
    }
    
    private func askForExplanation(forExecutor executor: TaskActionExecutor, withAction action: TaskAction, forTask task: TaskViewModel) {
        
        let completion = { (prefilledValues: [PrefilledMessageViewModel]) in
            
            let title: String
            let description: String
            let validationText: String
            
            switch action {
            case .rejectWhenInProgress:
                title = "reject_page_title_reject".localized
                description = "reject_page_explanation".localized
                validationText = "task_action_reject".localized
            case .reject:
                title = "reject_page_title_reject".localized
                description = "reject_page_explanation".localized
                validationText = "task_action_reject".localized
            default:
                title = "reject_page_title_cancel".localized
                description = "reject_page_explanation".localized
                validationText = "task_action_cancel".localized
            }
            
            self.delegate?.askForExplanation(withTitle: title, withDescrtion: description, andValidationText: validationText, withPrefilledValues: prefilledValues, hasToQuitAfter: action == .cancel) { (title, description) in
                executor.setNeededData(fromParams: [
                    ActionParamType.title: title,
                    ActionParamType.description: description
                    ])
                
                self.launchWithouConfirmation(forExecutor: executor, withAction: action, forTask: task)
            }
        }
        
        switch action {
        case .reject:
            userDataService().rejectMessages(completion: completion)
        default:
            userDataService().cancelMessages(completion: completion)
        }
        
    }
}
