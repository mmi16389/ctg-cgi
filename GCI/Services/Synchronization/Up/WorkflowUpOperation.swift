//
//  WorkflowUpOperation.swift
//  GCI
//
//  Created by Florian ALONSO on 5/24/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import CoreData

class WorkflowUpOperation: GCIOperationPairable {
    
    let dataService: WorkflowDataService
    let daoService: WorkflowDAOService
    let id: Int
    
    init(forId id: Int, dataService: WorkflowDataService, daoService: WorkflowDAOService, nextOperation: GCIOperation? = nil) {
        self.dataService = dataService
        self.daoService = daoService
        self.id = id
        super.init(nextOperation: nextOperation)
    }
    
    override func run() {
        daoService.unique(byId: id) { (actionWorkflowOpt) in
            guard let actionWorkflow = actionWorkflowOpt else {
                self.internalResult = .errorUpload("error_general".localized)
                return
            }
            let taskId = actionWorkflow.task?.id ?? 0
            
            self.dataService.forceSynchronization(forAction: actionWorkflow, completion: { (result) in
                switch result {
                case .success:
                    self.internalResult = .success
                case .failed(let error):
                    
                    switch error {
                    case .noNetwork:
                        self.internalResult = .noInternet
                    case .denied:
                        
                        self.daoService.delete(byId: self.id, completion: { (_) in
                            
                            let id = "\(taskId)"
                            let message = "error_workflow_task_denied".localized(arguments: String(id))
                            self.internalResult = .errorUpload(message)
                        })
                        
                    default:
                        let id = "\(taskId)"
                        let message = "error_workflow_task".localized(arguments: String(id))
                        self.internalResult = .errorUpload(message)
                    }
                }
            })
        }
    }
    
    override func runRollback() {
        // DO NOTHING
    }
    
    override func runSuccess() {
        self.daoService.delete(byId: self.id, completion: { (_) in
        })
    }
}
