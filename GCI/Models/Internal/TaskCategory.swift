//
//  TaskCategory.swift
//  GCI
//
//  Created by Florian ALONSO on 4/30/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

enum TaskCategory {
    case new
    case validated
    case assigned
    case inProgress
    case finished
    case global
    
    // Mark : Texts
    var title: String {
        let textKey: String?
        switch self {
        case .new:
            textKey = "tasks_status_new"
        case .validated:
            textKey = "tasks_status_validated"
        case .assigned:
            textKey = "tasks_status_assign"
        case .inProgress:
            textKey = "tasks_status_in_progress"
        case .finished:
            textKey = "tasks_status_finished"
        case .global:
            textKey = nil
        }
        return textKey?.localized ?? ""
    }
    
    var permissionsGranted: [ServiceViewModel.Permission] {
        let permissions: [ServiceViewModel.Permission]
        switch self {
        case .new:
            permissions = [.validate]
        case .validated:
            permissions = [.assign, .validate]
        case .assigned:
            permissions = [.start, .assign]
        case .inProgress:
            permissions = [.start]
        case .finished:
            permissions = [.close]
        case .global:
            permissions = []
        }
        return permissions
    }
}
