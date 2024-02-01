//
//  CreatedTaskViewModel.swift
//  GCI
//
//  Created by Florian ALONSO on 4/26/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import CoreData

class CreatedTaskViewModel {
    let internalManagedId: Int
    let domain: DomainViewModel
    let service: ServiceViewModel
    let otherService: [ServiceViewModel]
    let interventionType: InterventionTypeViewModel?
    let interventionComment: String?
    let status: TaskViewModel.Status
    let creationDate: Date
    let isUrgent: Bool
    let title: String
    let comment: String
    let transmitterComment: String
    let location: TaskLocationViewModel?
    let patrimony: TaskPatrimonyViewModel?
    let patrimonyComment: String
    let createdAttachment: CreatedAttachmentViewModel?
    var actionWorkflow: ActionWorkflowViewModel?
    
    init(
        internalManagedId: Int,
        domain: DomainViewModel,
        service: ServiceViewModel,
        otherService: [ServiceViewModel],
        interventionType: InterventionTypeViewModel?,
        interventionComment: String?,
        status: TaskViewModel.Status,
        creationDate: Date,
        isUrgent: Bool,
        title: String,
        comment: String,
        transmitterComment: String,
        location: TaskLocationViewModel?,
        patrimony: TaskPatrimonyViewModel?,
        patrimonyComment: String,
        createdAttachment: CreatedAttachmentViewModel?
        ) {
        
        self.internalManagedId = internalManagedId
        self.domain = domain
        self.service = service
        self.otherService = otherService
        self.interventionType = interventionType
        self.interventionComment = interventionComment
        self.status = status
        self.creationDate = creationDate
        self.isUrgent = isUrgent
        self.title = title
        self.comment = comment
        self.transmitterComment = transmitterComment
        self.location = location
        self.patrimony = patrimony
        self.patrimonyComment = patrimonyComment
        self.createdAttachment = createdAttachment
        
    }
}

extension CreatedTaskViewModel: Convertible {
    
    static func from(db: CreatedTask) -> CreatedTaskViewModel? {
        guard let domain = DomainViewModel.from(db: db.domain),
            let service = ServiceViewModel.from(db: db.service),
            let status = TaskViewModel.Status(rawValue: Int(db.status)),
            let date = db.creationDate else {
                return nil
        }
        
        let interventionType = InterventionTypeViewModel.from(db: db.interventionType)
        let location = TaskLocationViewModel.from(db: db.location)
        let patrimony = TaskPatrimonyViewModel.from(db: db.patrimony)
        let attachment = CreatedAttachmentViewModel.from(db: db.createdAttachment)
        
        let serviceOthersDB = db.otherServices?.allObjects as? [Service] ?? []
        let serviceOthers = ServiceViewModel.from(dbList: serviceOthersDB)
        
        return CreatedTaskViewModel(
                                    internalManagedId: Int(db.internalId),
                                    domain: domain,
                                    service: service,
                                    otherService: serviceOthers,
                                    interventionType: interventionType,
                                    interventionComment: db.interventionComment,
                                    status: status,
                                    creationDate: date,
                                    isUrgent: db.isUrgent,
                                    title: db.title ?? "",
                                    comment: db.comment ?? "",
                                    transmitterComment: db.transmitterComment ?? "",
                                    location: location,
                                    patrimony: patrimony,
                                    patrimonyComment: db.patrimonyComment ?? "",
                                    createdAttachment: attachment)
    }
}

extension CreatedTaskViewModel {
    
    var webParameters: [String: Any] {
        var content = [String: Any]()
        var otherServicesId = [Int]()
        
        self.otherService.forEach { (service) in
            otherServicesId.append(service.id)
        }
        
        content = [
            "domainId": self.domain.id,
            "serviceId": self.service.id,
            "status": self.status.rawValue,
            "otherServiceIds": otherServicesId,
            "creationDate": DateHelper.requestDateFormater.string(from: self.creationDate),
            "isUrgent": self.isUrgent,
            "title": self.title,
            "comment": self.comment,
            "transmitterComment": self.transmitterComment
            
        ]
        
        if let interventionType = self.interventionType {
            content["interventionTypeId"] = interventionType.id
        } else {
            content["interventionComment"] = self.interventionComment
        }
        
        if let location = self.location {
            content["location"] =  [
                "srid": location.srid,
                "point": location.pointAsString,
                "address": location.address,
                "comment": location.comment
            ]
        }
        
        if let attachment = self.createdAttachment, let uuid = attachment.uuid {
            content["attachement"] =  [
                "uuid": uuid
            ]
            content["fileId"] = uuid
        }
        
        if let patrimony = self.patrimony {
            content["patrimony"] =  [
                "id": patrimony.id,
                "comment": self.patrimonyComment,
                "key": patrimony.key
            ]
        }
        
        var parameters = [String: Any]()
        parameters["isActive"] = true
        parameters["content"] = content
        
        return parameters
    }
}
