//
//  TaskUserViewModel.swift
//  GCI
//
//  Created by Florian ALONSO on 4/25/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class TaskUserViewModel: Comparable {
    static func == (lhs: TaskUserViewModel, rhs: TaskUserViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: TaskUserViewModel, rhs: TaskUserViewModel) -> Bool {
        let usedLeftString: String
        let usedRightString: String
        
        if lhs.roles == rhs.roles {
            usedLeftString = lhs.fullname
            usedRightString = rhs.fullname
        } else {
            usedLeftString = lhs.displayableTitle
            usedRightString = rhs.displayableTitle
        }
        
        let value = usedLeftString.caseInsensitiveCompare(usedRightString)
        guard value != .orderedSame else {
            return false
        }
        return value == .orderedAscending
    }
    
    let id: String
    let firstname: String
    let lastname: String
    let roles: [String]
    
    var fullname: String {
        var fullname = ""
        
        if !firstname.isEmpty {
            fullname += firstname
            fullname += " "
        }
        
        fullname += lastname
        
        if fullname.isEmpty {
            fullname += id
        }
        return fullname
    }
    
    init(id: String, firstname firstnameOpt: String? = nil, lastname lastnameOpt: String? = nil, roles: [String] = []) {
        self.id = id
        self.lastname = lastnameOpt ?? ""
        self.firstname = firstnameOpt ?? ""
        self.roles = roles
    }
}

extension TaskUserViewModel: Convertible {
    
    static func from(db: TaskUser) -> TaskUserViewModel? {
        guard let id = db.id else {
            return nil
        }
        return TaskUserViewModel(id: id,
                                 firstname: db.firstname,
                                 lastname: db.lastname,
                                 roles: db.roles ?? [])
    }
}

extension TaskUserViewModel: ModalSelectListItemsDataSource {
    var displayableTitle: String {
        guard !roles.isEmpty else {
            return self.fullname
        }
        return "\(roles.joined(separator: ", ")) - \(self.fullname)"
    }
    
    var displayableSubtitle: String? {
        return nil
    }
    var displayableAnnotation: String? {
        return nil
    }
}
