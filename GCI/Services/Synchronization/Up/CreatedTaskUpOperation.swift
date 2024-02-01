//
//  CreatedTaskUpOperation.swift
//  GCI
//
//  Created by Florian ALONSO on 6/3/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import CoreData

class CreatedTaskUpOperation: GCIOperationPairable {
    
    let taskDataService: TaskDataService
    let createdDaoService: CreatedTaskDAOService
    let id: Int
    
    init(forId id: Int, taskDataService: TaskDataService, createdDaoService: CreatedTaskDAOService, nextOperation: GCIOperation? = nil) {
        self.taskDataService = taskDataService
        self.createdDaoService = createdDaoService
        self.id = id
        super.init(nextOperation: nextOperation)
    }
    
    override func run() {
        createdDaoService.unique(byId: self.id) { (createdTaskOpt) in
            guard let createdTask = createdTaskOpt,
                let viewModel = CreatedTaskViewModel.from(db: createdTask) else {
                self.internalResult = .errorUpload("error_general".localized)
                return
            }
            
            self.taskDataService.forceSyncronizeNewTask(fromCreatedTask: viewModel, withCompletion: { (result) in
                
                switch result {
                case .success:
                    self.internalResult = .success
                case .failed(let error ):
                    
                    switch error {
                    case .noNetwork:
                        self.internalResult = .noInternet
                    case .denied:
                        self.createdDaoService.delete(byId: self.id, completion: { (_) in
                            let message = "error_adding_task_denied".localized(arguments: viewModel.comment)
                            self.internalResult = .errorUpload(message)
                        })
                    default:
                        let message = "error_adding_task".localized(arguments: viewModel.comment)
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
