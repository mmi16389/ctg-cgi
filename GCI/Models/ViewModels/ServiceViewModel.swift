//
//  ServiceViewModel.swift
//  GCI
//
//  Created by Florian ALONSO on 4/23/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class ServiceViewModel: Comparable {
    static func == (lhs: ServiceViewModel, rhs: ServiceViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: ServiceViewModel, rhs: ServiceViewModel) -> Bool {
        let value = lhs.name.caseInsensitiveCompare(rhs.name)
        guard value != .orderedSame else {
            return false
        }
        return value == .orderedAscending
    }
    
    let id: Int
    let name: String
    let type: ServiceViewModel.Family
    let permissions: [ServiceViewModel.Permission]
    
    init(id: Int, name: String, type: ServiceViewModel.Family, permissions: [ServiceViewModel.Permission] = []) {
        self.id = id
        self.name = name
        self.type = type
        self.permissions = permissions
    }
    
    func actionWorkflow(fromTask task: TaskViewModel, andUser user: User) -> TaskActionWorkflow {
        let workflow: TaskActionWorkflow
        switch self.type {
        case .standard:
            workflow = StandardActionWorkflow(user: user, task: task)
        case .notOperational:
            workflow = NonOperationalActionWorkflow(task: task)
        case .external:
            workflow = ExternalActionWokflow(user: user, task: task)
        case .gmao:
            workflow = GmaoActionWokflow(user: user, task: task)
        }
        return workflow
    }
}

extension ServiceViewModel {
    enum Permission: Int {
        case read = 1
        case validate = 2
        case assign = 3
        case start = 4
        case close = 5
        case cancel = 6
        case createtask = 12
    }
    
    enum Family: Int {
        case standard = 1
        case external = 2
        case gmao = 3
        case notOperational = 4
    }
}

extension ServiceViewModel: Convertible {
    
    static func from(db: Service) -> ServiceViewModel? {
        guard let name = db.name,
            let family = ServiceViewModel.Family(rawValue: Int(db.type)) else {
                return nil
        }
        
        let permissionsDB = db.permissions?.allObjects as? [ServicePermission]
        let permissionArray = permissionsDB?.flatMap { (permission) -> Permission? in
            return Permission(rawValue: Int(permission.code))
        } ?? []
        
        return ServiceViewModel(id: Int(db.id),
            name: name,
            type: family,
            permissions: permissionArray)
    }
}

extension ServiceViewModel: ModalSelectListItemsDataSource {
    var displayableTitle: String {
        return self.name
    }
    
    var displayableSubtitle: String? {
        return nil
    }
    var displayableAnnotation: String? {
        return nil
    }
}
