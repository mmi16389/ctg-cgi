//
//  StandardWorkflow.swift
//  GCI
//
//  Created by Florian ALONSO on 5/2/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class StandardActionWorkflow: TaskActionWorkflow {
    
    let user: User
    let task: TaskViewModel
    
    init(user: User, task: TaskViewModel) {
        self.user = user
        self.task = task
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
        } else if task.canAssign {
            taskActionSet.add(TaskAction.assign)
            taskActionSet.add(TaskAction.reject)
        } else if task.isAssigned(to: user) && task.canStart {
            taskActionSet.add(TaskAction.start)
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
            } else if hasStartStep && !hasEndStep {
                taskActionSet.add(TaskAction.addStep)
                taskActionSet.add(TaskAction.addEndStep)
                if hasEditableSteps {
                    taskActionSet.add(TaskAction.editStep)
                }
                taskActionSet.add(TaskAction.finish)
            } else if hasEndStep {
                taskActionSet.add(TaskAction.finish)
                taskActionSet.add(TaskAction.addStep)
                if hasEditableSteps {
                    taskActionSet.add(TaskAction.editStep)
                }
            } else {
                taskActionSet.add(TaskAction.addStartStep)
                taskActionSet.add(TaskAction.finish)
                taskActionSet.add(TaskAction.addStep)
                if hasEditableSteps {
                    taskActionSet.add(TaskAction.editStep)
                }
            }
            taskActionSet.add(TaskAction.rejectWhenInProgress)
            
        } else if task.canClose {
            taskActionSet.add(TaskAction.terminate)
            taskActionSet.add(TaskAction.terminateAndCreate)
        }
        
        if task.canUndoValidate {
            taskActionSet.add(TaskAction.undoValidate)
        }
        
        if task.canUndoAssign {
            taskActionSet.add(TaskAction.changeAssign)
            taskActionSet.add(TaskAction.undoAssign)
        }
        
        if task.canEditPlannedDate {
            taskActionSet.add(TaskAction.editPlanDate)
        }
        
        if task.canCancel {
            taskActionSet.add(TaskAction.cancel)
        }
        
        return taskActionSet.array as? [TaskAction] ?? []
    }
}
