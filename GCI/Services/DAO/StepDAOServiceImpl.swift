//
//  StepDAOServiceImpl.swift
//  GCI
//
//  Created by Anthony Chollet on 24/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreStore

class StepDAOServiceImpl: StepDAOService {
    func add(fromViewModel viewModel: StepViewModel, completion: @escaping (Step?) -> Void) {
        //DO nothing
    }
    
    func all(completion: @escaping StepDAOService.ListCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> [Step] in
            let list = try transaction.fetchAll(
                From<Step>()
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
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> [Step] in
            let list = try transaction.fetchAll(
                From<Step>()
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
    
    func unique(byId idParam: Int, completion: @escaping StepDAOService.UniqueCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Step? in
            let object = try transaction.fetchOne(
                From<Step>()
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
    
    func delete(byId idParam: Int, completion: @escaping StepDAOService.StatusCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Bool in
            let object: Step? = try transaction.fetchOne(
                From<Step>()
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
    
    func deleteAll(completion: @escaping StepDAOService.StatusCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Bool in
            let list = try transaction.fetchAll(
                From<Step>()
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
    
    func update(fromViewModel viewModel: StepViewModel, oldAttachment: AttachmentViewModel?, completion: @escaping StepDAOService.UniqueCallback) {
        
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Step? in
            
            let idToFind = Int64(viewModel.id)
            
            let step = try? transaction.fetchOne(
                From<Step>()
                    .where(\.id == idToFind)
            )
            
            step?.action = Int16(viewModel.action.rawValue)
            step?.title = viewModel.title
            step?.date = viewModel.date
            step?.desc = viewModel.description
            step?.isModified = true
            
            if let attachment = oldAttachment {
                let idToFind = attachment.uuid
                let dbObject = try? transaction.fetchOne(
                    From<Attachment>()
                        .where(\.uuid == idToFind)
                )
                step?.attachment = dbObject
            } else {
                step?.attachment = nil
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
 
    func markAsEditionDone(byId id: Int, completion: @escaping StepDAOService.UniqueCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Step? in
            
            let idToFind = Int64(id)
            
            let step = try? transaction.fetchOne(
                From<Step>()
                    .where(\.id == idToFind)
            )
            
            step?.isModified = false
            
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
    
    func saveResponse(fromJson json: JSON, completion: @escaping StepDAOService.UniqueCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Step? in
            
            let step = self.saveResponse(forObjectJson: json, transaction: transaction)
            
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
    
    func saveResponses(fromJson json: JSON, completion: @escaping StepDAOService.ListCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> [Step] in
            
            let stepList = json["steps"].arrayValue.flatMap {
                self.saveResponse(forObjectJson: $0, transaction: transaction)
                }
            
            return stepList
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
    
    private func saveResponse(forObjectJson json: JSON, transaction: AsynchronousDataTransaction) -> Step? {
        let idToFind = json["id"].int64Value
        
        var step = try? transaction.fetchOne(
            From<Step>()
                .where(\.id == idToFind)
        )
        
        if step == nil {
            step = transaction.create(Into<Step>())
        }
        step?.id = idToFind
        step?.update(fromJSON: json, inTransaction: transaction)
        return step
    }
}
