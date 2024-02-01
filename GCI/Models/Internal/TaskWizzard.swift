//
//  TaskWizzard.swift
//  GCI
//
//  Created by Anthony Chollet on 04/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import ArcGIS

class TaskWizzard: NSObject {
    typealias Action = (_ task: TaskViewModel) -> Void
    typealias ActionDuplicate = (_ task: CreatedTaskViewModel) -> Void
    
    private var location: TaskLocationViewModel?
    private var zone: DomainZoneLinkViewModel?
    private var taskPatrimony: TaskPatrimonyViewModel?
    private var patrimonyComment: String = ""
    private var domain: DomainViewModel?
    
    var isDuplicateTask: Bool = false
    var actionOnValidate: Action?
    var actionOnDuplicate: ActionDuplicate?
    var comment: String = ""
    var interventionComment: String = ""
    var locationComment: String = "" {
        didSet {
            if let location = self.getLocation(), let zone = getZone() {
                self.setLocation(withLocation: TaskLocationViewModel.init(srid: location.srid, point: location.point, address: location.address, comment: locationComment), andZone: zone)
            }
        }
    }
    var createdAttchment: CreatedAttachmentViewModel? {
        willSet (newValue) {
            self.attachementIsFromCamera = false
            if newValue == nil, let attachmentURL = createdAttchment?.fileUrl {
                if FileManager.default.fileExists(atPath: attachmentURL.path) {
                    do {
                        try FileManager.default.removeItem(at: attachmentURL)
                    } catch let error {
                        print(error)
                    }
                }
            }
        }
    }
    var attachementIsFromCamera: Bool = false
    var attachment: AttachmentViewModel?
    var service: ServiceViewModel?
    var linkedServices = [ServiceViewModel]()
    var originalTask: TaskViewModel?
    var isUrgent: Bool = false {
        didSet {
            guard isUrgent else {
                return
            }
//            guard let interventionType = self.interventionType else {
//                isUrgent = false
//                return
//            }
            
//            if !interventionType.urgent {
//                isUrgent = false
//            }
        }
    }
    var interventionType: InterventionTypeViewModel? {
        didSet {
            self.location = nil
            self.zone = nil
            self.service = nil
            self.linkedServices = []
            self.isUrgent = self.interventionType?.urgent ?? false
            self.createdAttchment = nil
            if interventionType != nil {
                self.setDomain(domain: interventionType?.domain)
                self.interventionComment = ""
            } else {
                self.domain = nil
            }
        }
    }
    
    override init() {}
    
    init(originalTask: TaskViewModel? = nil,
         interventionType: InterventionTypeViewModel?,
         location: TaskLocationViewModel?,
         isUrgent: Bool,
         comment: String,
         interventionComment: String,
         domain: DomainViewModel?,
         createdAttchment: CreatedAttachmentViewModel?,
         attachment: AttachmentViewModel?,
         taskPatrimony: TaskPatrimonyViewModel?,
         patrimonyComment: String,
         zone: DomainZoneLinkViewModel?,
         service: ServiceViewModel?,
         linkedServices: [ServiceViewModel],
         isDuplicateTask: Bool = false) {
        self.originalTask = originalTask
        self.interventionType = interventionType
        self.location = location
        self.isUrgent = isUrgent
        self.comment = comment
        self.interventionComment = interventionComment
        self.domain = domain
        self.createdAttchment = createdAttchment
        self.attachment = attachment
        self.taskPatrimony = taskPatrimony
        self.patrimonyComment = patrimonyComment
        self.zone = zone
        self.service = service
        self.linkedServices = linkedServices
        self.isDuplicateTask = isDuplicateTask
    }
    
    var isNewTask: Bool {
        guard let originalTask = self.originalTask else {
            return true
        }
        if isDuplicateTask {
            return true
        } else {
            return originalTask.id <= 0
        }
    }
    
    func pointInZone(withPoint point: AGSPoint) -> DomainZoneLinkViewModel? {
        guard let zoneList = domain?.zoneList else {
            return nil
        }
        for domainZone in zoneList {
            guard let polygon = domainZone.zone.polygon else {
                continue
            }
            if ArcgisHelper.pointInPolygon(withPoint: point, inPolygon: polygon) {
                return domainZone
            }
        }
        return nil
    }
    
    var shouldDisplayMap: Bool {
        guard let domain = domain else {
            return true
        }
        
        return domain.useMap
    }
    
    func getLocation() -> TaskLocationViewModel? {
        return self.location
    }
    
    func getZone() -> DomainZoneLinkViewModel? {
        return self.zone
    }
    
    func setLocation(withLocation location: TaskLocationViewModel?, andZone zone: DomainZoneLinkViewModel?) {
        if let loc = self.location {
            if loc.point == location?.point {
                return
            }
        }
        self.location = location
        self.zone = zone
        setTaskPatrimony(withTaskPatrimony: nil, andComment: "")
        self.service = nil
        self.linkedServices = []
        self.createdAttchment = nil
    }
    
    func getTaskPatrimony() -> TaskPatrimonyViewModel? {
        return self.taskPatrimony
    }
    
    func getPatrimonyCommment() -> String {
        return self.patrimonyComment
    }
    
    func setTaskPatrimony(withTaskPatrimony taskPatrimony: TaskPatrimonyViewModel?, andComment comment: String) {
        self.taskPatrimony = taskPatrimony
        self.patrimonyComment = self.taskPatrimony != nil ? comment : ""
    }
    
    func getDomain() -> DomainViewModel? {
        return self.domain
    }
    
    func setDomain(domain: DomainViewModel?) {
        self.domain = domain
        self.setLocation(withLocation: nil, andZone: nil)
    }
    
    func generateCreatedAttachement(filePath: URL) -> CreatedAttachmentViewModel? {
        return CreatedAttachmentViewModel(fileName: filePath.lastPathComponent)
    }
    
    func getNumberOfActiveButton() -> Int {
        guard let domain = domain else {
            return 5
        }
        
        if domain.useMap {
            return 5
        } else {
            return 4
        }
    }

    func create() -> CreatedTaskViewModel? {
        guard isNewTask,
            let domain = self.getDomain(),
            let service = self.service,
            self.interventionType != nil || !self.interventionComment.isEmpty else {
            return nil
        }
        
        return CreatedTaskViewModel(internalManagedId: 0,
            domain: domain,
            service: service,
            otherService: self.linkedServices,
            interventionType: self.interventionType,
            interventionComment: self.interventionComment,
            status: TaskViewModel.Status.created,
            creationDate: Date(),
            isUrgent: self.isUrgent,
            title: "",
            comment: self.comment,
            transmitterComment: "",
            location: self.location,
            patrimony: self.taskPatrimony,
            patrimonyComment: self.patrimonyComment,
            createdAttachment: self.createdAttchment)
    }
    
    func createForUpload() -> CreatedTaskViewModel? {
        if let createdTaskViewModel = create() {
            
            return createdTaskViewModel
        }
        return nil
    }
    
    func edit() -> TaskViewModel? {
        guard !isNewTask,
            let originalTask = originalTask,
            let domain = self.getDomain(),
            let service = self.service,
            self.interventionType != nil || !self.interventionComment.isEmpty else {
                return nil
        }
        
        return TaskViewModel(id: originalTask.id,
                             activated: true,
                             status: TaskViewModel.Status.created,
                             isFavorite: originalTask.isFavorite,
                             creationDate: Date(),
                             dueDate: originalTask.dueDate,
                             endDate: originalTask.endDate,
                             isPublic: originalTask.isPublic,
                             title: originalTask.title,
                             originLabel: originalTask.originLabel,
                             creator: originalTask.creator,
                             transmitter: originalTask.transmitter,
                             attachment: self.attachment,
                             isModified: true,
                             isUrgent: self.isUrgent,
                             domain: domain,
                             service: service,
                             otherServices: self.linkedServices,
                             nextTask: originalTask.nextTask,
                             previousTask: originalTask.previousTask,
                             interventionType: self.interventionType,
                             interventionTypeComment: self.interventionComment,
                             modificationDate: Date(),
                             comment: self.comment,
                             transmitterComment: originalTask.transmitterComment,
                             assigned: originalTask.assigned,
                             location: self.getLocation(),
                             createdAttachment: self.createdAttchment,
                             patrimony: self.taskPatrimony,
                             patrimonyComment: self.patrimonyComment,
                             steps: originalTask.steps,
                             createdSteps: originalTask.createdSteps,
                             history: originalTask.history)
    }

}
