//
//  StepEditionUpOperation.swift
//  GCI
//
//  Created by Anthony Chollet on 26/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import CoreData

class StepEditionUpOperation: GCIOperationPairable {
    let taskDataService: TaskDataService
    let daoService: StepDAOService
    let id: Int
    
    init(forId id: Int, taskDataService: TaskDataService, daoService: StepDAOService, nextOperation: GCIOperation? = nil) {
        self.taskDataService = taskDataService
        self.daoService = daoService
        self.id = id
        super.init(nextOperation: nextOperation)
    }
    
    override func run() {
        daoService.unique(byId: self.id) { (editStepOpt) in
            guard editStepOpt != nil,
                let taskID = editStepOpt?.task?.id,
                let viewModel = StepViewModel.from(db: editStepOpt) else {
                    self.internalResult = .errorUpload("error_general".localized)
                    return
            }
            
            self.taskDataService.forceSyncronizeEditedStep(fromStep: viewModel, taskID: Int(taskID), withCompletion: { (result) in
                
                switch result {
                case .success:
                    self.internalResult = .success
                case .failed(let error ):
                    
                    switch error {
                    case .noNetwork:
                        self.internalResult = .noInternet
                    case .denied:
                        self.daoService.markAsEditionDone(byId: self.id) { (_) in
                            let message = "error_adding_step_denied".localized(arguments: viewModel.description)
                            self.internalResult = .errorUpload(message)
                        }
                    default:
                        let message = "error_adding_step".localized(arguments: viewModel.description)
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
        self.daoService.markAsEditionDone(byId: self.id) { (_) in
            
        }
    }
}
