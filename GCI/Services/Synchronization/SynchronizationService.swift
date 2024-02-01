//
//  SynchronizationService.swift
//  GCI
//
//  Created by Florian ALONSO on 5/10/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

enum AfterUploadDownload {
    case no
    case standard
    case light
}

class SynchronizationService {
    typealias CreationCallback = (_ topOperation: GCIOperation?) -> Void
    typealias SynchronizationServiceCallback = (_ result: GCIOperationResult) -> Void
    
    static let shared = {
       return SynchronizationService()
    }()
    
    let callbackListLock = NSObject()
    var callbackList = [SynchronizationServiceCallback]()
    var topOperation: GCIOperation?
    var afterUploadDownload = AfterUploadDownload.no
    
    let taskDataService: TaskDataService = TaskDataServiceImpl()
    let taskDaoService: TaskDAOService = TaskDAOServiceImpl()
    let stepDaoService: StepDAOService = StepDAOServiceImpl()
    let referentialDataService: ReferentialDataService = ReferentialDataServiceImpl()
    let userDataService: UserDataService = UserDataServiceImpl()
    let configurationDataService: ConfigurationDataService = ConfigurationDataServiceImpl()
    let createdTaskDao: CreatedTaskDAOService = CreatedTaskDAOServiceImpl()
    let createdStepDao: CreatedStepDAOService = CreatedStepDAOServiceImpl()
    let workflowDAOService: WorkflowDAOService = WorkflowDAOServiceImpl()
    let workflowDataService: WorkflowDataService = WorkflowDataServiceImpl()
    let attachmentDataService: AttachmentDataService = AttachmentDataServiceImpl()
    let createdAttachmentDAOService: CreatedAttachmentDAOService = CreatedAttachmentDAOServiceImpl()
    let favoriteDataService: FavoriteDataService = FavoriteDataServiceImpl()
    let favoriteDaoService: FavoriteDAOService = FavoriteDAOServiceImpl()
    
    var isRunning: Bool {
        return topOperation != nil
    }
    
    private init() {
    }
    
    private func syncedCallback<RETURN>(closure: (_ callbackList: [SynchronizationServiceCallback]) -> (RETURN)) -> RETURN {
        let value: RETURN
        objc_sync_enter(callbackListLock)
        value = closure(self.callbackList)
        objc_sync_exit(callbackListLock)
        return value
    }
    
    func forceStop() { 
        self.topOperation = nil
        self.callbackList.removeAll()
    }
    
    func startDownSynchronization(withCompletion completion: @escaping SynchronizationServiceCallback = {_ in }) {
        if isRunning {
            self.syncedCallback {_ in
                self.callbackList.append(completion)
            }
            return
        }
        self.syncedCallback {_ in
            self.callbackList.append(completion)
        }
        
        let operation = operationForDownload()
        operation.delegate = self
        operation.start()
        self.topOperation = operation
    }
    
    func startLightDownSynchronization(withCompletion completion: @escaping SynchronizationServiceCallback = {_ in }) {
        if isRunning {
            self.syncedCallback {_ in
                self.callbackList.append(completion)
            }
            return
        }
        self.syncedCallback {_ in
            self.callbackList.append(completion)
        }
        
        let operation = lightOperationForDownload()
        operation.delegate = self
        operation.start()
        self.topOperation = operation
    }
    
    func startSynchronizationForStepChange(withCompletion completion: @escaping SynchronizationServiceCallback = {_ in }) {
        if isRunning {
            self.syncedCallback {_ in
                self.callbackList.append(completion)
            }
            return
        }
        self.syncedCallback {_ in
            self.callbackList.append(completion)
        }
        operationForStepChange { (topOperationOpt) in
            if let topOperation = topOperationOpt {
                topOperation.delegate = self
                topOperation.start()
                self.afterUploadDownload = .light
                self.topOperation = topOperation
            } else {
                self.startLightDownSynchronization()
            }
        }
    }
    
    func startSynchronizationForTaskChange(withCompletion completion: @escaping SynchronizationServiceCallback = {_ in }) {
        if isRunning {
            self.syncedCallback {_ in
                self.callbackList.append(completion)
            }
            return
        }
        self.syncedCallback {_ in
            self.callbackList.append(completion)
        }
        
        operationForTaskChange { (topOperationOpt) in
            if let topOperation = topOperationOpt {
                topOperation.delegate = self
                topOperation.start()
                self.afterUploadDownload = .light
                self.topOperation = topOperation
            } else {
                self.startLightDownSynchronization()
            }
        }
    }
    
    func startUpSynchronization(withCompletion completion: @escaping SynchronizationServiceCallback = {_ in }) {
        if isRunning {
            self.syncedCallback {_ in
                self.callbackList.append(completion)
            }
            return
        }
        self.syncedCallback {_ in
            self.callbackList.append(completion)
        }
        
        operationForUpload { (topOperationOpt) in
            if let topOperation = topOperationOpt {
                topOperation.delegate = self
                topOperation.start()
                self.afterUploadDownload = .standard
                self.topOperation = topOperation
            } else {
                self.startDownSynchronization()
            }
        }
    }
    
    private func lightOperationForDownload() -> GCIOperation {
        let favoriteOperation = FavoriteDownOperation(dataService: favoriteDataService)
        
        let taskOperation = TaskDownOperation(dataService: taskDataService, nextOperation: favoriteOperation)
        taskOperation.isBlocking = true
        
        let referentialOperation = ReferentialDownOperation(dataService: referentialDataService, nextOperation: taskOperation)
        referentialOperation.isBlocking = true
        
        return referentialOperation
    }
    
    private func operationForDownload() -> GCIOperation {
        let favoriteOperation = FavoriteDownOperation(dataService: favoriteDataService)
        
        let taskOperation = TaskDownOperation(dataService: taskDataService, nextOperation: favoriteOperation)
        taskOperation.isBlocking = true
        
        let userOperation = UserDownOperation(dataService: userDataService, nextOperation: taskOperation)
        
        let referentialOperation = ReferentialDownOperation(dataService: referentialDataService, nextOperation: userOperation)
        referentialOperation.isBlocking = true
        
        return ConfigurationDownOperation(dataService: configurationDataService, nextOperation: referentialOperation)
    }
    
    private func operationForStepChange(_ completion: @escaping CreationCallback) {
        self.operationForStepEdition(withNext: nil) { (topOperationStepEdition) in
            if let topOperationStepEdition = topOperationStepEdition {
                topOperationStepEdition.isBlocking = true
            }
            self.operationForStepCreation(withNext: topOperationStepEdition) { (topOperationStepCreation) in
                completion(topOperationStepCreation)
            }
        }
    }
    
    private func operationForTaskChange(_ completion: @escaping CreationCallback) {
        self.operationForTaskEdition(withNext: nil) { (topOperationTaskEdition) in
            if let topOperationTaskEdition = topOperationTaskEdition {
                topOperationTaskEdition.isBlocking = true
            }
            self.operationForTaskCreation(withNext: topOperationTaskEdition) { (topOperationTaskCreation) in
                completion(topOperationTaskCreation)
            }
        }
    }
    
    private func operationForUpload(_ completion: @escaping CreationCallback) {
        self.operationForTaskEdition(withNext: nil) { (topOperationTaskEdition) in
            if let topOperationTaskEdition = topOperationTaskEdition {
                topOperationTaskEdition.isBlocking = true
            }
            
            self.operationForStepEdition(withNext: topOperationTaskEdition, andCompletion: { (topOperationStepEdition) in
                self.operationForStepCreation(withNext: topOperationStepEdition, andCompletion: { (topOperationStepCreation) in
                    if let topOperationStepCreation = topOperationStepCreation {
                        topOperationStepCreation.isBlocking = true
                    }
                    
                    self.operationForTaskCreation(withNext: topOperationStepCreation) { (topOperationTaskCreation) in
                        
                        self.operationForFavoriteUpload(withNext: topOperationStepCreation, andCompletion: { (topOperationFavorite) in
                            
                            self.operationForUploadWorkflows(withNext: topOperationFavorite) { (topOperationWorkflow) in
                                completion(topOperationWorkflow)
                            }
                        })
                    }
                })                
            })
        }
    }
    
    private func operationForUploadWorkflows(withNext nextOperation: GCIOperation?, andCompletion completion: @escaping CreationCallback) {
        workflowDAOService.allOrdered { (actionWorkflows) in
            
            guard !actionWorkflows.isEmpty else {
                completion(nextOperation)
                return
            }
            
            var lastCreated = nextOperation
            for workflow in actionWorkflows {
                if let createdAttachment = workflow.createdTask?.createdAttachment,
                    let attachmentId = createdAttachment.fileName {
                    let stepCreation = WorkflowUpOperation(forId: Int(workflow.internalId),
                                                           dataService: self.workflowDataService,
                                                           daoService: self.workflowDAOService,
                                                           nextOperation: nil)
                    
                    let attachmentUpload = CreatedAttachmentUpOperation(forId: attachmentId,
                                                                        dataServce: self.attachmentDataService,
                                                                        daoService: self.createdAttachmentDAOService,
                                                                        nextOperation: nil)
                    
                    lastCreated = GCIOperationPaired(nextOperation: lastCreated,
                                                     operationPairedOne: attachmentUpload,
                                                     operationPairedTwo: stepCreation)
                } else {
                    lastCreated = WorkflowUpOperation(forId: Int(workflow.internalId),
                                                      dataService: self.workflowDataService,
                                                      daoService: self.workflowDAOService,
                                                      nextOperation: lastCreated)
                }
                lastCreated?.isBlocking = true
                
            }
            completion(lastCreated)
        }
    }
    
     private func operationForStepCreation(withNext nextOperation: GCIOperation?, andCompletion completion: @escaping CreationCallback) {
        createdStepDao.allPending { (createdSteps) in
            guard !createdSteps.isEmpty else {
                completion(nextOperation)
                return
            }
            
            var lastCreated = nextOperation
            for created in createdSteps {
                if let createdAttachment = created.createdAttachment, let attachmentId = createdAttachment.fileName {
                    let stepCreation = CreatedStepUpOperation(forId: Int(created.internalId),
                                                              taskDataService: self.taskDataService,
                                                              createdDaoService: self.createdStepDao,
                                                              nextOperation: nil)
                    let attachmentUpload = CreatedAttachmentUpOperation(forId: attachmentId,
                                                                        dataServce: self.attachmentDataService,
                                                                        daoService: self.createdAttachmentDAOService,
                                                                        nextOperation: nil)
                    
                    lastCreated = GCIOperationPaired(nextOperation: lastCreated,
                                                     operationPairedOne: attachmentUpload,
                                                     operationPairedTwo: stepCreation)
                } else {
                    lastCreated = CreatedStepUpOperation(forId: Int(created.internalId),
                                                         taskDataService: self.taskDataService,
                                                         createdDaoService: self.createdStepDao,
                                                         nextOperation: lastCreated)
                }
            }
            completion(lastCreated)
        }
    }
    
    private func operationForTaskCreation(withNext nextOperation: GCIOperation?, andCompletion completion: @escaping CreationCallback) {
        createdTaskDao.allPending { (createdTasks) in
            
            guard !createdTasks.isEmpty else {
                completion(nextOperation)
                return
            }
            
            var lastCreated = nextOperation
            for created in createdTasks {
                if let createdAttachment = created.createdAttachment, let attachmentId = createdAttachment.fileName {
                    
                    let taskCreation = CreatedTaskUpOperation(forId: Int(created.internalId),
                                                              taskDataService: self.taskDataService,
                                                              createdDaoService: self.createdTaskDao,
                                                              nextOperation: nil)
                    let attachmentUpload = CreatedAttachmentUpOperation(forId: attachmentId,
                                                                        dataServce: self.attachmentDataService,
                                                                        daoService: self.createdAttachmentDAOService,
                                                                        nextOperation: nil)
                    
                    lastCreated = GCIOperationPaired(nextOperation: lastCreated,
                                                     operationPairedOne: attachmentUpload,
                                                     operationPairedTwo: taskCreation)
                    
                } else {
                    lastCreated = CreatedTaskUpOperation(forId: Int(created.internalId),
                                                         taskDataService: self.taskDataService,
                                                         createdDaoService: self.createdTaskDao,
                                                         nextOperation: lastCreated)
                }
                
            }
            completion(lastCreated)
        }
    }
    
    private func operationForStepEdition(withNext nextOperation: GCIOperation?, andCompletion completion: @escaping CreationCallback) {
        stepDaoService.allModified { (editedSteps) in
            guard !editedSteps.isEmpty else {
                completion(nextOperation)
                return
            }
            
            var lastCreated = nextOperation
            for edit in editedSteps {
                if let createdAttachment = edit.createdAttachment, let attachmentId = createdAttachment.fileName {
                    let stepEdition = StepEditionUpOperation(forId: Int(edit.id),
                                                              taskDataService: self.taskDataService,
                                                              daoService: self.stepDaoService,
                                                              nextOperation: nil)
                    let attachmentUpload = CreatedAttachmentUpOperation(forId: attachmentId,
                                                                        dataServce: self.attachmentDataService,
                                                                        daoService: self.createdAttachmentDAOService,
                                                                        nextOperation: nil)
                    
                    lastCreated = GCIOperationPaired(nextOperation: lastCreated,
                                                     operationPairedOne: attachmentUpload,
                                                     operationPairedTwo: stepEdition)
                } else {
                    lastCreated = StepEditionUpOperation(forId: Int(edit.id),
                                                         taskDataService: self.taskDataService,
                                                         daoService: self.stepDaoService,
                                                         nextOperation: lastCreated)
                }
            }
            completion(lastCreated)
        }
    }
    
    private func operationForTaskEdition(withNext nextOperation: GCIOperation?, andCompletion completion: @escaping CreationCallback) {
        taskDaoService.allModified { (editedTasks) in
            
            guard !editedTasks.isEmpty else {
                completion(nextOperation)
                return
            }
            
            var lastCreated = nextOperation
            for task in editedTasks {
                if let createdAttachment = task.createdAttachment, let attachmentId = createdAttachment.fileName {
                    
                    let taskCreation = TaskEditionUpOperation(forId: Int(task.id),
                                                              dataService: self.taskDataService,
                                                              daoService: self.taskDaoService,
                                                              nextOperation: nil)
                    let attachmentUpload = CreatedAttachmentUpOperation(forId: attachmentId,
                                                                        dataServce: self.attachmentDataService,
                                                                        daoService: self.createdAttachmentDAOService,
                                                                        nextOperation: nil)
                    
                    lastCreated = GCIOperationPaired(nextOperation: lastCreated,
                                                     operationPairedOne: attachmentUpload,
                                                     operationPairedTwo: taskCreation)
                    
                } else {
                    lastCreated = TaskEditionUpOperation(forId: Int(task.id),
                                                         dataService: self.taskDataService,
                                                         daoService: self.taskDaoService,
                                                         nextOperation: lastCreated)
                }
                
            }
            completion(lastCreated)
        }
    }
    
    private func operationForFavoriteUpload(withNext nextOperation: GCIOperation?, andCompletion completion: @escaping CreationCallback) {
        favoriteDaoService.allAction { (actionList) in
            guard !actionList.isEmpty else {
                completion(nextOperation)
                return
            }
            
            var lastCreated = nextOperation
            for actionFav in actionList {
                lastCreated = FavoriteUpOperation(forId: Int(actionFav.taskId),
                                                  dataService: self.favoriteDataService ,
                                                  daoService: self.favoriteDaoService,
                                                     nextOperation: lastCreated)
            }
            completion(lastCreated)
        }
        
        createdTaskDao.allPending { (createdTasks) in
            
            guard !createdTasks.isEmpty else {
                completion(nextOperation)
                return
            }
            
            var lastCreated = nextOperation
            for created in createdTasks {
                if let createdAttachment = created.createdAttachment, let attachmentId = createdAttachment.fileName {
                    
                    let taskCreation = CreatedTaskUpOperation(forId: Int(created.internalId),
                                                              taskDataService: self.taskDataService,
                                                              createdDaoService: self.createdTaskDao,
                                                              nextOperation: nil)
                    let attachmentUpload = CreatedAttachmentUpOperation(forId: attachmentId,
                                                                        dataServce: self.attachmentDataService,
                                                                        daoService: self.createdAttachmentDAOService,
                                                                        nextOperation: nil)
                    
                    lastCreated = GCIOperationPaired(nextOperation: lastCreated,
                                                     operationPairedOne: attachmentUpload,
                                                     operationPairedTwo: taskCreation)
                    
                } else {
                    lastCreated = CreatedTaskUpOperation(forId: Int(created.internalId),
                                                         taskDataService: self.taskDataService,
                                                         createdDaoService: self.createdTaskDao,
                                                         nextOperation: lastCreated)
                }
                
            }
            completion(lastCreated)
        }
    }
    
}

extension SynchronizationService: GCIOperationDelegate {
    func didFinish(operation: GCIOperation, withResult result: GCIOperationResult) {
        if case GCIOperationResult.success = result, afterUploadDownload != .no {
            let rememberAction = self.afterUploadDownload
            self.topOperation = nil
            self.afterUploadDownload = .no
            
            switch rememberAction {
            case .light:
                startLightDownSynchronization()
            default:
                startDownSynchronization()
            }
            return
        }
        
        var toProcess = [SynchronizationServiceCallback]()
        syncedCallback {
            $0.forEach {
                toProcess.append($0)
            }
            self.callbackList.removeAll()
            self.topOperation = nil
            self.afterUploadDownload = .no
        }
        
        toProcess.forEach {
            $0(result)
        }
    }
}
