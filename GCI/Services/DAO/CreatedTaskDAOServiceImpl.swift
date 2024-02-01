//
//  CreatedTaskDAOServiceImpl.swift
//  GCI
//
//  Created by Florian ALONSO on 6/3/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import CoreStore

class CreatedTaskDAOServiceImpl: CreatedTaskDAOService {
    
    func allPending(completion: @escaping ListCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> [CreatedTask] in
            let list = try transaction.fetchAll(
                From<CreatedTask>(),
                Where<CreatedTask>("actionWorkflow = nil")
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
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> CreatedTask? in
            let object = try transaction.fetchOne(
                From<CreatedTask>()
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
            let object: CreatedTask? = try transaction.fetchOne(
                From<CreatedTask>()
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
                From<CreatedTask>()
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
    
    func add(fromViewModel viewModel: CreatedTaskViewModel, completion: @escaping UniqueCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> CreatedTask? in
            let maxIdOpt = try CoreStoreDefaults.dataStack.queryValue(
                From<CreatedTask>()
                    .select(Int.self, .maximum(\.internalId))
            )
            
            var maxId = 0
            if let safeMaxId = maxIdOpt {
                maxId = safeMaxId
            }
            
            let createdTask = transaction.create(Into<CreatedTask>())
            createdTask.internalId = Int64(maxId + 1)
            createdTask.title = viewModel.title
            createdTask.isUrgent = viewModel.isUrgent
            createdTask.creationDate = viewModel.creationDate
            createdTask.comment = viewModel.comment
            createdTask.transmitterComment = viewModel.transmitterComment
            
            let serviceIdList = viewModel.otherService.map { $0.id }
            let predicate = NSPredicate(format: "id IN %@", serviceIdList)
            let otherServices = try? transaction.fetchAll(
                From<Service>(),
                Where<Service>(predicate)
            )
            createdTask.otherServices = NSSet(array: otherServices ?? [])
            
            createdTask.domain = try? transaction.fetchOne(
                From<Domain>()
                    .where(\.id == Int64(viewModel.domain.id))
            )
            createdTask.service = try? transaction.fetchOne(
                From<Service>()
                    .where(\.id == Int64(viewModel.service.id))
            )
            
            if let newAttachment = viewModel.createdAttachment {
                let createdAttachment = transaction.create(Into<CreatedAttachment>())
                createdAttachment.fileName = newAttachment.fileUrl.lastPathComponent
                createdTask.createdAttachment = createdAttachment
            }
            
            if let interventionType = viewModel.interventionType {
                createdTask.interventionType = try? transaction.fetchOne(
                    From<InterventionType>()
                        .where(\.id == Int64(interventionType.id))
                )
            } else {
                createdTask.interventionComment = viewModel.interventionComment
            }
            
            if let patrimory = viewModel.patrimony {
                var patrimonyOpt = try? transaction.fetchOne(
                    From<TaskPatrimony>()
                        .where(\.id == Int64(patrimory.id))
                )
                
                if patrimonyOpt == nil {
                    patrimonyOpt = transaction.create(Into<TaskPatrimony>())
                    patrimonyOpt?.id = Int64(patrimory.id)
                    patrimonyOpt?.key = patrimory.key
                }
                createdTask.patrimony = patrimonyOpt
                createdTask.patrimonyComment = viewModel.patrimonyComment
            }
            
            if let locationViewModel = viewModel.location {
                let location = transaction.create(Into<TaskLocation>())
                location.address = locationViewModel.address
                location.comment = locationViewModel.comment
                location.point = locationViewModel.pointAsString
                location.srid = Int32(locationViewModel.srid)
                createdTask.location = location
            }
            
            return createdTask
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
