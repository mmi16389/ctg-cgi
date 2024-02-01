//
//  GmaoActionWokflow.swift
//  GCI
//
//  Created by Florian ALONSO on 5/2/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class GmaoActionWokflow: TaskActionWorkflow {
    
    let task: TaskViewModel
    let user: User
    
    init(user: User, task: TaskViewModel) {
        self.task = task
        self.user = user
    }
    
    var actions: [TaskAction] {
        let taskActionSet = NSMutableOrderedSet()
        
        guard task.isVisible else {
            return []
        }
        
        if task.canValidate && task.interventionType != nil {
            taskActionSet.add(TaskAction.validate)
            taskActionSet.add(TaskAction.edit)
            taskActionSet.add(TaskAction.transferAndReject)
        } else if task.canValidate {
            taskActionSet.add(TaskAction.edit)
            taskActionSet.add(TaskAction.reject)
        } else if task.isInProgress && task.isAssigned(to: user) {
            let allSteps = self.task.allSteps
            let hasStep = !allSteps.isEmpty
            let hasStartStep = allSteps.first { (step) in
                return step.action == .start
                } != nil
            let hasEndStep = allSteps.first { (step) in
                return step.action == .end
                } != nil
            let hasEditableSteps = !task.displayableAndEditableSteps(forUser: user).isEmpty
            
            if !hasStep {
                taskActionSet.add(TaskAction.addStartStep)
                taskActionSet.add(TaskAction.addStep)
            } else {
                if !hasStartStep {
                    taskActionSet.add(TaskAction.addStartStep)
                }
                taskActionSet.add(TaskAction.addStep)
                if hasStartStep && !hasEndStep {
                    taskActionSet.add(TaskAction.addEndStep)
                }
                if hasEditableSteps {
                    taskActionSet.add(TaskAction.editStep)
                }
            }
        }
        
        if task.canEditPlannedDate {
            taskActionSet.add(TaskAction.editPlanDate)
        }
        
        if task.status == .created && task.canCancel {
            taskActionSet.add(TaskAction.cancel)
        }
        
        return taskActionSet.array as? [TaskAction] ?? []
    }
}
