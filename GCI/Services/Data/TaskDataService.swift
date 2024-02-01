//
//  TaskDataService.swift
//  GCI
//
//  Created by Florian ALONSO on 5/8/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

protocol TaskDataService {
    
    typealias TaskListCallback = (_ taskList: ViewModelResultCachable<[TaskViewModel]>) -> Void
    typealias TaskCallback = (_ taskList: ViewModelResult<TaskViewModel>) -> Void
    typealias StepCallback = (_ step: ViewModelResult<TaskViewModel>) -> Void
    typealias TaskCreatedCallback = (_ taskList: ViewModelResult<CreatedTaskViewModel>) -> Void
    typealias StepCreatedCallback = (_ task: ViewModelResult<TaskViewModel>) -> Void
    typealias AssignationUsersCallback = (_ taskList: ViewModelResult<[TaskUserViewModel]>) -> Void
    typealias AssignationServiceCallback = (_ taskList: ViewModelResult<[ServiceViewModel]>) -> Void
    typealias StatusCallback = (_ result: UIResult) -> Void

    func taskList(withAForcedRefresh forceRefresh: Bool, completion: @escaping TaskListCallback)
    func task(byId id: Int, withAForcedRefresh forceRefresh: Bool, completion: @escaping TaskCallback)
    func updateWithoutEdition(task: TaskViewModel, completion: @escaping TaskCallback)
    func update(task: TaskViewModel, completion: @escaping TaskCallback)
    func update(step: StepViewModel, oldAttachment: AttachmentViewModel?, completion: @escaping StepCallback)
    func update(createdStep: CreatedStepViewModel, completion: @escaping TaskDataService.StepCallback)
    func add(fromCreatedTask createdTask: CreatedTaskViewModel, withCompletion completion: @escaping TaskCreatedCallback)
    func addWithoutAutoSync(fromCreatedTask createdTask: CreatedTaskViewModel, withCompletion completion: @escaping TaskCreatedCallback)
    func forceSyncronizeNewTask(fromCreatedTask createdTask: CreatedTaskViewModel, withCompletion completion: @escaping StatusCallback)
    func forceSyncronizeEditedTask(fromTask task: TaskViewModel, withCompletion completion: @escaping TaskCallback)
    func assignableUser(forTask task: TaskViewModel, withCompletion completion: @escaping AssignationUsersCallback)
    func changeService(forTask task: TaskViewModel, title: String?, description: String?, toService service: ServiceViewModel, withCompletion completion: @escaping TaskCallback)
    func addStep(fromCreatedStep createdStep: CreatedStepViewModel, withCompletion completion: @escaping StepCreatedCallback)
    func forceSynchronizeNewStep(fromCreatedStep createdStep: CreatedStepViewModel, withCompletion completion: @escaping StatusCallback)
     func forceSyncronizeEditedStep(fromStep step: StepViewModel, taskID: Int, withCompletion completion: @escaping StatusCallback)
    func availableServices(forTask task: TaskViewModel, completionHandler: @escaping AssignationServiceCallback)

}
