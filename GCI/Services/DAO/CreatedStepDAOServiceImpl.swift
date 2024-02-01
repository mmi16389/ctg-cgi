//
//  CreatedStepDAOServiceImpl.swift
//  GCI
//
//  Created by Anthony Chollet on 24/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import CoreStore

class CreatedStepDAOServiceImpl: CreatedStepDAOService {

    func allPending(completion: @escaping ListCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> [CreatedStep] in
            let list = try transaction.fetchAll(
                From<CreatedStep>()
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
    
    func unique(byId idParam: Int, completion: @escaping UniqueCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> CreatedStep? in
            let object = try transaction.fetchOne(
                From<CreatedStep>()
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
    
    func delete(byId idParam: Int, completion: @escaping StatusCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Bool in
            let object: CreatedStep? = try transaction.fetchOne(
                From<CreatedStep>()
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

    func deleteAll(completion: @escaping StatusCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Bool in
            let list = try transaction.fetchAll(
                From<CreatedStep>()
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
    
    func update(fromViewModel viewModel: CreatedStepViewModel, completion: @escaping CreatedStepDAOService.UniqueCallback) {
        
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> CreatedStep? in
            
            let idToFind = Int64(viewModel.internalId)
            
            let step = try? transaction.fetchOne(
                From<CreatedStep>()
                    .where(\.internalId == idToFind)
            )
            
            step?.action = Int16(viewModel.action.rawValue)
            step?.title = viewModel.title
            step?.date = viewModel.date
            step?.desc = viewModel.description
            
            if let createdAttachment = viewModel.createdAttachment {
                let idToFind = createdAttachment.fileUrl.lastPathComponent
                
                var dbObject = try? transaction.fetchOne(
                    From<CreatedAttachment>()
                        .where(\.fileName == idToFind)
                )
                
                if dbObject == nil {
                    dbObject = transaction.create(Into<CreatedAttachment>())
                }
                dbObject?.fileName = idToFind
                step?.createdAttachment = dbObject
            } else {
                step?.createdAttachment = nil
            }
            
            return step
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
    
    func add(fromViewModel viewModel: CreatedStepViewModel, completion: @escaping UniqueCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> CreatedStep? in
            
            let taskOpt = try transaction.fetchOne(
                From<Task>()
                    .where(\.id == Int64(viewModel.taskId))
            )
            
            let maxIdOpt = try CoreStoreDefaults.dataStack.queryValue(
                From<CreatedStep>()
                    .select(Int.self, .maximum(\.internalId))
            )
            
            var maxId = 0
            if let safeMaxId = maxIdOpt {
                maxId = safeMaxId
            }
            
            guard let task = taskOpt else {
                return nil
            }
            
            let createdStep = transaction.create(Into<CreatedStep>())
            createdStep.internalId = Int64(maxId + 1)
            if viewModel.action == .standard {
                createdStep.title = viewModel.title
                createdStep.desc = viewModel.description
            } else {
                createdStep.title = ""
                createdStep.desc = ""
            }
            createdStep.date = viewModel.date
            createdStep.task = task
            createdStep.action = Int16(viewModel.action.rawValue)
            
            if let newAttachment = viewModel.createdAttachment {
                let createdAttachment = transaction.create(Into<CreatedAttachment>())
                createdAttachment.fileName = newAttachment.fileUrl.lastPathComponent
                createdStep.createdAttachment = createdAttachment
            }
            
            return createdStep
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
