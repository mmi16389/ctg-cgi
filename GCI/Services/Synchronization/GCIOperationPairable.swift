//
//  GCIOperationPairable.swift
//  GCI
//
//  Created by Florian ALONSO on 5/27/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class GCIOperationPaired: GCIOperation {
    
    private let operationPairedOne: GCIOperationPairable
    private let operationPairedTwo: GCIOperationPairable
    
    private var internalPairedResultOne: GCIOperationResult?
    private var internalPairedResultTwo: GCIOperationResult?
    
    override var isDone: Bool {
        return internalPairedResultOne != nil && internalPairedResultTwo != nil
    }
    
    init(nextOperation: GCIOperation?, operationPairedOne: GCIOperationPairable, operationPairedTwo: GCIOperationPairable) {
        self.operationPairedOne = operationPairedOne
        self.operationPairedTwo = operationPairedTwo
        self.operationPairedOne.isPaired = true
        self.operationPairedTwo.isPaired = true
        super.init(nextOperation: nextOperation)
    }
    
    override func run() {
        launchFirstOperation()
    }
    
    func launchFirstOperation() {
        self.operationPairedOne.delegate = self
        self.operationPairedOne.start()
    }
    
    func launchSecondOperation() {
        self.operationPairedTwo.delegate = self
        self.operationPairedTwo.start()
    }
    
    override func didFinish(operation: GCIOperation, withResult result: GCIOperationResult) {
        if operation === operationPairedOne {
            internalPairedResultOne = result
            
            if case .success = result {
                launchSecondOperation()
            } else {
                internalPairedResultTwo = result
                internalResult = result
            }
            
        } else if operation === operationPairedTwo {
            internalPairedResultTwo = result
            var isSuccessOne = false
            var isSuccessTwo = false
            if case .success? = internalPairedResultOne {
                isSuccessOne = true
            }
            if case .success? = internalPairedResultTwo {
                isSuccessTwo = true
            }
            
            if !isSuccessTwo && isSuccessOne {
                self.operationPairedOne.runRollback()
            } else {
                self.operationPairedOne.runSuccess()
                self.operationPairedTwo.runSuccess()
            }
            internalResult = result
            
        } else {
            super.didFinish(operation: operation, withResult: result)
        }
    }
    
}

// MARK: GCIOperationPairable
class GCIOperationPairable: GCIOperation {
    
    var isPaired: Bool = false
    
    override var internalResult: GCIOperationResult? {
        didSet {
            
            var isSuccess = false
            if case .success? = self.internalResult {
                isSuccess = true
            }
            
            if isSuccess && !isPaired {
                self.runSuccess()
            } else if !isPaired && !isSuccess {
                self.runRollback()
            }
        }
    }
    
    func runRollback() {
        print("⚠️⚠️⚠️⚠️⚠️")
        print("SHOULD BE OVERRIDED")
        print("⚠️⚠️⚠️⚠️⚠️")
    }
    
    func runSuccess() {
        print("⚠️⚠️⚠️⚠️⚠️")
        print("SHOULD BE OVERRIDED")
        print("⚠️⚠️⚠️⚠️⚠️")
    }
    
}
