//
//  Task.swift
//  GCI
//
//  Created by Florian ALONSO on 5/8/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreStore

extension Task {
    
    func update(fromJSON json: JSON, inTransaction transaction: AsynchronousDataTransaction) {
        
        self.activated = json["isActive"].boolValue
        guard activated, let createdDate = json["content"]["creationDate"].networkDate else {
            return
        }
        
        // Internal types
        self.interventionComment = json["content"]["interventionComment"].string
        self.status = json["content"]["status"].int16Value
        self.creationDate = createdDate
        self.dueDate = json["content"]["dueDate"].networkDate
        self.endDate = json["content"]["endDate"].networkDate
        if let modificationDate = json["content"]["modificationDate"].networkDate {
            self.modificationDate = modificationDate
        } else {
            self.modificationDate = createdDate
        }
        self.isPublic = json["content"]["isPublic"].boolValue
        self.isUrgent = json["content"]["isUrgent"].boolValue
        self.isFavorite = json["content"]["isFavorite"].boolValue
        self.title = json["content"]["title"].stringValue
        self.comment = json["content"]["comment"].stringValue
        self.transmitterComment = json["content"]["transmitterComment"].stringValue
        self.originLabel = json["content"]["origin"]["label"].stringValue
        
        // Linked object
        self.domain = try? transaction.fetchOne(
            From<Domain>()
                .where(\.id == json["content"]["domainId"].int64Value)
        )
        self.service = try? transaction.fetchOne(
            From<Service>()
                .where(\.id == json["content"]["serviceId"].int64Value)
        )
        self.interventionType = try? transaction.fetchOne(
            From<InterventionType>()
                .where(\.id == json["content"]["interventionTypeId"].int64Value)
        )
        
        let serviceIdList = json["content"]["otherServiceIds"].arrayValue.map { $0.int64Value }
        var predicate = NSPredicate(format: "id IN %@", serviceIdList)
        let otherServices = try? transaction.fetchAll(
            From<Service>(),
            Where<Service>(predicate)
            )
        self.otherServices = NSSet(array: otherServices ?? [])
        
        // Sub objects
        let stepsArray = Step.findOrCreate(fromJSON: json["content"]["steps"].arrayValue, inTransaction: transaction)
        self.steps = NSSet(array: stepsArray)
        
        let historyArray = History.findOrCreate(fromJSON: json["content"]["history"].arrayValue, inTransaction: transaction)
        self.history = NSSet(array: historyArray)

        if json["content"]["attachement"].exists() {
            self.attachment = Attachment.findOrCreate(fromJSON: json["content"]["attachement"], inTransaction: transaction)
        } else {
            self.attachment = nil
        }
        
        self.creator = TaskUser.findOrCreate(fromJSON: json["content"]["creator"], inTransaction: transaction)
        
        if json["content"]["assigned"].exists() {
            self.assigned = TaskUser.findOrCreate(fromJSON: json["content"]["assigned"], inTransaction: transaction)
        } else {
            self.assigned = nil
        }
        
        if json["content"]["patrimony"].exists() {
            self.patrimony = TaskPatrimony.findOrCreate(fromJSON: json["content"]["patrimony"], inTransaction: transaction)
        } else {
            self.patrimony = nil
        }
        self.patrimonyComment = json["content"]["patrimony"]["comment"].stringValue
        
        if json["content"]["location"].exists() {
            self.location = TaskLocation.findOrCreate(fromJSON: json["content"]["location"], inTransaction: transaction)
        } else {
            self.location = nil
        }
        
        if self.transmitter == nil {
            self.transmitter = transaction.create(Into<TaskTransmitter>())
        }
        self.transmitter?.update(fromJSON: json["content"]["transmitter"], inTransaction: transaction)
        
        let previouTaskIdList = json["content"]["linkedPreviousTasks"].arrayValue.map { $0.int64Value }
        predicate = NSPredicate(format: "id IN %@", previouTaskIdList)
        let previousTasksArray = try? transaction.fetchAll(
            From<Task>(),
            Where<Task>(predicate)
        )
        self.previousTasks = NSOrderedSet(array: previousTasksArray ?? [])
    }
}
