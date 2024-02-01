//
//  CreatedStepUpOperation.swift
//  GCI
//
//  Created by Anthony Chollet on 24/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import CoreData

class CreatedStepUpOperation: GCIOperationPairable {
    let taskDataService: TaskDataService
    let createdDaoService: CreatedStepDAOService
    let id: Int
    
    init(forId id: Int, taskDataService: TaskDataService, createdDaoService: CreatedStepDAOService, nextOperation: GCIOperation? = nil) {
        self.taskDataService = taskDataService
        self.createdDaoService = createdDaoService
        self.id = id
        super.init(nextOperation: nextOperation)
    }
    
    override func run() {
        createdDaoService.unique(byId: self.id) { (createdStepOpt) in
            guard let createdStep = createdStepOpt,
                let viewModel = CreatedStepViewModel.from(db: createdStep) else {
                    self.internalResult = .errorUpload("error_general".localized)
                    return
            }
            
            self.taskDataService.forceSynchronizeNewStep(fromCreatedStep: viewModel, withCompletion: { (result) in
                
                switch result {
                case .success:
                    self.internalResult = .success
                case .failed(let error ):
                    
                    switch error {
                    case .noNetwork:
                        self.internalResult = .noInternet
                    case .denied:
                        self.createdDaoService.delete(byId: self.id, completion: { (_) in
                            let message = "error_adding_step_denied".localized(arguments: viewModel.description)
                            self.internalResult = .errorUpload(message)
                        })
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
        self.createdDaoService.delete(byId: self.id, completion: { (_) in
        })
    }
}
