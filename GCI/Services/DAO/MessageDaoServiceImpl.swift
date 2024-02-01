//
//  UserDaoServiceImpl.swift
//  GCI
//
//  Created by Florian ALONSO on 5/10/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreStore

class MessageDaoServiceImpl: MessageDaoService {
    
    func allRejectMessages(completion: @escaping MessageDaoService.RejectMessagesCallbak) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> [RejectMessage] in
            let list = try transaction.fetchAll(
                From<RejectMessage>()
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
    
    func allCancelMessages(completion: @escaping MessageDaoService.CancelMessagesCallbak) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> [CancelMessage] in
            let list = try transaction.fetchAll(
                From<CancelMessage>()
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
    
    func saveResponses(fromJson json: JSON, completion: @escaping MessageDaoService.StateCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Bool in
            // ⚠️ The order of import here is very important
            // So the links between them can be handle correctly
            try transaction.deleteAll(
                From<CancelMessage>()
            )
            
            json["cancelResponses"].arrayValue.forEach {
                _ = self.saveResponse(forCancel: $0, transaction: transaction)
            }
            
            try transaction.deleteAll(
                From<RejectMessage>()
            )
            
            json["rejectResponses"].arrayValue.forEach {
                _ = self.saveResponse(forReject: $0, transaction: transaction)
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
    
    private func saveResponse(forReject json: JSON, transaction: AsynchronousDataTransaction) -> RejectMessage? {
        let idToFind = json["id"].int64Value
        
        var message = try? transaction.fetchOne(
            From<RejectMessage>()
                .where(\.id == idToFind)
        )
        
        if message == nil {
            message = transaction.create(Into<RejectMessage>())
        }
        message?.id = idToFind
        message?.update(fromJSON: json, inTransaction: transaction)
        return message
    }
    
    private func saveResponse(forCancel json: JSON, transaction: AsynchronousDataTransaction) -> CancelMessage? {
        let idToFind = json["id"].int64Value
        
        var message = try? transaction.fetchOne(
            From<CancelMessage>()
                .where(\.id == idToFind)
        )
        
        if message == nil {
            message = transaction.create(Into<CancelMessage>())
        }
        message?.id = idToFind
        message?.update(fromJSON: json, inTransaction: transaction)
        return message
    }
    
    func clearAllMessages(completion: @escaping MessageDaoService.StateCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Bool in
            try transaction.deleteAll(
                From<CancelMessage>()
            )
            
            try transaction.deleteAll(
                From<RejectMessage>()
            )
            
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
}
