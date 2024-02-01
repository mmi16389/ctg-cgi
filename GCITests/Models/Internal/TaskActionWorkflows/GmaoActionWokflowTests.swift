//
//  GmaoActionWokflowTests.swift
//  GCITests
//
//  Created by Florian ALONSO on 5/6/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import XCTest
@testable import GCI

class GmaoActionWokflowTests: XCTestCase {
    
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
        let workflow = GmaoActionWokflow(user: currentUserSession, task: task)
        
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
        let workflow = GmaoActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testValidatePermissionButNoInterventionType() {
        let awaitedActions: [TaskAction] = [
            .edit,
            .reject
        ]
        
        let task = createTask(ofStatus: .created, withCurrentUser: false, withDefinedInterventionType: false, andPermissions: [.read, .validate])
        let workflow = GmaoActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testNotValidatePermission() {
        let awaitedActions: [TaskAction] = [
        ]
        
        let task = createTask(ofStatus: .created, withCurrentUser: false, withDefinedInterventionType: true, andPermissions: [.read, .start])
        let workflow = GmaoActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testAssignPermission() {
        let awaitedActions: [TaskAction] = [
        ]
        
        let task = createTask(ofStatus: .validated, withCurrentUser: false, withDefinedInterventionType: true, andPermissions: [.read, .assign])
        let workflow = GmaoActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testNotAssignPermission() {
        let awaitedActions: [TaskAction] = [
        ]
        
        let task = createTask(ofStatus: .validated, withCurrentUser: false, withDefinedInterventionType: true, andPermissions: [.read, .validate])
        let workflow = GmaoActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testClosePermission() {
        let awaitedActions: [TaskAction] = [
        ]
        
        let task = createTask(ofStatus: .finished, withCurrentUser: false, withDefinedInterventionType: true, andPermissions: [.read, .close])
        let workflow = GmaoActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testNotClosePermission() {
        let awaitedActions: [TaskAction] = [
        ]
        
        let task = createTask(ofStatus: .finished, withCurrentUser: false, withDefinedInterventionType: true, andPermissions: [.read, .validate])
        let workflow = GmaoActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testNotStartPermission() {
        let awaitedActions: [TaskAction] = [
            .addStartStep,
            .addStep
        ]
        
        let task = createTask(ofStatus: .inProgress, withCurrentUser: true, withDefinedInterventionType: true, andPermissions: [.read, .validate])
        let workflow = GmaoActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testStartNotUserPermission() {
        let awaitedActions: [TaskAction] = [
        ]
        
        let task = createTask(ofStatus: .inProgress, withCurrentUser: false, withDefinedInterventionType: true, andPermissions: [.read, .start])
        let workflow = GmaoActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testStartNoStepsPermission() {
        let awaitedActions: [TaskAction] = [
            .addStartStep,
            .addStep
        ]
        
        let task = createTask(ofStatus: .inProgress, withCurrentUser: true, withDefinedInterventionType: true, andPermissions: [.read, .start])
        let workflow = GmaoActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testStartAndStartStepPermission() {
        let awaitedActions: [TaskAction] = [
            .addStep,
            .addEndStep
        ]
        
        let task = createTask(ofStatus: .inProgress, withCurrentUser: true, withDefinedInterventionType: true, andPermissions: [.read, .start], andSteps: [.start])
        let workflow = GmaoActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testStartAndStandardStepPermission() {
        let awaitedActions: [TaskAction] = [
            .addStep,
            .addEndStep
        ]
        
        let task = createTask(ofStatus: .inProgress, withCurrentUser: true, withDefinedInterventionType: true, andPermissions: [.read, .start], andSteps: [.start, .standard])
        let workflow = GmaoActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testStartAndStandardAndNoStartStepPermission() {
        let awaitedActions: [TaskAction] = [
            .addStartStep,
            .addStep
        ]
        
        let task = createTask(ofStatus: .inProgress, withCurrentUser: true, withDefinedInterventionType: true, andPermissions: [.read, .start], andSteps: [.standard])
        let workflow = GmaoActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testStartAndFullStepPermission() {
        let awaitedActions: [TaskAction] = [
            .addStep
        ]
        
        let task = createTask(ofStatus: .inProgress, withCurrentUser: true, withDefinedInterventionType: true, andPermissions: [.read, .start], andSteps: [.start, .standard, .end])
        let workflow = GmaoActionWokflow(user: currentUserSession, task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
}
