//
//  ExternalActionWokflowTests.swift
//  GCITests
//
//  Created by Florian ALONSO on 5/8/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import XCTest
@testable import GCI

class ExternalActionWokflowTests: XCTestCase {
    
    let currentUserSession = User.login(id: "current", webToken: "token", webRefreshToken: "refreshToken", webRefreshExpireInSeconds: 3600)
    let currentUser = TaskUserViewModel(id: "current")
    let otherUser = TaskUserViewModel(id: "other")
    
    override func setUp() {
    }
    
    override func tearDown() {
    }
    
    private func createTask(ofStatus status: TaskViewModel.Status, withCurrentUser: Bool, withDefinedInterventionType: Bool, andPermissions permissions: [ServiceViewModel.Permission] = [], andSteps stepsAction: [StepViewModel.Action] = []) -> TaskViewModel {
        
        let user = withCurrentUser ? currentUser : otherUser
        let service = ServiceViewModel(id: 1, name: "test", type: .notOperational, permissions: permissions)
        let interventionType = withDefinedInterventionType ? InterventionTypeViewModel(id: 1, name: "test", urgent: true, estimatedDurationSec: 3600) : nil
        
        let step = stepsAction.map { (action) -> StepViewModel in
            return StepViewModel(id: 1, date: Date(), title: "title", description: "desc", action: action)
        }
        
        return TaskViewModel(id: 1, activated: true, status: status, isFavorite: false, creationDate: Date(), dueDate: nil, endDate: nil, isPublic: false, title: "Title", originLabel: "", creator: user, transmitter: nil, attachment: nil, isModified: false, isUrgent: false, domain: nil, service: service, otherServices: [], interventionType: interventionType, interventionTypeComment: nil, modificationDate: nil, comment: "", transmitterComment: "", assigned: user, location: nil, createdAttachment: nil, patrimony: nil, patrimonyComment: nil, steps: step, createdSteps: [], history: [])
    }
    
    func testValidatePermission() {
        let awaitedActions: [TaskAction] = [
            .validate,
            .edit
        ]
        
        let task = createTask(ofStatus: .created, withCurrentUser: false, withDefinedInterventionType: true, andPermissions: [.read, .validate])
        let workflow = ExternalActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testValidateWithCancelPermission() {
        let awaitedActions: [TaskAction] = [
            .validate,
            .edit,
            .cancel
        ]
        
        let task = createTask(ofStatus: .created, withCurrentUser: false, withDefinedInterventionType: true, andPermissions: [.read, .validate, .cancel])
        let workflow = ExternalActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testValidatePermissionButNoInterventionType() {
        let awaitedActions: [TaskAction] = [
            .edit,
            .reject
        ]
        
        let task = createTask(ofStatus: .created, withCurrentUser: false, withDefinedInterventionType: false, andPermissions: [.read, .validate])
        let workflow = ExternalActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testNotValidatePermission() {
        let awaitedActions: [TaskAction] = [
        ]
        
        let task = createTask(ofStatus: .created, withCurrentUser: false, withDefinedInterventionType: true, andPermissions: [.read, .start])
        let workflow = ExternalActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testAssignPermission() {
        let awaitedActions: [TaskAction] = [
            .assign,
            .reject
        ]
        
        let task = createTask(ofStatus: .validated, withCurrentUser: false, withDefinedInterventionType: true, andPermissions: [.read, .assign])
        let workflow = ExternalActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testAssignWithValidatePermission() {
        let awaitedActions: [TaskAction] = [
            .assign,
            .reject,
            .undoValidate
        ]
        
        let task = createTask(ofStatus: .validated, withCurrentUser: false, withDefinedInterventionType: true, andPermissions: [.read, .validate, .assign])
        let workflow = ExternalActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testAssignWithCancelPermission() {
        let awaitedActions: [TaskAction] = [
            .assign,
            .reject,
            .cancel
        ]
        
        let task = createTask(ofStatus: .validated, withCurrentUser: false, withDefinedInterventionType: true, andPermissions: [.read, .assign, .cancel])
        let workflow = ExternalActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testNotAssignPermission() {
        let awaitedActions: [TaskAction] = [
        ]
        
        let task = createTask(ofStatus: .validated, withCurrentUser: false, withDefinedInterventionType: true, andPermissions: [.read, .start])
        let workflow = ExternalActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testNotAssignWithCancelPermission() {
        let awaitedActions: [TaskAction] = [
            .cancel
        ]
        
        let task = createTask(ofStatus: .validated, withCurrentUser: false, withDefinedInterventionType: true, andPermissions: [.read, .start, .cancel])
        let workflow = ExternalActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testStartAndChangeActionPermission() {
        let awaitedActions: [TaskAction] = [
        ]
        
        let task = createTask(ofStatus: .assigned, withCurrentUser: true, withDefinedInterventionType: true, andPermissions: [.read, .assign, .start])
        let workflow = ExternalActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testStartAndNotChangeActionPermission() {
        let awaitedActions: [TaskAction] = [
        ]
        
        let task = createTask(ofStatus: .assigned, withCurrentUser: true, withDefinedInterventionType: true, andPermissions: [.read, .start])
        let workflow = ExternalActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testNotStartPermission() {
        let awaitedActions: [TaskAction] = [
            .addStartStep,
            .addStep,
            .rejectWhenInProgress
        ]
        
        let task = createTask(ofStatus: .inProgress, withCurrentUser: true, withDefinedInterventionType: true, andPermissions: [.read, .validate])
        let workflow = ExternalActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testStartNotUserPermission() {
        let awaitedActions: [TaskAction] = [
        ]
        
        let task = createTask(ofStatus: .inProgress, withCurrentUser: false, withDefinedInterventionType: true, andPermissions: [.read, .start])
        let workflow = ExternalActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testStartNotUserWithCancelPermission() {
        let awaitedActions: [TaskAction] = [
            .cancel
        ]
        
        let task = createTask(ofStatus: .inProgress, withCurrentUser: false, withDefinedInterventionType: true, andPermissions: [.read, .start, .cancel])
        let workflow = ExternalActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testStartNoStepsPermission() {
        let awaitedActions: [TaskAction] = [
            .addStartStep,
            .addStep,
            .rejectWhenInProgress
        ]
        
        let task = createTask(ofStatus: .inProgress, withCurrentUser: true, withDefinedInterventionType: true, andPermissions: [.read, .start])
        let workflow = ExternalActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testStartAndStartStepPermission() {
        let awaitedActions: [TaskAction] = [
            .addStep,
            .addEndStep,
            .finish,
            .rejectWhenInProgress
        ]
        
        let task = createTask(ofStatus: .inProgress, withCurrentUser: true, withDefinedInterventionType: true, andPermissions: [.read, .start], andSteps: [.start])
        let workflow = ExternalActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testStartAndStandardStepPermission() {
        let awaitedActions: [TaskAction] = [
            .addStep,
            .addEndStep,
            .finish,
            .rejectWhenInProgress
        ]
        
        let task = createTask(ofStatus: .inProgress, withCurrentUser: true, withDefinedInterventionType: true, andPermissions: [.read, .start], andSteps: [.start, .standard])
        let workflow = ExternalActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testStartAndStandardAndNoStartStepPermission() {
        let awaitedActions: [TaskAction] = [
            .addStartStep,
            .finish,
            .addStep,
            .rejectWhenInProgress
        ]
        
        let task = createTask(ofStatus: .inProgress, withCurrentUser: true, withDefinedInterventionType: true, andPermissions: [.read, .start], andSteps: [.standard])
        let workflow = ExternalActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testStartAndFullStepPermission() {
        let awaitedActions: [TaskAction] = [
            .finish,
            .addStep,
            .rejectWhenInProgress
        ]
        
        let task = createTask(ofStatus: .inProgress, withCurrentUser: true, withDefinedInterventionType: true, andPermissions: [.read, .start], andSteps: [.start, .standard, .end])
        let workflow = ExternalActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testFinishedNoPermissionPermission() {
        let awaitedActions: [TaskAction] = [
        ]
        
        let task = createTask(ofStatus: .finished, withCurrentUser: false, withDefinedInterventionType: true, andPermissions: [.read, .start], andSteps: [.start])
        let workflow = ExternalActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testFinishedCancelPermission() {
        let awaitedActions: [TaskAction] = [
            .cancel
        ]
        
        let task = createTask(ofStatus: .finished, withCurrentUser: false, withDefinedInterventionType: true, andPermissions: [.read, .start, .cancel], andSteps: [.start])
        let workflow = ExternalActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testFinishedPermission() {
        let awaitedActions: [TaskAction] = [
            .terminate,
            .terminateAndCreate,
            .cancel
        ]
        
        let task = createTask(ofStatus: .finished, withCurrentUser: false, withDefinedInterventionType: true, andPermissions: [.read, .close, .cancel], andSteps: [.start])
        let workflow = ExternalActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
}
