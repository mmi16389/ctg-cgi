//
//  CreatedStepViewModel.swift
//  GCI
//
//  Created by Florian ALONSO on 4/26/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import CoreData

class CreatedStepViewModel: ViewableStep, Comparable {
    static func == (lhs: CreatedStepViewModel, rhs: CreatedStepViewModel) -> Bool {
        return lhs.date == rhs.date
    }
    
    static func < (lhs: CreatedStepViewModel, rhs: CreatedStepViewModel) -> Bool {
        return lhs.date < rhs.date
    }
    
    let taskId: Int
    let action: StepViewModel.Action
    let date: Date
    let title: String
    let description: String
    let createdAttachment: CreatedAttachmentViewModel?
    let isPendingStep = true
    let internalId: Int

    var displayableAttachment: ViewableAttachment? {
        return createdAttachment
    }
    
    var isPendingFile: Bool {
        return createdAttachment != nil
    }
    
    var userFullName: String {
        return User.currentUser()?.fullname ?? ""
    }
    
    var userIdentifier: String {
        return User.currentUser()?.id ?? ""
    }
    
    init(internalId: Int = -1, taskId: Int, action: StepViewModel.Action, date: Date, title: String, description: String, createdAttachment: CreatedAttachmentViewModel? = nil) {
        self.internalId = internalId
        self.taskId = taskId
        self.action = action
        self.date = date
        self.description = description
        self.createdAttachment = createdAttachment
        
        if title.isEmpty && action == .start {
            self.title = "task_action_step_start".localized
        } else if title.isEmpty && action == .end {
            self.title = "task_action_step_end".localized
        } else {
            self.title = title
        }
    }
    
}

extension CreatedStepViewModel: Convertible {
    
    static func from(db: CreatedStep) -> CreatedStepViewModel? {
        guard let action = StepViewModel.Action(rawValue: Int(db.action)),
            let date = db.date else {
                return nil
        }
        
        let createdAttachment = CreatedAttachmentViewModel.from(db: db.createdAttachment)
        
        return CreatedStepViewModel(internalId: Int(db.internalId),
                                    taskId: Int(db.task?.id ?? 0),
                                    action: action,
                                    date: date,
                                    title: db.title ?? "",
                                    description: db.desc ?? "",
                                    createdAttachment: createdAttachment)
    }
}

extension CreatedStepViewModel {
    
    var webParameters: [String: Any] {
        var content = [String: Any]()
        content = [
            "action": self.action.rawValue,
            "date": DateHelper.requestDateFormater.string(from: self.date)
        ]
        if (self.action == .start && self.title == "task_action_step_start".localized)
        || (self.action == .end && self.title == "task_action_step_end".localized) {
            content["title"] = ""
        } else {
            content["title"] = self.title
        }
        content["description"] = self.description
        
        if let attachment = self.createdAttachment, let uuid = attachment.uuid {
            content["attachement"] =  [
                "uuid": uuid
            ]
            content["fileId"] = uuid
        }
        
        return content
    }
}

extension CreatedStepViewModel: ModalSelectListItemsDataSource {
    var displayableTitle: String {
        return self.title
    }
    
    var displayableSubtitle: String? {
        return nil
    }
    var displayableAnnotation: String? {
        return nil
    }
}
