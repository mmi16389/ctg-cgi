//
//  TaskAction.swift
//  GCI
//
//  Created by Florian ALONSO on 4/29/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

protocol TaskActionWorkflow {
    var actions: [TaskAction] { get }
}

enum TaskAction {
    case validate
    case assign
    case start
    case addStartStep
    case addEndStep
    case addStep
    case editStep
    case edit
    case finish
    case terminate
    case terminateAndCreate
    case reject
    case rejectWhenInProgress
    case cancel
    case undoValidate
    case undoAssign
    case changeAssign
    case editPlanDate
    case changeService
    case transferAndReject
    
    // Mark : Texts
    var title: String {
        let textKey: String
        switch self {
        case .validate:
            textKey = "task_action_validate"
        case .assign:
            textKey = "task_action_assign"
        case .start:
            textKey = "task_action_start"
        case .addStartStep:
            textKey = "task_action_step_start"
        case .addEndStep:
            textKey = "task_action_step_end"
        case .addStep:
            textKey = "task_action_step_custom"
        case .editStep:
            textKey = "task_action_step_edit"
        case .edit:
            textKey = "task_action_edit"
        case .finish:
            textKey = "task_action_finish"
        case .terminate:
            textKey = "task_action_close"
        case .terminateAndCreate:
            textKey = "task_action_close_and_create"
        case .reject:
            textKey = "task_action_reject"
        case .rejectWhenInProgress:
            textKey = "task_action_reject_when_in_progress"
        case .cancel:
            textKey = "task_action_cancel"
        case .undoValidate:
            textKey = "task_action_undo_validate"
        case .undoAssign:
            textKey = "task_action_undo_assign"
        case .changeAssign:
            textKey = "task_action_change_assignement"
        case .editPlanDate:
            textKey = "task_action_edit_plan_date"
        case .changeService:
            textKey = "task_action_edit_transfer"
        case .transferAndReject:
            textKey = "task_action_reject"
        }
        return textKey.localized
    }
    
    var confirmationMessage: String? {
        let textKey: String?
        switch self {
        case .validate:
            textKey = "action_confirmation_task_validate"
        case .start:
            textKey = "action_confirmation_task_start"
        case .finish:
            textKey = "action_confirmation_task_finish"
        case .terminate:
            textKey = "action_confirmation_task_close"
        case .undoValidate:
            textKey = "action_confirmation_task_undo_validation"
        case .undoAssign:
            textKey = "action_confirmation_task_undo_assign"
        default:
            textKey = nil
        }
        return textKey?.localized
    }
    
    var confirmationCode: DialogCode? {
        let code: DialogCode?
        switch self {
        case .validate:
            code = .validate
        case .start:
            code = .start
        case .finish:
            code = .finish
        case .undoValidate:
            code = .undoValidate
        case .undoAssign:
            code = .undoAssign
        default:
            code = nil
        }
        return code
    }
    
    // Mark : Images
    var icon: UIImage? {
        let image: UIImage?
        switch self {
        case .addStartStep, .addEndStep:
            image = UIImage(named: "ico_end_intervention_secondary_actions")
        case .edit, .editStep:
            image = UIImage(named: "ico_edit_DI_secondary actions")
        case .finish:
            image = UIImage(named: "ico_finish_secondary_actions")
        case .addStep, .terminateAndCreate:
            image = UIImage(named: "ico_add_step_secondary_actions")
        case .reject, .rejectWhenInProgress, .transferAndReject:
            image = UIImage(named: "ico_reject_DI_secondary_actions")
        case .cancel:
            image = UIImage(named: "ico_cancel_DI_secondary actions")
        case .undoValidate:
            image = UIImage(named: "ico_canceling_the_validation_DI")
        case .undoAssign:
            image = UIImage(named: "ico_cancel_the_assignment")
        case .changeAssign:
            image = UIImage(named: "ico_reassign")
        case .editPlanDate:
            image = UIImage(named: "ico_change_the_planning_date")!
        case .validate:
            image = nil // Will never have image
        case .assign:
            image = nil // Will never have image
        case .start:
            image = nil // Will never have image
        case .terminate:
            image = nil // Will never have image
        case .changeService:
            image = nil // Will never have image
        }
        return image
    }
    
    var executor: TaskActionExecutor? {
        let object: TaskActionExecutor?
        switch self {
        case .addStartStep :
            object = StartOrEndStepTaskActionExecutor(isStart: true)
        case .addEndStep :
            object = StartOrEndStepTaskActionExecutor(isStart: false)
        case .edit:
            object = EditTaskActionExecutor()
        case .editStep:
            object = EditStepTaskActionExecutor()
        case .finish:
            object = FinishTaskActionExecutor()
        case .addStep:
            object = AddStepTaskActionExecutor()
        case .terminateAndCreate:
            object = TerminateCreateTaskActionExecutor()
        case .reject, .rejectWhenInProgress:
            object = RejectTaskActionExecutor()
        case .cancel:
            object = CancelTaskActionExecutor()
        case .undoValidate:
            object = UndoValidateTaskActionExecutor()
        case .undoAssign:
            object = UndoAssignTaskActionExecutor()
        case .changeAssign:
            object = AssignTaskActionExecutor()
        case .editPlanDate:
            object = nil // This is canceled for now
        case .validate:
            object = ValidateTaskActionExecutor()
        case .assign:
            object = AssignTaskActionExecutor()
        case .start:
            object = StartTaskActionExecutor()
        case .terminate:
            object = TerminateTaskActionExecutor()
        case .changeService:
            object = ChangeServiceTaskActionExecutor()
        case .transferAndReject:
            object = TransferAndRejectActionExecutor()
        }
        return object
    }
    
}
