//
//  TaskViewModel.swift
//  GCI
//
//  Created by Florian ALONSO on 4/23/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import ArcGIS

class TaskViewModel: Comparable {
    static func == (lhs: TaskViewModel, rhs: TaskViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: TaskViewModel, rhs: TaskViewModel) -> Bool {
        if lhs.isUrgent == rhs.isUrgent {
            return lhs.creationDate > rhs.creationDate
        }
        return lhs.isUrgent
    }
    
    let id: Int
    var isActivated: Bool
    var status: Status
    var isFavorite: Bool
    let creationDate: Date
    let dueDate: Date?
    let endDate: Date?
    let isPublic: Bool
    let title: String
    let originLabel: String
    let creator: TaskUserViewModel
    let transmitter: TaskTransmitterViewModel?
    let attachment: AttachmentViewModel?
    var isModified: Bool
    let isUrgent: Bool
    let domain: DomainViewModel?
    let service: ServiceViewModel?
    let otherServices: [ServiceViewModel]
    let nextTask: [TaskViewModel]
    let previousTask: [TaskViewModel]
    let interventionType: InterventionTypeViewModel?
    let interventionTypeComment: String?
    let modificationDate: Date?
    let comment: String
    let transmitterComment: String
    let assigned: TaskUserViewModel?
    let location: TaskLocationViewModel?
    let createdAttachment: CreatedAttachmentViewModel?
    let patrimony: TaskPatrimonyViewModel?
    let patrimonyComment: String?
    let steps: [StepViewModel]
    let createdSteps: [CreatedStepViewModel]
    let history: [HistoryViewModel]
    var zone: DomainZoneLinkViewModel? {
        guard let zoneList = domain?.zoneList, let location = location else {
            return nil
        }
        for domainZone in zoneList {
            guard let polygon = domainZone.zone.polygon else {
                continue
            }
            if ArcgisHelper.pointInPolygon(withPoint: location.point, inPolygon: polygon) { 
                return domainZone
            }
        }
        return nil
    }
    var transferableServices: [ServiceViewModel] {
        guard let service = self.service, let domain = self.domain else {
            return [] // Not a valid service type
        }
        var services = [ServiceViewModel]()
        
        if domain.useMap, let zoneLinked = self.zone {
            // Using map so getting zone services
            if !zoneLinked.linkedServices.contains(zoneLinked.defaultService) {
                services.append(zoneLinked.defaultService)
            }
            services.append(contentsOf: zoneLinked.linkedServices)
        } else if let domain = self.domain {
            if let defaultService = domain.defaultService, !domain.linkedServices.contains(defaultService) {
                services.append(defaultService)
            }
            services.append(contentsOf: domain.linkedServices)
        }
        
        if let index = services.firstIndex(of: service) {
            services.remove(at: index)
        }
        
        return services
    }
    
    var displayableAttachment: ViewableAttachment? {
        return createdAttachment != nil ? createdAttachment : attachment
    }
    
    var hasLinkedTask: Bool {
        return !nextTask.isEmpty || !previousTask.isEmpty
    }
    
    init(
        id: Int,
        activated: Bool,
        status: Status,
        isFavorite: Bool,
        creationDate: Date,
        dueDate: Date?,
        endDate: Date?,
        isPublic: Bool,
        title: String,
        originLabel: String,
        creator: TaskUserViewModel,
        transmitter: TaskTransmitterViewModel?,
        attachment: AttachmentViewModel?,
        isModified: Bool,
        isUrgent: Bool,
        domain: DomainViewModel?,
        service: ServiceViewModel?,
        otherServices: [ServiceViewModel],
        nextTask: [TaskViewModel] = [],
        previousTask: [TaskViewModel] = [],
        interventionType: InterventionTypeViewModel?,
        interventionTypeComment: String?,
        modificationDate: Date?,
        comment: String,
        transmitterComment: String,
        assigned: TaskUserViewModel?,
        location: TaskLocationViewModel?,
        createdAttachment: CreatedAttachmentViewModel?,
        patrimony: TaskPatrimonyViewModel?,
        patrimonyComment: String?,
        steps: [StepViewModel],
        createdSteps: [CreatedStepViewModel],
        history: [HistoryViewModel]
        ) {
        self.id = id
        self.isActivated = activated
        self.status = status
        self.isFavorite = isFavorite
        self.creationDate = creationDate
        self.dueDate = dueDate
        self.endDate = endDate
        self.isPublic = isPublic
        self.title = title
        self.originLabel = originLabel
        self.creator = creator
        self.transmitter = transmitter
        self.attachment = attachment
        self.isModified = isModified
        self.isUrgent = isUrgent
        self.domain = domain
        self.service = service
        self.otherServices = otherServices
        self.nextTask = nextTask
        self.previousTask = previousTask
        self.interventionType = interventionType
        self.interventionTypeComment = interventionTypeComment
        self.modificationDate = modificationDate
        self.comment = comment
        self.transmitterComment = transmitterComment
        self.assigned = assigned
        self.location = location
        self.createdAttachment = createdAttachment
        self.patrimony = patrimony
        self.patrimonyComment = patrimonyComment
        self.steps = steps
        self.createdSteps = createdSteps
        self.history = history
    }
    
    // Mark - State utils
    
    var isInProgress: Bool {
        return status == .inProgress
    }
    
    func isAssigned(to user: User) -> Bool {
        
        if let assigned = self.assigned {
            return assigned.id == user.id
        } else if isInProgress, let service = service, service.type == .external {
            return true
        } else {
            return false
        }
    }
    
    func category(forUser user: User) -> TaskCategory {
        let category: TaskCategory
        
        if canValidate {
            category = TaskCategory.new
        } else if canAssign {
            category = TaskCategory.validated
        } else if canClose {
            category = TaskCategory.finished
        } else if canStart && isAssigned(to: user) {
            category = TaskCategory.assigned
        } else if isInProgress && isAssigned(to: user) {
            category = TaskCategory.inProgress
        } else if canUndoValidate {
            category = TaskCategory.validated
        } else if canUndoAssign {
            category = TaskCategory.assigned
        } else {
            category = TaskCategory.global
        }
        
        return category
    }
    
    var searchDefinition: String {
        var text = ""
        text += "_\(self.status.localizedText)"
        text += "_\(self.title)"
        text += "_\(self.originLabel)"
        text += "_\(self.comment)"
        text += "_\(self.transmitterComment)"
        text += "_\(self.creator.fullname)"
        if let interventionTypeComment = self.interventionTypeComment {
            text += "_\(interventionTypeComment)"
        }
        if let patrimonyComment = self.patrimonyComment {
            text += "_\(patrimonyComment)"
        }
        if let transmitter = self.transmitter {
            text += "_\(transmitter.fullname)"
        }
        if let assigned = self.assigned {
            text += "_\(assigned.fullname)"
        }
        if let domain = self.domain {
            text += "_\(domain.title)"
        }
        if let service = self.service {
            text += "_\(service.name)"
        }
        if let interventionType = self.interventionType {
            text += "_\(interventionType.name)"
        }
        self.otherServices.forEach {
            text += "_\($0.name)"
        }
        let simple = text.folding(options: [.diacriticInsensitive, .widthInsensitive, .caseInsensitive], locale: nil)
        let nonAlphaNumeric = CharacterSet.alphanumerics.inverted
        return simple.components(separatedBy: nonAlphaNumeric).joined(separator: "")
    }
    
    // Mark - Permissions utils
    
    var isVisible: Bool {
        return status != TaskViewModel.Status.canceled
            && status != TaskViewModel.Status.closed
            && status != TaskViewModel.Status.refused
            && isActivated
    }
    
    var canRead: Bool {
        return service?.permissions.contains(ServiceViewModel.Permission.read) ?? false
    }
    
    var canValidate: Bool {
        return status == .created &&
            service?.permissions.contains(ServiceViewModel.Permission.validate) ?? false
    }
    
    var canUndoValidate: Bool {
        return status == .validated &&
            service?.permissions.contains(ServiceViewModel.Permission.validate) ?? false
    }
    
    var canStart: Bool {
        return status == .assigned &&
            service?.permissions.contains(ServiceViewModel.Permission.start) ?? false
    }
    
    var canStartForExternalServices: Bool {
        guard let service = service else {
            return false
        }
        return status == .validated && service.type == .external && service.permissions.contains(ServiceViewModel.Permission.start)
    }
    
    var canAssign: Bool {
        return status == .validated &&
            service?.permissions.contains(ServiceViewModel.Permission.assign) ?? false
    }
    
    var canChangeAssign: Bool {
        return (status == .validated || status == .assigned) &&
            service?.permissions.contains(ServiceViewModel.Permission.assign) ?? false
    }
    
    var canUndoAssign: Bool {
        return status == .assigned &&
            service?.permissions.contains(ServiceViewModel.Permission.assign) ?? false
    }
    
    var canClose: Bool {
        return status == .finished &&
            service?.permissions.contains(ServiceViewModel.Permission.close) ?? false
    }
    
    var canCancel: Bool {
        return (service?.permissions.contains(ServiceViewModel.Permission.cancel) ?? false)
    }
    
    // Mark - Step utils
    
    var allSteps: [ViewableStep] {
        var steps = [ViewableStep]()
        steps.append(contentsOf: self.steps)
        steps.append(contentsOf: self.createdSteps)
        return steps
    }
    
    var displayableSteps: [ViewableStep] {
        var steps = self.allSteps
        steps.sort { (lhs, rhs) -> Bool in
            return lhs.date < rhs.date
        }
        return steps
    }
    
    func displayableAndEditableSteps(forUser user: User) -> [ViewableStep] {
        return displayableSteps.filter { (step) -> Bool in
            return user.id == step.userIdentifier
        }
    }
    
    // Mark - Date utils
    
    var isLate: Bool {
        guard let dueDate = self.dueDate, self.status != .closed else {
            return false
        }
        
        return dueDate.isInPast
    }
    
    var isUpdatedToday: Bool {
        let foundHistory = self.history.first { (history) -> Bool in
            if history.statusChangedFor == self.status {
                return history.date.isInToday
            }
            return false
        }
        return foundHistory?.date.isInToday ?? false
    }
    
    var interventionDurationSec: Double {
        let displableSteps = self.allSteps
        let startDateOpt = displableSteps.first { (step) in
            return step.action == .start
            }.map { $0.date }
        let endDateOpt = displableSteps.first { (step) in
            return step.action == .end
            }.map { $0.date }
        
        guard let startDate = startDateOpt else {
            return 0
        }
        guard let endDate = endDateOpt else {
            return Date().timeIntervalSince(startDate)
        }
        return abs(startDate.timeIntervalSince(endDate))
        
    }
    
    var canEditPlannedDate: Bool {
        return false
        /* Delayed in time so just commented this part
        let value: Bool
        switch self.status {
        case .created:
            value = canValidate
        case .validated:
            value = canAssign
        case .assigned:
            value = canAssign || canStart
        case .inProgress:
            value = service?.permissions.contains(ServiceViewModel.Permission.start) ?? false
        default:
            value = false
        }
        return value
        */
    }
    
    func isCreatedSameDay(than date: Date) -> Bool {
        return Calendar.current.isDate(self.creationDate, equalTo: date, toGranularity: .day)
    }
    
    func isCreated(after startDate: Date, andBefore endDate: Date) -> Bool {
        return self.isCreatedSameDay(than: startDate)
            || self.isCreatedSameDay(than: endDate)
            || self.creationDate.isBetween(startDate, endDate)
    }
    
    // Mark : Task Actions
    
    func taskActions(forUser user: User) -> [TaskAction] {
        return service?.actionWorkflow(fromTask: self, andUser: user).actions ?? []
    }
}

extension TaskViewModel {
    enum Status: Int {
        case created = 1
        case validated = 2
        case assigned = 3
        case inProgress = 4
        case closed = 5 //Cloturée
        case canceled = 6 //Annulée
        case finished = 7 //Terminée
        case refused = 8 //Refusée
        
        var localizedText: String {
            switch self {
            case .validated:
                return "tasks_status_validated_single".localized
            case .assigned:
                return "tasks_status_assign_single".localized
            case .inProgress:
                return "tasks_status_in_progress_single".localized
            case .finished:
                return "tasks_status_finished_single".localized
            case .canceled:
                return "tasks_status_canceled_single".localized
            case .closed:
                return "tasks_status_closed_single".localized
            case .refused:
                return "tasks_status_refused_single".localized
            default:
                return "tasks_status_new_single".localized
            }
        }
    }
}

extension TaskViewModel: Convertible {
    
    static func from(db: Task) -> TaskViewModel? {
        return from(db: db, withLinked: true)
    }
    
    static func from(db: Task, withLinked: Bool) -> TaskViewModel? {
        guard let status = Status(rawValue: Int(db.status)),
            let creationDate = db.creationDate,
            let title = db.title,
            let transmiter = TaskTransmitterViewModel.from(db: db.transmitter),
            let creator = TaskUserViewModel.from(db: db.creator) else {
                return nil
        }
        
        let domain = DomainViewModel.from(db: db.domain)
        let interventionType = InterventionTypeViewModel.from(db: db.interventionType)
        let service = ServiceViewModel.from(db: db.service)
        let serviceOtherListDB = db.otherServices?.allObjects as? [Service] ?? []
        let serviceOtherList = ServiceViewModel.from(dbList: serviceOtherListDB)
        let attachment = AttachmentViewModel.from(db: db.attachment)
        let createdAttachment = CreatedAttachmentViewModel.from(db: db.createdAttachment)
        let assigned = TaskUserViewModel.from(db: db.assigned)
        let location = TaskLocationViewModel.from(db: db.location)
        let patrimony = TaskPatrimonyViewModel.from(db: db.patrimony)
        let stepsListDB = db.steps?.allObjects as? [Step] ?? []
        let stepsList = StepViewModel.from(dbList: stepsListDB)
        let createdStepsListDB = db.createdSteps?.allObjects as? [CreatedStep] ?? []
        let createdStepsList = CreatedStepViewModel.from(dbList: createdStepsListDB)
        let historyListDB = db.history?.allObjects as? [History] ?? []
        let historyList = HistoryViewModel.from(dbList: historyListDB)
        
        let nextTasks: [TaskViewModel]
        if withLinked,
            let nextTasksDB = db.nextTasks?.array as? [Task] {
            nextTasks = nextTasksDB.flatMap({ (taskDB) -> TaskViewModel? in
                return from(db: taskDB, withLinked: false)
            })
        } else {
            nextTasks = []
        }
        
        let previousTasks: [TaskViewModel]
        if withLinked,
            let previousTasksDB = db.previousTasks?.array as? [Task] {
            previousTasks = previousTasksDB.flatMap({ (taskDB) -> TaskViewModel? in
                return from(db: taskDB, withLinked: false)
            })
        } else {
            previousTasks = []
        }
        
        return TaskViewModel(id: Int(db.id),
                             activated: db.activated,
                             status: status,
                             isFavorite: db.isFavorite,
                             creationDate: creationDate,
                             dueDate: db.dueDate,
                             endDate: db.endDate,
                             isPublic: db.isPublic,
                             title: title,
                             originLabel: db.originLabel ?? "",
                             creator: creator,
                             transmitter: transmiter,
                             attachment: attachment,
                             isModified: db.isModified,
                             isUrgent: db.isUrgent,
                             domain: domain,
                             service: service,
                             otherServices: serviceOtherList,
                             nextTask: nextTasks,
                             previousTask: previousTasks,
                             interventionType: interventionType,
                             interventionTypeComment: db.interventionComment ?? "",
                             modificationDate: db.modificationDate,
                             comment: db.comment ?? "",
                             transmitterComment: db.transmitterComment ?? "",
                             assigned: assigned,
                             location: location,
                             createdAttachment: createdAttachment,
                             patrimony: patrimony,
                             patrimonyComment: db.patrimonyComment ?? "",
                             steps: stepsList,
                             createdSteps: createdStepsList,
                             history: historyList)
    }
}

extension TaskViewModel {
    
    var webParameters: [String: Any] {
        var content = [String: Any]()
        var otherServicesId = [Int]()
        
        self.otherServices.forEach { (service) in
            otherServicesId.append(service.id)
        }
        
        content = [
            "domainId": self.domain?.id ?? -1,
            "serviceId": self.service?.id ?? -1,
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
            content["interventionComment"] = self.interventionTypeComment ?? ""
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
        } else if let attachment = self.attachment {
            content["attachement"] =  [
                "uuid": attachment.uuid
            ]
            content["fileId"] = attachment.uuid
        }
        
        if let patrimony = self.patrimony {
            content["patrimony"] =  [
                "id": patrimony.id,
                "comment": patrimonyComment ?? "",
                "key": patrimony.key
            ]
        }
        
        var parameters = [String: Any]()
        parameters["id"] = self.id
        parameters["isActive"] = true
        parameters["content"] = content
        
        return parameters
    }
}

extension Array where Element: TaskViewModel {
    
    var updatedTodayCount: Int {
        return self.reduce(0) { (previous, element) -> Int in
            if element.isUpdatedToday {
                return previous + 1
            }
            return previous
        }
    }
    
}
