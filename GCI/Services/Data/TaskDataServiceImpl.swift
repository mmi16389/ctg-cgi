//
//  TaskDataServiceImpl.swift
//  GCI
//
//  Created by Florian ALONSO on 5/8/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class TaskDataServiceImpl: NSObject, TaskDataService {
    
    var internalDaoService: TaskDAOService?
    var internalStepDaoService: StepDAOService?
    var internalCreatedDaoService: CreatedTaskDAOService?
    var internalCreatedStepDaoService: CreatedStepDAOService?
    var internalApiService: TaskAPIService?
    var internalApiStepService: StepAPIService?
    var internalLoginDataService: LoginDataService?
    var internalReferentialDaoService: ReferentialDaoService?
    
    override init() {
        super.init()
    }
    
    func createdDaoService() -> CreatedTaskDAOService {
        if internalCreatedDaoService == nil {
            self.internalCreatedDaoService = CreatedTaskDAOServiceImpl()
        }
        return internalCreatedDaoService!
    }
    
    func createdStepDaoService() -> CreatedStepDAOService {
        if internalCreatedStepDaoService == nil {
            self.internalCreatedStepDaoService = CreatedStepDAOServiceImpl()
        }
        return internalCreatedStepDaoService!
    }
    
    func daoService() -> TaskDAOService {
        if internalDaoService == nil {
            self.internalDaoService = TaskDAOServiceImpl()
        }
        return internalDaoService!
    }
    
    func stepDaoService() -> StepDAOService {
        if internalStepDaoService == nil {
            self.internalStepDaoService = StepDAOServiceImpl()
        }
        return internalStepDaoService!
    }
    
    func apiStepService() -> StepAPIService {
        if internalApiStepService == nil {
            self.internalApiStepService = StepAPIServiceImpl()
        }
        return internalApiStepService!
    }
    
    func apiService() -> TaskAPIService {
        if internalApiService == nil {
            self.internalApiService = TaskAPIServiceImpl()
        }
        return internalApiService!
    }
    
    func loginService() -> LoginDataService {
        if internalLoginDataService == nil {
            self.internalLoginDataService = LoginDataServiceImpl()
        }
        return internalLoginDataService!
    }
    
    func daoReferentialService() -> ReferentialDaoService {
        if internalReferentialDaoService == nil {
            self.internalReferentialDaoService = ReferentialDaoServiceImpl()
        }
        return internalReferentialDaoService!
    }
    
    func taskList(withAForcedRefresh forceRefresh: Bool, completion: @escaping TaskDataService.TaskListCallback) {
        daoService().all { (taskList) in
            TaskViewModel.from(dbList: taskList) {
                completion(.cached($0))
            }
            let alreadyKnowsIds = taskList.map { Int($0.id) }
            DispatchQueue.global().async {
                var shouldRefresh = true
                let lastDateFetchOpt = UserDefaultManager.shared.lastTaskListRequestDate
                if let lastDateFetch = lastDateFetchOpt {
                    let diff = Date().timeIntervalSince(lastDateFetch)
                    shouldRefresh = diff > Constant.API.Durations.fetchDelayTasks
                }
                
                if shouldRefresh || forceRefresh {
                    
                    self.loginService().makeSecureAPICall {
                        self.apiService().taskList(alreadyKnowsIds: alreadyKnowsIds, completionHandler: { (jsonOpt, requestStatus) in
                            
                            if requestStatus == .shouldRelogin {
                                User.currentUser()?.invalidateToken()
                                self.taskList(withAForcedRefresh: forceRefresh, completion: completion)
                                return
                            } else if requestStatus == .noInternet {
                                DispatchQueue.main.async {
                                    completion(.failed(.noNetwork))
                                }
                                return
                            } else if requestStatus == .success {
                                if let json = jsonOpt {
                                    
                                    self.daoService().saveResponses(fromJson: json, completion: { (taskListUpdated) in
                                        
                                        TaskViewModel.from(dbList: taskListUpdated) {
                                            completion(.value($0))
                                        }
                                    })
                                    
                                } else {
                                    self.daoService().all { (taskList) in
                                        TaskViewModel.from(dbList: taskList) {
                                            completion(.value($0))
                                        }
                                    }
                                }
                                
                            } else {
                                DispatchQueue.main.async {
                                    completion(.failed(ViewModelError.from(networkRequest: requestStatus)))
                                }
                            }
                        })
                        
                    }
                } else {
                    self.daoService().all { (taskList) in
                        TaskViewModel.from(dbList: taskList) {
                            completion(.value($0))
                        }
                    }
                }
            }
        }
    }
    
    func task(byId id: Int, withAForcedRefresh forceRefresh: Bool, completion: @escaping TaskDataService.TaskCallback) {
        self.daoService().unique(byId: id) { (taskOpt) in
            if let task = taskOpt, !forceRefresh {
                TaskViewModel.from(db: task) {
                    completion($0 == nil ? .failed(.error) : .value($0!))
                }
                return
            }
            
            self.loginService().makeSecureAPICall {
                self.apiService().task(byId: id, completionHandler: { (jsonOpt, requestStatus) in
                    if requestStatus == .shouldRelogin {
                        User.currentUser()?.invalidateToken()
                        self.task(byId: id, withAForcedRefresh: forceRefresh, completion: completion)
                        return
                    } else if requestStatus == .noInternet {
                        DispatchQueue.main.async {
                            completion(.failed(.noNetwork))
                        }
                        return
                    } else if requestStatus == .success, let json = jsonOpt {
                        
                        self.daoService().saveResponse(fromJson: json, completion: { (taskUpdatedOpt) in
                            guard let taskUpdated = taskUpdatedOpt else {
                                DispatchQueue.main.async {
                                    completion(.failed(.error))
                                }
                                return
                            }
                            TaskViewModel.from(db: taskUpdated) {
                                completion($0 == nil ? .failed(.error) : .value($0!))
                            }
                        })
                        
                    } else {
                        DispatchQueue.main.async {
                            completion(.failed(ViewModelError.from(networkRequest: requestStatus)))
                        }
                    }
                })
            }
            
        }
    }
    
    func updateWithoutEdition(task: TaskViewModel, completion: @escaping TaskDataService.TaskCallback) {
        daoService().update(fromViewModel: task) { (taskUpdatedOpt) in
            let result: ViewModelResult<TaskViewModel>
            if let taskUpdated = taskUpdatedOpt,
                let parsedViewModel = TaskViewModel.from(db: taskUpdated) {
                result = .value(parsedViewModel)
            } else {
                result = .failed(.error)
            }
            
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func update(task: TaskViewModel, completion: @escaping TaskDataService.TaskCallback) {
        task.isModified = true // Forcing the edition things
        daoService().update(fromViewModel: task) { (taskUpdatedOpt) in
            let result: ViewModelResult<TaskViewModel>
            if let taskUpdated = taskUpdatedOpt,
                let parsedViewModel = TaskViewModel.from(db: taskUpdated) {
                result = .value(parsedViewModel)
            } else {
                result = .failed(.error)
            }
            
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func update(createdStep: CreatedStepViewModel, completion: @escaping TaskDataService.StepCallback) {
        createdStepDaoService().update(fromViewModel: createdStep) { (createdStepUpdatedOpt) in
            guard let update = createdStepUpdatedOpt, let viewModel = CreatedStepViewModel.from(db: update) else {
                completion(.failed(.error))
                return
            }
            
            SynchronizationService.shared.startSynchronizationForStepChange(withCompletion: { (result) in
                switch result {
                case .success:
                    self.daoService().unique(byId: viewModel.taskId, completion: { (taskOpt) in
                        guard let task = taskOpt, let viewModel = TaskViewModel.from(db: task) else {
                            completion(.failed(.error))
                            return
                        }
                        completion(.value(viewModel))
                    })
                case .noInternet:
                    completion(.failed(.noNetwork))
                default:
                    completion(.failed(.error))
                }
            })
        }
    }
    
    func update(step: StepViewModel, oldAttachment: AttachmentViewModel?, completion: @escaping TaskDataService.StepCallback) {
        stepDaoService().update(fromViewModel: step, oldAttachment: oldAttachment) { (stepUpdatedOpt) in
            guard let update = stepUpdatedOpt, let viewModel = StepViewModel.from(db: update) else {
                completion(.failed(.error))
                return
            }
            
            SynchronizationService.shared.startSynchronizationForStepChange(withCompletion: { (result) in
                switch result {
                case .success:
                    self.stepDaoService().unique(byId: viewModel.id, completion: { (step) in
                        if let step = step, let taskID = step.task?.id {
                            self.daoService().unique(byId: Int(taskID), completion: { (taskOpt) in
                                guard let task = taskOpt, let viewModel = TaskViewModel.from(db: task) else {
                                    completion(.failed(.error))
                                    return
                                }
                                completion(.value(viewModel))
                            })
                        } else {
                            completion(.failed(.error))
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
    
    func add(fromCreatedTask createdTask: CreatedTaskViewModel, withCompletion completion: @escaping TaskCreatedCallback) {
        
        createdDaoService().add(fromViewModel: createdTask) { (createdOpt) in
            guard let created = createdOpt, let viewModel = CreatedTaskViewModel.from(db: created) else {
                completion(.failed(.error))
                return
            }
            
            SynchronizationService.shared.startSynchronizationForTaskChange(withCompletion: { (result) in
                switch result {
                case .success:
                    completion(.value(viewModel))
                case .noInternet:
                    completion(.failed(.noNetwork))
                default:
                    completion(.failed(.error))
                }
            })
        }
    }
    
    func addStep(fromCreatedStep createdStep: CreatedStepViewModel, withCompletion completion: @escaping StepCreatedCallback) {
        createdStepDaoService().add(fromViewModel: createdStep) { (createdOpt) in
            guard let created = createdOpt, let viewModel = CreatedStepViewModel.from(db: created) else {
                completion(.failed(.error))
                return
            }
            
            SynchronizationService.shared.startSynchronizationForStepChange(withCompletion: { (result) in
                switch result {
                case .success:
                    self.daoService().unique(byId: viewModel.taskId, completion: { (taskOpt) in
                        guard let task = taskOpt, let viewModel = TaskViewModel.from(db: task) else {
                            completion(.failed(.error))
                            return
                        }
                        completion(.value(viewModel))
                    })
                case .noInternet:
                    completion(.failed(.noNetwork))
                default:
                    completion(.failed(.error))
                }
            })
        }
    }
    
    func addWithoutAutoSync(fromCreatedTask createdTask: CreatedTaskViewModel, withCompletion completion: @escaping TaskCreatedCallback) {
        createdDaoService().add(fromViewModel: createdTask) { (createdOpt) in
            guard let created = createdOpt, let viewModel = CreatedTaskViewModel.from(db: created)  else {
                completion(.failed(.error))
                return
            }
            completion(.value(viewModel))
        }
    }
    
    func forceSynchronizeNewStep(fromCreatedStep createdStep: CreatedStepViewModel, withCompletion completion: @escaping StatusCallback) {
        self.loginService().makeSecureAPICall {
            self.apiStepService().create(fromViewModel: createdStep, completionHandler: { (jsonOpt, requestStatus) in
                if requestStatus == .shouldRelogin {
                    User.currentUser()?.invalidateToken()
                    self.forceSynchronizeNewStep(fromCreatedStep: createdStep, withCompletion: completion)
                    return
                } else if requestStatus == .noInternet {
                    DispatchQueue.main.async {
                        completion(.failed(.noNetwork))
                    }
                    return
                } else if requestStatus == .success, let json = jsonOpt {
                    
                    self.daoService().saveResponse(fromJson: json, completion: { (taskUpdatedOpt) in
                        completion(taskUpdatedOpt == nil ? .failed(.error) : .success)
                    })
                    
                } else {
                    DispatchQueue.main.async {
                        completion(.failed(ViewModelError.from(networkRequest: requestStatus)))
                    }
                }
            })
        }
    }
    
    func forceSyncronizeNewTask(fromCreatedTask createdTask: CreatedTaskViewModel, withCompletion completion: @escaping StatusCallback) {
        self.loginService().makeSecureAPICall {
            
            self.apiService().create(fromViewModel: createdTask, completionHandler: { (jsonOpt, requestStatus) in
                if requestStatus == .shouldRelogin {
                    User.currentUser()?.invalidateToken()
                    self.forceSyncronizeNewTask(fromCreatedTask: createdTask, withCompletion: completion)
                    return
                } else if requestStatus == .noInternet {
                    DispatchQueue.main.async {
                        completion(.failed(.noNetwork))
                    }
                    return
                } else if requestStatus == .success, let json = jsonOpt {
                    
                    self.daoService().saveResponse(fromJson: json, completion: { (taskUpdatedOpt) in
                        completion(taskUpdatedOpt == nil ? .failed(.error) : .success)
                    })
                    
                } else {
                    DispatchQueue.main.async {
                        completion(.failed(ViewModelError.from(networkRequest: requestStatus)))
                    }
                }
            })
        }
    }
    
    func forceSyncronizeEditedTask(fromTask task: TaskViewModel, withCompletion completion: @escaping TaskCallback) {
        self.loginService().makeSecureAPICall {
            
            self.apiService().update(fromViewModel: task, completionHandler: { (jsonOpt, requestStatus) in
                
                if requestStatus == .shouldRelogin {
                    User.currentUser()?.invalidateToken()
                    self.forceSyncronizeEditedTask(fromTask: task, withCompletion: completion)
                    return
                } else if requestStatus == .noInternet {
                    DispatchQueue.main.async {
                        completion(.failed(.noNetwork))
                    }
                    return
                } else if requestStatus == .success, let json = jsonOpt {
                    
                    self.daoService().saveResponse(fromJson: json, completion: { (taskUpdatedOpt) in
                        guard let taskDb = taskUpdatedOpt,
                            let viewModel = TaskViewModel.from(db: taskDb) else {
                                completion(.failed(.error))
                                return
                        }
                        completion(.value(viewModel))
                    })
                    
                } else {
                    DispatchQueue.main.async {
                        completion(.failed(ViewModelError.from(networkRequest: requestStatus)))
                    }
                }
                
            })
        }
    }
    
    func forceSyncronizeEditedStep(fromStep step: StepViewModel, taskID: Int, withCompletion completion: @escaping StatusCallback) {
        self.loginService().makeSecureAPICall {
            self.apiStepService().update(fromViewModel: step, taskID: taskID, completionHandler: { (jsonOpt, requestStatus) in
                
                if requestStatus == .shouldRelogin {
                    User.currentUser()?.invalidateToken()
                    self.forceSyncronizeEditedStep(fromStep: step, taskID: taskID, withCompletion: completion)
                    return
                } else if requestStatus == .noInternet {
                    DispatchQueue.main.async {
                        completion(.failed(.noNetwork))
                    }
                    return
                } else if requestStatus == .success, let json = jsonOpt {
                    
                    self.daoService().saveResponse(fromJson: json, completion: { (taskUpdatedOpt) in
                        completion(taskUpdatedOpt == nil ? .failed(.error) : .success)
                    })
                    
                } else {
                    DispatchQueue.main.async {
                        completion(.failed(ViewModelError.from(networkRequest: requestStatus)))
                    }
                }
                
            })
        }
    }
    
    func assignableUser(forTask task: TaskViewModel, withCompletion completion: @escaping AssignationUsersCallback) {
        loginService().makeSecureAPICall {
            
            self.apiService().assignableUser(forTaskId: task.id, completionHandler: { (jsonOpt, requestStatus) in
                if requestStatus == .shouldRelogin {
                    User.currentUser()?.invalidateToken()
                    self.assignableUser(forTask: task, withCompletion: completion)
                    return
                } else if requestStatus == .noInternet {
                    DispatchQueue.main.async {
                        completion(.failed(.noNetwork))
                    }
                    return
                } else if requestStatus == .success, let json = jsonOpt {
                    
                    // Convert + Sort
                    var taskUserViewModels: [TaskUserViewModel] = json["users"].arrayValue.flatMap {
                        guard let id = $0["id"].string, !id.isEmpty else {
                            return nil
                        }
                        return TaskUserViewModel(id: id,
                                                 firstname: $0["firstname"].stringValue,
                                                 lastname: $0["lastname"].stringValue,
                                                 roles: $0["roles"].arrayValue.flatMap { $0.string })
                    }
                    taskUserViewModels.sort()
                    
                    DispatchQueue.main.async {
                        completion(.value(taskUserViewModels))
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        completion(.failed(ViewModelError.from(networkRequest: requestStatus)))
                    }
                }
            })
        }
    }
    
    func changeService(forTask task: TaskViewModel, title: String?, description: String?, toService service: ServiceViewModel, withCompletion completion: @escaping TaskCallback) {
        
        loginService().makeSecureAPICall {
            
            self.apiService().changeService(forTaskId: task.id, toServiceId: service.id, title: title, description: description, completionHandler: { (jsonOpt, requestStatus) in
                
                if requestStatus == .shouldRelogin {
                    User.currentUser()?.invalidateToken()
                    self.changeService(forTask: task, title: title, description: description, toService: service, withCompletion: completion)
                    return
                } else if requestStatus == .noInternet {
                    DispatchQueue.main.async {
                        completion(.failed(.noNetwork))
                    }
                    return
                } else if requestStatus == .success, let json = jsonOpt {
                    
                    self.daoService().saveResponse(fromJson: json, completion: { (taskUpdatedOpt) in
                        guard let taskUpdated = taskUpdatedOpt else {
                            DispatchQueue.main.async {
                                completion(.failed(.error))
                            }
                            return
                        }
                        TaskViewModel.from(db: taskUpdated) {
                            completion($0 == nil ? .failed(.error) : .value($0!))
                        }
                    })
                    
                } else {
                    DispatchQueue.main.async {
                        completion(.failed(ViewModelError.from(networkRequest: requestStatus)))
                    }
                }
            })
            
        }
    }
    
    func availableServices(forTask task: TaskViewModel, completionHandler: @escaping AssignationServiceCallback) {
        self.loginService().makeSecureAPICall {
            
            self.apiService().availableServices(forTaskId: task.id, completionHandler: { (servicesIdList, requestStatus) in
                
                if requestStatus == .shouldRelogin {
                    User.currentUser()?.invalidateToken()
                    self.availableServices(forTask: task, completionHandler: completionHandler)
                    return
                } else if requestStatus == .success {
                    
                    self.daoReferentialService().services(byIds: servicesIdList, completion: { (serviceList) in
                        
                        let serviceList = ServiceViewModel.from(dbList: serviceList)
                        
                        DispatchQueue.main.async {
                            completionHandler(serviceList.isEmpty ? .failed(.error) : .value(serviceList))
                        }
                        
                    })
                    
                } else {
                    DispatchQueue.main.async {
                        completionHandler(.failed(ViewModelError.from(networkRequest: requestStatus)))
                    }
                }
            })
        }
    }
    
}
