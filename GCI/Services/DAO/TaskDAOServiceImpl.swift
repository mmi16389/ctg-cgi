//
//  TaskDAOServiceImpl.swift
//  GCI
//
//  Created by Florian ALONSO on 5/8/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreStore

class TaskDAOServiceImpl: TaskDAOService {
    
    func all(completion: @escaping TaskDAOService.ListCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> [Task] in
                let list = try transaction.fetchAll(
                    From<Task>()
                        .where(\.activated == true)
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
    
    func allModified(completion: @escaping ListCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> [Task] in
            let list = try transaction.fetchAll(
                From<Task>()
                    .where(\.activated == true)
                    .where(\.isModified == true)
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
    
    func unique(byId idParam: Int, completion: @escaping TaskDAOService.UniqueCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Task? in
            let object = try transaction.fetchOne(
                From<Task>()
                    .where(\.id == Int64(idParam))
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
    
    func delete(byId idParam: Int, completion: @escaping TaskDAOService.StatusCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Bool in
            let object: Task? = try transaction.fetchOne(
                From<Task>()
                    .where(\.id == Int64(idParam))
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
    
    func deleteAll(completion: @escaping TaskDAOService.StatusCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Bool in
            let list = try transaction.fetchAll(
                From<Task>()
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
    
    func update(fromViewModel viewModel: TaskViewModel, completion: @escaping TaskDAOService.UniqueCallback) {
        
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Task? in
            
            let idToFind = Int64(viewModel.id)
            
            let task = try? transaction.fetchOne(
                From<Task>()
                    .where(\.id == idToFind)
            )
            
            task?.activated = viewModel.isActivated
            task?.isFavorite = viewModel.isFavorite
            task?.isModified = viewModel.isModified
            task?.status = Int16(viewModel.status.rawValue)
            task?.isUrgent = viewModel.isUrgent
            task?.comment = viewModel.comment
            
            if let interventionType = viewModel.interventionType {
                task?.interventionType = try? transaction.fetchOne(
                    From<InterventionType>()
                        .where(\.id == Int64(interventionType.id))
                )
                task?.interventionComment = nil
            } else {
                task?.interventionComment = viewModel.interventionTypeComment
                task?.interventionType = nil
            }
            
            if let domain = viewModel.domain {
                task?.domain = try? transaction.fetchOne(
                    From<Domain>()
                        .where(\.id == Int64(domain.id))
                )
            }
            
            if let service = viewModel.service {
                task?.service = try? transaction.fetchOne(
                    From<Service>()
                        .where(\.id == Int64(service.id))
                )
                
                let serviceIdList = viewModel.otherServices.map { $0.id }
                let predicate = NSPredicate(format: "id IN %@", serviceIdList)
                let otherServices = try? transaction.fetchAll(
                    From<Service>(),
                    Where<Service>(predicate)
                )
                task?.otherServices = NSSet(array: otherServices ?? [])
            }
            
            if let location = viewModel.location {
                let idToFind = location.pointAsString
                
                var dbObject = try? transaction.fetchOne(
                    From<TaskLocation>()
                        .where(\.point == idToFind)
                )
                
                if dbObject == nil {
                    dbObject = transaction.create(Into<TaskLocation>())
                }
                dbObject?.address = location.address
                dbObject?.point = location.pointAsString
                dbObject?.comment = location.comment
                dbObject?.srid = Int32(location.srid)
                task?.location = dbObject
            } else {
                task?.location = nil
            }
            
            if let patrimony = viewModel.patrimony {
                let idToFind = patrimony.id
                
                var dbObject = try? transaction.fetchOne(
                    From<TaskPatrimony>()
                        .where(\.id == Int64(idToFind))
                )
                
                if dbObject == nil {
                    dbObject = transaction.create(Into<TaskPatrimony>())
                }
                dbObject?.id = Int64(idToFind)
                dbObject?.key = patrimony.key
                task?.patrimony = dbObject
                task?.patrimonyComment = viewModel.patrimonyComment
            } else {
                task?.patrimony = nil
                task?.patrimonyComment = nil
            }
            
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
                task?.createdAttachment = dbObject
            } else {
                task?.createdAttachment = nil
            }
            
            return task
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
    
    func markAsEditionDone(byId id: Int, completion: @escaping TaskDAOService.UniqueCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Task? in
            
            let idToFind = Int64(id)
            
            let task = try? transaction.fetchOne(
                From<Task>()
                    .where(\.id == idToFind)
            )
            
            task?.isModified = false
            
            return task
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
    
    func setFavorite(byTaskId taskId: Int, isBecomingFavorite: Bool, completion: @escaping TaskDAOService.UniqueCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Task? in
            
            let idToFind = Int64(taskId)
            
            let task = try? transaction.fetchOne(
                From<Task>()
                    .where(\.id == idToFind)
            )
            
            task?.isFavorite = isBecomingFavorite
            
            return task
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
    
    func setAllFavorites(byIds ids: [Int], completion: @escaping TaskDAOService.StatusCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Bool in
            
            let idsAs64 = ids.map { Int64($0) }
            let predicateUnFavorite = NSPredicate(format: "NOT (id IN %@) AND isFavorite = %@", idsAs64, NSNumber(value: true))
            let taskToUnFavorite = try? transaction.fetchAll(
                From<Task>(),
                Where<Task>(predicateUnFavorite)
            )
            
            taskToUnFavorite?.forEach {
                $0.isFavorite = false
            }
            
            let predicateToFavorite = NSPredicate(format: "id IN %@ AND isFavorite = %@", idsAs64, NSNumber(value: false))
            let taskToFavorite = try? transaction.fetchAll(
                From<Task>(),
                Where<Task>(predicateToFavorite)
            )
            taskToFavorite?.forEach {
                $0.isFavorite = true
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
    
    func saveResponse(fromJson json: JSON, completion: @escaping TaskDAOService.UniqueCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Task? in
            
            let task = self.saveResponse(forObjectJson: json, transaction: transaction)
            
            return task
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
    
    func saveResponses(fromJson json: JSON, completion: @escaping TaskDAOService.ListCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> [Task] in
            
            let taskList = json["tasks"].arrayValue.flatMap {
                self.saveResponse(forObjectJson: $0, transaction: transaction)
                }.filter {
                    $0.activated == true
                }
            
            return taskList
        }) { (result) -> Void in
            switch result {
            case .success(let returned):
                completion(returned)
            case .failure(let error):
                print(error)
                completion([])
            }
        }
    }
    
    private func saveResponse(forObjectJson json: JSON, transaction: AsynchronousDataTransaction) -> Task? {
        let idToFind = json["id"].int64Value
        
        var task = try? transaction.fetchOne(
            From<Task>()
                .where(\.id == idToFind)
        )
        
        if task == nil {
            task = transaction.create(Into<Task>())
        }
        task?.id = idToFind
        task?.update(fromJSON: json, inTransaction: transaction)
        return task
    }
    
}
