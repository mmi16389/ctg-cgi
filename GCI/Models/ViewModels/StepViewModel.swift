//
//  StepViewModel.swift
//  GCI
//
//  Created by Florian ALONSO on 4/23/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import UIKit

protocol ViewableStep: TimeableViewModel, ModalSelectListItemsDataSource {
    var action: StepViewModel.Action { get }
    var displayableAttachment: ViewableAttachment? { get }
    var isPendingStep: Bool { get }
    var isPendingFile: Bool { get }
}

extension StepViewModel: ModalSelectListItemsDataSource {
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

class StepViewModel: ViewableStep, Comparable {
    static func == (lhs: StepViewModel, rhs: StepViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: StepViewModel, rhs: StepViewModel) -> Bool {
        return lhs.date < rhs.date
    }
    
    let id: Int
    let date: Date
    let title: String
    let description: String
    let action: StepViewModel.Action
    let attachment: AttachmentViewModel?
    let createdAttachment: CreatedAttachmentViewModel?
    let user: TaskUserViewModel?
    let isPendingStep: Bool = false
    
    var displayableAttachment: ViewableAttachment? {
        return createdAttachment != nil ? createdAttachment : attachment
    }
    
    var isPendingFile: Bool {
        return createdAttachment != nil
    }
    
    var userFullName: String {
        return user?.fullname ?? ""
    }
    
    var userIdentifier: String {
        return user?.id ?? ""
    }
    
    init(id: Int, date: Date, title: String, description: String, action: StepViewModel.Action, attachment attachmentOpt: AttachmentViewModel? = nil, createdAttachment createdAttachmentOpt: CreatedAttachmentViewModel? = nil, user userOpt: TaskUserViewModel? = nil) {
        self.id = id
        self.date = date
        self.description = description
        self.action = action
        self.attachment = attachmentOpt
        self.createdAttachment = createdAttachmentOpt
        self.user = userOpt
        
        if title.isEmpty && action == .start {
            self.title = "task_action_step_start".localized
        } else if title.isEmpty && action == .end {
            self.title = "task_action_step_end".localized
        } else {
            self.title = title
        }
    }
    
}

extension StepViewModel {
    enum Action: Int {
        case standard = 1
        case start = 2
        case end = 3
    }
}

extension StepViewModel: Convertible {
    
    static func from(db: Step) -> StepViewModel? {
        guard let date = db.date,
            let action = StepViewModel.Action(rawValue: Int(db.action)) else {
            return nil
        }
        
        let attachment = AttachmentViewModel.from(db: db.attachment)
        let createdAttachment = CreatedAttachmentViewModel.from(db: db.createdAttachment)
        let user = TaskUserViewModel.from(db: db.user)
        
        return StepViewModel(id: Int(db.id),
                             date: date,
                             title: db.title ?? "",
                             description: db.desc ?? "",
                             action: action,
                             attachment: attachment,
                             createdAttachment: createdAttachment,
                             user: user)
    }
}

extension StepViewModel {
    
    var webParameters: [String: Any] {
        var content = [String: Any]()
        content = [
            "action": self.action.rawValue,
            "date": DateHelper.requestDateFormater.string(from: self.date)
        ]
        
        content["title"] = self.title
        content["description"] = self.description
        
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
        
        return content
    }
}
