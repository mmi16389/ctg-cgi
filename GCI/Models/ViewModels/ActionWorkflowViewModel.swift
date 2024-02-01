//
//  ActionWorkflowViewModel.swift
//  GCI
//
//  Created by Florian ALONSO on 4/23/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class ActionWorkflowViewModel {
    let taskId: Int
    let workflowAction: WorkflowAction
    let taskAction: TaskAction
    let date: Date
    var title: String?
    var description: String?
    var userId: String?
    var createdTask: CreatedTaskViewModel?
    
    init(taskId: Int, workflowAction: WorkflowAction, taskAction: TaskAction, date: Date = Date()) {
        self.taskId = taskId
        self.workflowAction = workflowAction
        self.taskAction = taskAction
        self.date = date
    }
}

extension ActionWorkflowViewModel {
    enum WorkflowAction: Int {
        case next = 0
        case cancel = 1
        case reject = 2
        case undo = 3
    }
    
    enum TaskAction: Int {
        case validate = 1
        case assign = 2
        case start = 3
        case cancel = 4
        case refuse = 5
        case finish = 6
        case close = 7
    }
}

extension ActionWorkflowViewModel: Convertible {
    
    static func from(db: ActionWorkflow) -> ActionWorkflowViewModel? {
        guard let taskAction = TaskAction(rawValue: Int(db.taskAction)),
            let workflowAction = WorkflowAction(rawValue: Int(db.workflowAction)),
            let date = db.date,
            let taskId = db.task?.id else {
            return nil
        }
        let viewModel = ActionWorkflowViewModel(taskId: Int(taskId),
                                       workflowAction: workflowAction,
                                       taskAction: taskAction,
                                       date: date)
        
        viewModel.description = db.desc
        viewModel.title = db.title
        viewModel.userId = db.userId
        viewModel.createdTask = CreatedTaskViewModel.from(db: db.createdTask)
        
        return viewModel
    }
}

extension ActionWorkflowViewModel {
    
    var webParameters: [String: Any] {
        var parameters = [String: Any]()
        parameters["date"] = DateHelper.requestDateFormater.string(from: self.date)
        parameters["action"] = self.taskAction.rawValue
        if let title = self.title {
            parameters["title"] = title
        }
        if let description = self.description {
            parameters["description"] = description
        }
        if let userId = self.userId {
            parameters["userId"] = userId
        }
        
        if let createdTask = self.createdTask {
            parameters["task"] = createdTask.webParameters
        }
        
        return parameters
    }
}
