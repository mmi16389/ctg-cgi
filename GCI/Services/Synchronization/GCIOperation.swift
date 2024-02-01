//
//  GCIOperation.swift
//  GCI
//
//  Created by Florian ALONSO on 5/13/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

enum GCIOperationResult {
    case success
    case errorUpload(String)
    case errorDownload
    case noInternet
    
    var errorMessage: String {
        let message: String
        switch self {
        case .errorUpload(let messageGiven):
            message = messageGiven
        case .errorDownload:
            message = "error_general".localized
        case .noInternet:
            message = "error_banner_internet".localized
        default:
            message = ""
        }
        return message
    }
}

protocol GCIOperationDelegate: class {
    func didFinish(operation: GCIOperation, withResult result: GCIOperationResult)
}

class GCIOperation: GCIOperationDelegate {
    
    weak var delegate: GCIOperationDelegate?
    var isBlocking = false
    
    private let nextOperation: GCIOperation?
    var internalResult: GCIOperationResult? {
        didSet {
            finish()
            
            if isBlocking {
                startNextOperation()
            }
        }
    }
    
    var computedResult: GCIOperationResult? {
        guard let nextOperation = nextOperation, let computedNextResult = nextOperation.computedResult else {
            return internalResult
        }
        
        switch computedNextResult {
        case .success:
            return internalResult
        default:
            return computedNextResult
        }
    }
    
    var isDone: Bool {
        guard let nextOperation = self.nextOperation else {
            return internalResult != nil
        }
        return internalResult != nil && nextOperation.isDone
    }
    
    init(nextOperation: GCIOperation?) {
        self.nextOperation = nextOperation
    }
    
    private func finish() {
        DispatchQueue.main.async {
            guard self.isDone else {
                return
            }
            
            if let nextOperation = self.nextOperation {
                if nextOperation.isDone, let computedResult = self.computedResult {
                    self.delegate?.didFinish(operation: self, withResult: computedResult)
                }
            } else if let internalResult = self.internalResult {
                self.delegate?.didFinish(operation: self, withResult: internalResult)
            }
        }
    }
    
    final func start() {
        if !isBlocking {
            startNextOperation()
        }
        
        DispatchQueue.global().async {
            self.run()
        }
    }
    
    final func startNextOperation() {
        guard let nextOperation = self.nextOperation else {
            return
        }
        nextOperation.delegate = self
        nextOperation.start()
    }
    
    func run() {
    }
    
    func didFinish(operation: GCIOperation, withResult result: GCIOperationResult) {
        finish()
    }
}
