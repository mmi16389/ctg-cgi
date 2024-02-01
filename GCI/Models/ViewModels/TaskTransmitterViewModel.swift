//
//  TaskTransmitterViewModel.swift
//  GCI
//
//  Created by Florian ALONSO on 4/25/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class TaskTransmitterViewModel {
    let civility: String?
    let firstname: String?
    let lastname: String?
    let phone: String?
    let address: String?
    let email: String?
    
    var fullname: String {
        var fullname = ""
        
        if let civility = self.civility, !civility.isEmpty {
            fullname += civility
            fullname += " "
        }
        
        if let firstname =  self.firstname, !firstname.isEmpty {
            fullname += firstname
            fullname += " "
        }
        
        fullname += lastname ?? ""
        return fullname
    }
    
    init(civility civilityOpt: String?, firstname firstnameOpt: String?, lastname lastnameOpt: String?, phone phoneOpt: String?, address addressOpt: String?, email emailOpt: String?) {
        self.civility = civilityOpt
        self.firstname = firstnameOpt
        self.lastname = lastnameOpt
        self.phone = phoneOpt
        self.address = addressOpt
        self.email = emailOpt
    }
}

extension TaskTransmitterViewModel: Convertible {
    
    static func from(db: TaskTransmitter) -> TaskTransmitterViewModel? {
        return TaskTransmitterViewModel(civility: db.civility, firstname: db.firstname, lastname: db.lastname, phone: db.phone, address: db.address, email: db.email)
    }
}
