//
//  ExternalActionWokflow.swift
//  GCI
//
//  Created by Florian ALONSO on 5/2/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class ExternalActionWokflow: StandardActionWorkflow {
    
    override var actions: [TaskAction] {
        // The difference of workflow between standard and external is handled in the backend
        // By security the actions of the state assigned are removed
        if task.status == .assigned {
            return []
        } else if task.canAssign {            
            return [
                TaskAction.start,
                TaskAction.reject,
                TaskAction.undoValidate
            ]
        } else if task.isInProgress && !task.canStart {
            return []
        }
        return super.actions
    }
}
