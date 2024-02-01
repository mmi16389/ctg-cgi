//
//  HistoryViewModel.swift
//  GCI
//
//  Created by Florian ALONSO on 4/25/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class HistoryViewModel: TimeableViewModel, Comparable {
    static func == (lhs: HistoryViewModel, rhs: HistoryViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: HistoryViewModel, rhs: HistoryViewModel) -> Bool {
        guard lhs.date != rhs.date else {
            return lhs.statusChangedFor.rawValue < rhs.statusChangedFor.rawValue
        }
        return lhs.date < rhs.date
    }
    
    let id: Int
    let date: Date
    let name: String
    let comment: String
    let statusChangedFor: TaskViewModel.Status
    let user: TaskUserViewModel
    
    var title: String {
        return name
    }
    var description: String {
        return comment
    }
    var userFullName: String {
        return user.fullname
    }
    var userIdentifier: String {
        return user.id
    }
    
    init(id: Int, date: Date, name: String, comment: String, statusChangedFor: TaskViewModel.Status, user: TaskUserViewModel) {
        self.id = id
        self.date = date
        self.name = name
        self.comment = comment
        self.statusChangedFor = statusChangedFor
        self.user = user
    }
}

extension HistoryViewModel: Convertible {
    
    static func from(db: History) -> HistoryViewModel? {
        guard let date = db.date,
            let status = TaskViewModel.Status(rawValue: Int(db.statusChangedFor)),
            let userDB = db.user,
            let user = TaskUserViewModel.from(db: userDB) else {
                return nil
        }
        
        return HistoryViewModel(id: Int(db.id),
                                date: date,
                                name: db.name ?? "",
                                comment: db.comment ?? "",
                                statusChangedFor: status,
                                user: user)
    }
}
