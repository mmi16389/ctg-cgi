//
//  NonOperationalActionWorkflowTests.swift
//  GCITests
//
//  Created by Florian ALONSO on 5/3/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import XCTest
@testable import GCI

class NonOperationalActionWorkflowTests: XCTestCase {
    
    let currentUser = TaskUserViewModel(id: "current")
    let otherUser = TaskUserViewModel(id: "other")
    
    override func setUp() {
    }
    
    override func tearDown() {
    }
    
    private func createTask(ofStatus status: TaskViewModel.Status, withCurrentUser: Bool, andPermissions permissions: [ServiceViewModel.Permission] = []) -> TaskViewModel {
        
        let user = withCurrentUser ? currentUser : otherUser
        let service = ServiceViewModel(id: 1, name: "test", type: .notOperational, permissions: permissions)
        
        return TaskViewModel(id: 1, activated: true, status: status, isFavorite: false, creationDate: Date(), dueDate: nil, endDate: nil, isPublic: false, title: "Title", originLabel: "", creator: user, transmitter: nil, attachment: nil, isModified: false, isUrgent: false, domain: nil, service: service, otherServices: [], interventionType: nil, interventionTypeComment: nil, modificationDate: nil, comment: "", transmitterComment: "", assigned: nil, location: nil, createdAttachment: nil, patrimony: nil, patrimonyComment: nil, steps: [], createdSteps: [], history: [])
    }
    
    func testNonReadPermission() {
        let awaitedActions = [TaskAction]()
        
        let task = createTask(ofStatus: .created, withCurrentUser: true, andPermissions: [])
        let workflow = NonOperationalActionWorkflow(task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testReadPermission() {
        let awaitedActions = [TaskAction]()
        
        let task = createTask(ofStatus: .created, withCurrentUser: true, andPermissions: [.read])
        let workflow = NonOperationalActionWorkflow(task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testValidateButWithoutReadPermission() {
        let awaitedActions: [TaskAction] = [
            .changeService,
            .edit,
            .reject
        ]
        
        let task = createTask(ofStatus: .created, withCurrentUser: true, andPermissions: [.validate])
        let workflow = NonOperationalActionWorkflow(task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testValidatePermission() {
        let awaitedActions: [TaskAction] = [
            .changeService,
            .edit,
            .reject
        ]
        
        let task = createTask(ofStatus: .created, withCurrentUser: true, andPermissions: [.read, .validate])
        let workflow = NonOperationalActionWorkflow(task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testValidateNotOrderedPermission() {
        let awaitedActions: [TaskAction] = [
            .reject,
            .changeService,
            .edit
        ]
        
        let task = createTask(ofStatus: .created, withCurrentUser: true, andPermissions: [.read, .validate])
        let workflow = NonOperationalActionWorkflow(task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertNotEqual(awaitedActions, actionsCalculated)
    }
    
    func testValidateButInProgressPermission() {
        let awaitedActions: [TaskAction] = [
        ]
        
        let task = createTask(ofStatus: .inProgress, withCurrentUser: true, andPermissions: [.read, .validate])
        let workflow = NonOperationalActionWorkflow(task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testValidateButAssignedPermission() {
        let awaitedActions: [TaskAction] = [
        ]
        
        let task = createTask(ofStatus: .assigned, withCurrentUser: true, andPermissions: [.read, .validate])
        let workflow = NonOperationalActionWorkflow(task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
    func testValidateButValidatedPermission() {
        let awaitedActions: [TaskAction] = [
        ]
        
        let task = createTask(ofStatus: .validated, withCurrentUser: true, andPermissions: [.read, .validate])
        let workflow = NonOperationalActionWorkflow(task: task)
        
        let actionsCalculated = workflow.actions
        XCTAssertEqual(awaitedActions, actionsCalculated)
    }
    
}
