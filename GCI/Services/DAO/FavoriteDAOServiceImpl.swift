//
//  FavoriteDAOServiceImpl.swift
//  GCI
//
//  Created by Florian ALONSO on 7/1/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import CoreStore

class FavoriteDAOServiceImpl: FavoriteDAOService {
    
    func unique(byId idParam: Int, completion: @escaping FavoriteDAOService.UniqueCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> ActionFavorite? in
            let object = try transaction.fetchOne(
                From<ActionFavorite>()
                    .where(\.taskId == Int64(idParam))
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
    
    func allAction(completion: @escaping FavoriteDAOService.ListCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> [ActionFavorite] in
            let object = try transaction.fetchAll(
                From<ActionFavorite>()
            )
            
            return object
        }) { (result) -> Void in
            switch result {
            case .success(let object):
                completion(object)
            case .failure(let error):
                print(error)
                completion([])
            }
        }
    }
    
    func addToActionFavorite(forTaskId taskId: Int, isBecommingFavorite: Bool, completion: @escaping FavoriteDAOService.StatusCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Bool in
            let previousActionOpt = try transaction.fetchOne(
                From<ActionFavorite>()
                    .where(\.taskId == Int64(taskId))
            )
            
            if let previousAction = previousActionOpt {
                // Action already exist so deleting it if not the same
                if previousAction.isBecomingFavorite != isBecommingFavorite {
                    transaction.delete(previousAction)
                }
            } else {
                // Creating it
                let action = transaction.create(Into<ActionFavorite>())
                action.taskId = Int64(taskId)
                action.isBecomingFavorite = isBecommingFavorite
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
    
    func delete(byTaskId taskId: Int, completion: @escaping FavoriteDAOService.StatusCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Bool in
            let object: ActionFavorite? = try transaction.fetchOne(
                From<ActionFavorite>()
                    .where(\.taskId == Int64(taskId))
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
    
    func deleteAll(completion: @escaping FavoriteDAOService.StatusCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Bool in
            let list = try transaction.fetchAll(
                From<ActionFavorite>()
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
    
}
