//
//  CreatedAttachmentDAOServiceImpl.swift
//  GCI
//
//  Created by Florian ALONSO on 6/3/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import CoreStore

class CreatedAttachmentDAOServiceImpl: CreatedAttachmentDAOService {
    
    func unique(byId id: String, completion: @escaping UniqueCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> CreatedAttachment? in
            let object = try transaction.fetchOne(
                From<CreatedAttachment>()
                    .where(\.fileName == id)
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
    
    func delete(byId id: String, completion: @escaping StatusCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Bool in
            let object: CreatedAttachment? = try transaction.fetchOne(
                From<CreatedAttachment>()
                    .where(\.fileName == id)
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
                From<CreatedAttachment>()
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
    
    func rollbackUUID(byId id: String, completion: @escaping StatusCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> CreatedAttachment? in
            let object = try transaction.fetchOne(
                From<CreatedAttachment>()
                    .where(\.fileName == id)
            )
            
            object?.uuid = nil
            
            return object
        }) { (result) -> Void in
            switch result {
            case .success(let object):
                completion((object != nil))
            case .failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    func updatedUUID(byId id: String, withNewUUID uuid: String, completion: @escaping StatusCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> CreatedAttachment? in
            let object = try transaction.fetchOne(
                From<CreatedAttachment>()
                    .where(\.fileName == id)
            )
            
            object?.uuid = uuid
            
            return object
        }) { (result) -> Void in
            switch result {
            case .success(let object):
                completion((object != nil))
            case .failure(let error):
                print(error)
                completion(false)
            }
        }
    }
}
