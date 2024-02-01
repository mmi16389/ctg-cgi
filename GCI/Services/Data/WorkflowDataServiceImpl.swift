//
//  WorkflowDataServiceImpl.swift
//  GCI
//
//  Created by Florian ALONSO on 5/23/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class WorkflowDataServiceImpl: NSObject, WorkflowDataService {
    
    var internalDaoService: WorkflowDAOService?
    var internalApiService: WorkflowAPIService?
    var internalLoginDataService: LoginDataService?
    var internalTaskDaoService: TaskDAOService?
    var internalAttachmentService: AttachmentDataService?
    var internalCreatedAttachmentDAOService: CreatedAttachmentDAOService?
    
    override init() {
        super.init()
    }
    
    func daoService() -> WorkflowDAOService {
        if internalDaoService == nil {
            self.internalDaoService = WorkflowDAOServiceImpl()
        }
        return internalDaoService!
    }
    
    func apiService() -> WorkflowAPIService {
        if internalApiService == nil {
            self.internalApiService = WorkflowAPIServiceImpl()
        }
        return internalApiService!
    }
    
    func loginService() -> LoginDataService {
        if internalLoginDataService == nil {
            self.internalLoginDataService = LoginDataServiceImpl()
        }
        return internalLoginDataService!
    }
    
    func taskDaoService() -> TaskDAOService {
        if internalTaskDaoService == nil {
            self.internalTaskDaoService = TaskDAOServiceImpl()
        }
        return internalTaskDaoService!
    }
    
    func attchmentDataService() -> AttachmentDataService {
        if internalAttachmentService == nil {
            self.internalAttachmentService = AttachmentDataServiceImpl()
        }
        return internalAttachmentService!
    }
    
    func createdAttachmentDAOService() -> CreatedAttachmentDAOService {
        if internalCreatedAttachmentDAOService == nil {
            self.internalCreatedAttachmentDAOService = CreatedAttachmentDAOServiceImpl()
        }
        return internalCreatedAttachmentDAOService!
    }
    
    func launchActionWorkflow(withOfflineEnabled offlineEnabled: Bool, onViewModel viewModel: ActionWorkflowViewModel, completion: @escaping StatusCallback) {
        loginService().makeSecureAPICall {
            
            switch viewModel.workflowAction {
            case .next:
                self.launchActionWorkflowNext(withOfflineEnabled: offlineEnabled, onViewModel: viewModel, completion: completion)
            case .cancel:
                self.launchActionWorkflowCancel(withOfflineEnabled: offlineEnabled, onViewModel: viewModel, completion: completion)
            case .reject:
                self.launchActionWorkflowReject(withOfflineEnabled: offlineEnabled, onViewModel: viewModel, completion: completion)
            case .undo:
                self.launchActionWorkflowUndo(withOfflineEnabled: offlineEnabled, onViewModel: viewModel, completion: completion)
            }
        }
    }
    
    func forceSynchronization(forAction action: ActionWorkflow, completion: @escaping StatusCallback) {
        guard let viewModel = ActionWorkflowViewModel.from(db: action) else {
            completion(.failed(.error))
            return
        }
        
        launchActionWorkflow(withOfflineEnabled: false, onViewModel: viewModel, completion: completion)
    }
    
    // MARK: GENERIC Workflow API callback
    
    private func networkCompletionHandler(withOfflineEnabled offlineEnabled: Bool, onViewModel viewModel: ActionWorkflowViewModel, completion: @escaping StatusCallback) -> RequestJSONCallback {
        
        return { (jsonOpt, requestStatus) in
            if requestStatus == .shouldRelogin {
                User.currentUser()?.invalidateToken()
                self.launchActionWorkflow(withOfflineEnabled: offlineEnabled, onViewModel: viewModel, completion: completion)
            } else if requestStatus == .noInternet && offlineEnabled {
                // The request failed due to offline mode and it's allowed
                self.daoService().add(fromViewModel: viewModel) { (resultOpt) in
                    DispatchQueue.main.async {
                        completion(resultOpt == nil ? .failed(ViewModelError.from(networkRequest: requestStatus)) : .success)
                    }
                }
            } else if requestStatus == .noInternet && !offlineEnabled {
                DispatchQueue.main.async {
                    completion(.failed(.noNetwork))
                }
            } else if requestStatus == .success {
                
                if let json = jsonOpt {
                    // HANDLING DATA SUCCESS
                    self.taskDaoService().saveResponse(fromJson: json, completion: { (updatedTaskOp) in
                        DispatchQueue.main.async {
                            completion(updatedTaskOp == nil ? .failed(ViewModelError.from(networkRequest: requestStatus)) : .success)
                        }
                    })
                    
                } else {
                    DispatchQueue.main.async {
                        completion(.success)
                    }
                }
                
            } else {
                DispatchQueue.main.async {
                    completion(.failed(ViewModelError.from(networkRequest: requestStatus)))
                }
            }
        }
    }
    
    // MARK: Workflow calls
    private func launchActionWorkflowNext(withOfflineEnabled offlineEnabled: Bool, onViewModel viewModel: ActionWorkflowViewModel, completion: @escaping StatusCallback) {
        let networkCompletion = self.networkCompletionHandler(withOfflineEnabled: offlineEnabled, onViewModel: viewModel, completion: completion)
        
        if let createdAttachment = viewModel.createdTask?.createdAttachment,
            createdAttachment.uuid == nil {
            // Created attachment exist without beiing sync
            // Need to sync file
            attchmentDataService().upload(fromFileUrl: createdAttachment.fileUrl) { (result) in
                switch result {
                case .value(let newUUID):
                    self.createdAttachmentDAOService().updatedUUID(byId: createdAttachment.identifier, withNewUUID: newUUID, completion: { (success) in
                        viewModel.createdTask?.createdAttachment?.uuid = newUUID
                        self.apiService().next(forViewModel: viewModel, completionHandler: networkCompletion)
                    })
                case .failed(let error):
                    completion(.failed(error))
                }
            }
        } else {
            self.apiService().next(forViewModel: viewModel, completionHandler: networkCompletion)
        }
    }
    
    private func launchActionWorkflowUndo(withOfflineEnabled offlineEnabled: Bool, onViewModel viewModel: ActionWorkflowViewModel, completion: @escaping StatusCallback) {
        let networkCompletion = self.networkCompletionHandler(withOfflineEnabled: offlineEnabled, onViewModel: viewModel, completion: completion)
        self.apiService().undo(forViewModel: viewModel, completionHandler: networkCompletion)
    }
    
    private func launchActionWorkflowCancel(withOfflineEnabled offlineEnabled: Bool, onViewModel viewModel: ActionWorkflowViewModel, completion: @escaping StatusCallback) {
        let networkCompletion = self.networkCompletionHandler(withOfflineEnabled: offlineEnabled, onViewModel: viewModel, completion: completion)
        self.apiService().cancel(forViewModel: viewModel, completionHandler: networkCompletion)
    }
    
    private func launchActionWorkflowReject(withOfflineEnabled offlineEnabled: Bool, onViewModel viewModel: ActionWorkflowViewModel, completion: @escaping StatusCallback) {
        let networkCompletion = self.networkCompletionHandler(withOfflineEnabled: offlineEnabled, onViewModel: viewModel, completion: completion)
        self.apiService().reject(forViewModel: viewModel, completionHandler: networkCompletion)
    }
}
