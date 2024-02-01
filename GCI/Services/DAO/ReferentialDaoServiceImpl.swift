//
//  ReferentialDaoServiceImpl.swift
//  GCI
//
//  Created by Florian ALONSO on 5/8/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreStore

class ReferentialDaoServiceImpl: ReferentialDaoService {
    
    func allMapZone(completion: @escaping ReferentialDaoService.ReferentialMapZoneCallbak) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> ReferentialMapZone in
            let listZone = try transaction.fetchAll(
                From<Zone>()
            )
            let listMap = try transaction.fetchAll(
                From<MapReferential>()
            )
            
            return ReferentialMapZone(zones: listZone, maps: listMap)
        }) { (result) -> Void in
            switch result {
            case .success(let list):
                completion(list)
            case .failure(let error):
                print(error)
                completion(ReferentialMapZone(zones: [], maps: []))
            }
        }
    }
    
    func uniquePermissionCodes(completion: @escaping ReferentialDaoService.PermissionCodeCallbak) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> [Int] in
            let allIdsDisction = try CoreStoreDefaults.dataStack.queryAttributes(
                From<ServicePermission>(),
                Select("code")
            )
            
            let intArray = allIdsDisction.flatMap({ (array) -> [Int] in
                array.flatMap({ (value) -> Int? in
                    value.value as? Int
                })
            }) // Getting all ints
            
            let set = Set(intArray) // The set is helpfull to get unique code
            return Array(set)
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
    
    func saveResponses(fromJson json: JSON, completion: @escaping ReferentialDaoService.StateCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Bool in
            // ⚠️ The order of import here is very important
            // So the links between them can be handle correctly
            
            json["zones"].arrayValue.forEach {
                _ = self.saveResponse(forZone: $0, transaction: transaction)
            }
            
            json["services"].arrayValue.forEach {
                _ = self.saveResponse(forService: $0, transaction: transaction)
            }
            
            json["map"].arrayValue.forEach {
                _ = self.saveResponse(forMap: $0, transaction: transaction)
            }
            
            json["domains"].arrayValue.forEach {
                _ = self.saveResponse(forDomain: $0, transaction: transaction)
            }
            
            json["interventionTypes"].arrayValue.forEach {
                _ = self.saveResponse(forInterventionType: $0, transaction: transaction)
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
    
    private func saveResponse(forService json: JSON, transaction: AsynchronousDataTransaction) -> Service? {
        let idToFind = json["id"].int64Value
        
        var service = try? transaction.fetchOne(
            From<Service>()
                .where(\.id == idToFind)
        )
        
        if service == nil {
            service = transaction.create(Into<Service>())
        }
        service?.id = idToFind
        service?.update(fromJSON: json, inTransaction: transaction)
        return service
    }
    
    private func saveResponse(forInterventionType json: JSON, transaction: AsynchronousDataTransaction) -> InterventionType? {
        let idToFind = json["id"].int64Value
        
        var interventionType = try? transaction.fetchOne(
            From<InterventionType>()
                .where(\.id == idToFind)
        )
        
        if interventionType == nil {
            interventionType = transaction.create(Into<InterventionType>())
        }
        interventionType?.id = idToFind
        interventionType?.update(fromJSON: json, inTransaction: transaction)
        return interventionType
    }
    
    private func saveResponse(forDomain json: JSON, transaction: AsynchronousDataTransaction) -> Domain? {
        let idToFind = json["id"].int64Value
        
        var domain = try? transaction.fetchOne(
            From<Domain>()
                .where(\.id == idToFind)
        )
        
        if domain == nil {
            domain = transaction.create(Into<Domain>())
        }
        domain?.id = idToFind
        domain?.update(fromJSON: json, inTransaction: transaction)
        return domain
    }
    
    private func saveResponse(forMap json: JSON, transaction: AsynchronousDataTransaction) -> MapReferential? {
        let idToFind = json["id"].int64Value
        
        var map = try? transaction.fetchOne(
            From<MapReferential>()
                .where(\.id == idToFind)
        )
        
        if map == nil {
            map = transaction.create(Into<MapReferential>())
        }
        map?.id = idToFind
        map?.update(fromJSON: json, inTransaction: transaction)
        return map
    }
    
    private func saveResponse(forZone json: JSON, transaction: AsynchronousDataTransaction) -> Zone? {
        let idToFind = json["id"].int64Value
        
        var zone = try? transaction.fetchOne(
            From<Zone>()
                .where(\.id == idToFind)
        )
        
        if zone == nil {
            zone = transaction.create(Into<Zone>())
        }
        zone?.id = idToFind
        zone?.update(fromJSON: json, inTransaction: transaction)
        return zone
    }
    
    func savePermissionsResponses(fromJson jsonArray: [JSON], completion: @escaping StateCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Bool in
            try transaction.deleteAll(
                From<ServicePermission>()
            )
            
            jsonArray.forEach { json in
                
                let idToFind = json["id"].int64Value
                let zoneOpt = try? transaction.fetchOne(
                    From<Service>()
                        .where(\.id == idToFind)
                )
                
                guard let zone = zoneOpt else {
                    return
                }
                let permissionCodeList = json["permissions"].arrayValue
                    .map {$0.int16Value }
                    .map({ (code) -> ServicePermission in
                        let permission = transaction.create(Into<ServicePermission>())
                        permission.code = code
                        return permission
                    })
                
                zone.permissions = NSSet(array: permissionCodeList)
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
    
    func clearPermissions(completion: @escaping StateCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Bool in
            try transaction.deleteAll(
                From<ServicePermission>()
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
    
    func deleteAll(completion: @escaping StateCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> Bool in
            try transaction.deleteAll(
                From<InterventionType>()
            )
            try transaction.deleteAll(
                From<Domain>()
            )
            try transaction.deleteAll(
                From<Service>()
            )
            try transaction.deleteAll(
                From<DomainZoneLink>()
            )
            try transaction.deleteAll(
                From<Zone>()
            )
            try transaction.deleteAll(
                From<MapReferential>()
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
    
    func allInterventionTypes(completion: @escaping InterventionTypeListCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> [InterventionType] in
            let list = try transaction.fetchAll(
                From<InterventionType>()
                    .orderBy(.ascending(\.name))
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
    
    func allDomains(completion: @escaping DomainListCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> [Domain] in
            let list = try transaction.fetchAll(
                From<Domain>()
                    .orderBy(.ascending(\.name))
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
    
    func allServices(completion: @escaping ServiceListCallback) {
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> [Service] in
            let list = try transaction.fetchAll(
                From<Service>()
                    .orderBy(.ascending(\.name))
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
    
    func services(byIds ids: [Int], completion: @escaping ServiceListCallback) {
        let predicate = NSPredicate(format: "id IN %@", ids)
        
        CoreStoreDefaults.dataStack.perform(asynchronous: { (transaction) -> [Service] in
            let list = try transaction.fetchAll(
                From<Service>(),
                Where<Service>(predicate),
                OrderBy<Service>(.ascending(\.name))
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
}
