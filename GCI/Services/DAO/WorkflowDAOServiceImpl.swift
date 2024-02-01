//
//  WorkflowDAOServiceImpl.swift
//  GCI
//
//  Created by Florian ALONSO on 5/23/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreStore

class WorkflowDAOServiceImpl: WorkflowDAOService {
    
    func allOrdered(completion: @escaping WorkflowDAOService.ListCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> [ActionWorkflow] in
            let list = try transaction.fetchAll(
                From<ActionWorkflow>()
                    .orderBy(.descending(\.date))
            )
            
            return list
        }) { (result) -> Void in
            switch result {
            case .success(let list):
                completion(list)
            case .failure(let error):
                print(error)
                completion([])
            }
        }
    }
    
    func unique(byId idParam: Int, completion: @escaping WorkflowDAOService.UniqueCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> ActionWorkflow? in
            let object = try transaction.fetchOne(
                From<ActionWorkflow>()
                    .where(\.internalId == Int64(idParam))
            )
            
            return object
        }) { (result) -> Void in
            switch result {
            case .success(let object):
                completion(object)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    func delete(byId idParam: Int, completion: @escaping WorkflowDAOService.StatusCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Bool in
            let object: ActionWorkflow? = try transaction.fetchOne(
                From<ActionWorkflow>()
                    .where(\.internalId == Int64(idParam))
            )
            
            transaction.delete(object)
            
            return true
        }) { (result) -> Void in
            switch result {
            case .success(let returned):
                completion(returned)
            case .failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    func deleteAllPending(completion: @escaping WorkflowDAOService.StatusCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Bool in
            let list = try transaction.fetchAll(
                From<ActionWorkflow>()
            )
            
            list.forEach {
                transaction.delete($0)
            }
            
            return true
        }) { (result) -> Void in
            switch result {
            case .success(let returned):
                completion(returned)
            case .failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    func add(fromViewModel viewModel: ActionWorkflowViewModel, completion: @escaping WorkflowDAOService.UniqueCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> ActionWorkflow? in
            
            let taskOpt = try transaction.fetchOne(
                From<Task>()
                    .where(\.id == Int64(viewModel.taskId))
            )
            
            let maxIdOpt = try CoreStoreDefaults.dataStack.queryValue(
                From<ActionWorkflow>()
                    .select(Int.self, .maximum(\.internalId))
            )
            
            var maxId = 0
            if let safeMaxId = maxIdOpt {
                maxId = safeMaxId
            }
            
            guard let task = taskOpt else {
                return nil
            }
            
            let action = transaction.create(Into<ActionWorkflow>())
            action.internalId = Int64(maxId + 1)
            action.task = task
            action.date = viewModel.date
            action.desc = viewModel.description
            action.title = viewModel.title
            action.taskAction = Int16(viewModel.taskAction.rawValue)
            action.workflowAction = Int16(viewModel.workflowAction.rawValue)
            action.userId = viewModel.userId
        
            if let managedId = viewModel.createdTask?.internalManagedId {
                
                let createdTaskId = managedId
                let createdTask = try transaction.fetchOne(
                    From<CreatedTask>()
                        .where(\.internalId == Int64(createdTaskId))
                )
                
                action.createdTask = createdTask
            }
            
            return action
        }) { (result) -> Void in
            switch result {
            case .success(let returned):
                completion(returned)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
}
