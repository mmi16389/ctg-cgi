//
//  NonOperationalActionWorkflow.swift
//  GCI
//
//  Created by Florian ALONSO on 5/2/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class NonOperationalActionWorkflow: TaskActionWorkflow {
    
    let task: TaskViewModel
    
    init(task: TaskViewModel) {
        self.task = task
    }
    
    var actions: [TaskAction] {
        let taskActionSet = NSMutableOrderedSet()
        
        guard task.isVisible else {
            return []
        }
        
        if task.canValidate {
            taskActionSet.add(TaskAction.changeService)
            taskActionSet.add(TaskAction.edit)
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
