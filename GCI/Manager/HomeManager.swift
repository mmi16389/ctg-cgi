//
//  HomeManager.swift
//  GCI
//
//  Created by Anthony Chollet on 13/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class HomeManager: NSObject {
    
    typealias CategoriesCompletionHandler = (_ categories: [TaskCategory]) -> Void
    typealias TaskCompletionHandler = (_ task: TaskViewModel?, _ error: ViewModelError?) -> Void
    typealias FavoriteCompletionHandler = (_ isSuccess: Bool, _ error: ViewModelError?) -> Void
    typealias TasksListCompletionHandler = (_ categories: [TaskViewModel]?, _ fromCache: Bool, _ error: ViewModelError?) -> Void
    typealias SynchViewModelCompletionHandler = (_ synchInfo: GCIOperationResult) -> Void
    
    var internalTaskDataService: TaskDataService?
    var internalFavoriteDataService: FavoriteDataService?
    
    func taskDataService() -> TaskDataService {
        if internalTaskDataService == nil {
            internalTaskDataService = TaskDataServiceImpl()
        }
        return internalTaskDataService!
    }
    
    func favoriteDataService() -> FavoriteDataService {
        if internalFavoriteDataService == nil {
            internalFavoriteDataService = FavoriteDataServiceImpl()
        }
        return internalFavoriteDataService!
    }
    
    func getAllTaskCategories(completionHandler: @escaping CategoriesCompletionHandler) {
        DispatchQueue.global().async {
            var categories = [TaskCategory]()
            
            if let user = User.currentUser() {
                if user.isCategoryVisible(TaskCategory.new) {
                    categories.append(TaskCategory.new)
                }
                if user.isCategoryVisible(TaskCategory.validated) {
                    categories.append(TaskCategory.validated)
                }
                if user.isCategoryVisible(TaskCategory.assigned) {
                    categories.append(TaskCategory.assigned)
                }
                if user.isCategoryVisible(TaskCategory.inProgress) {
                    categories.append(TaskCategory.inProgress)
                }
                if user.isCategoryVisible(TaskCategory.finished) {
                    categories.append(TaskCategory.finished)
                }
            }
            
            DispatchQueue.main.async {
                completionHandler(categories)
            }
        }
    }

    func getAllTask(completionHandler: @escaping TasksListCompletionHandler) {
        taskDataService().taskList(withAForcedRefresh: false) { (result) in
            switch result {
            case .cached(let taskList):
                completionHandler(taskList, true, nil)
            case .value(let taskList):
                completionHandler(taskList, false, nil)
            case .failed(let error):
                completionHandler(nil, false, error)
            }
        }
    }
    
    func getTask(byId id: Int, completion: @escaping TaskCompletionHandler) {
        taskDataService().task(byId: id, withAForcedRefresh: false) { (result) in
            switch result {
                
            case .value(let task):
                completion(task, nil)
            case .failed(let error):
                completion(nil, error)
            }
        }
    }
    
    func getAllTaskForCategory(category: TaskCategory, completionHandler: @escaping TasksListCompletionHandler) {
        self.getAllTask { (taskList, isCached, error) in
            if let taskList = taskList, let user = User.currentUser() {
                let filterTasks = taskList.filter({ $0.category(forUser: user) == category })
                completionHandler(filterTasks, isCached, error)
            }
            completionHandler(nil, isCached, error)
        }
    }
    
    func getDisplayTasksWithNoFilter(completionHandler: @escaping TasksListCompletionHandler) {
        if let user = User.currentUser() {
            getAllTaskCategories { (categories) in
                self.getAllTask(completionHandler: { (taskList, isCached, error) in
                    completionHandler(taskList?.filter({ categories.contains($0.category(forUser: user)) }), isCached, error)
                })
            }
        }
    }
    
    func lauchLightSync(completionHandler: @escaping SynchViewModelCompletionHandler) {
        SynchronizationService.shared.startLightDownSynchronization { (result) in
            
            switch result {
                
            case .success:
                completionHandler(.success)
            default:
                completionHandler(result)
            }
        }
    }
    
    func setFavorite(forTask task: TaskViewModel, isFavorite: Bool, completionHandler: @escaping FavoriteCompletionHandler) {
        if isFavorite {
            favoriteDataService().setTaskAsFavorite(byTaskId: task.id) { (result) in
                switch result {
                case .success:
                    completionHandler(true, nil)
                case .failed(let error):
                    completionHandler(false, error)
                }
            }
        } else {
            favoriteDataService().removeTaskAsFavorite(byTaskId: task.id) { (result) in
                switch result {
                case .success:
                    completionHandler(true, nil)
                case .failed(let error):
                    completionHandler(false, error)
                }
            }
        }
    }
}
