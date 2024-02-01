//
//  TaskEditionUpOperation.swift
//  GCI
//
//  Created by Florian ALONSO on 6/6/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import CoreData

class TaskEditionUpOperation: GCIOperationPairable {
    
    let dataService: TaskDataService
    let daoService: TaskDAOService
    let id: Int
    
    init(forId id: Int, dataService: TaskDataService, daoService: TaskDAOService, nextOperation: GCIOperation? = nil) {
        self.dataService = dataService
        self.daoService = daoService
        self.id = id
        super.init(nextOperation: nextOperation)
    }
    
    override func run() {
        daoService.unique(byId: id) { (taskOpt) in
            guard let task = taskOpt,
                let viewModel = TaskViewModel.from(db: task) else {
                    self.internalResult = .errorUpload("error_general".localized)
                    return
            }
            
            self.dataService.forceSyncronizeEditedTask(fromTask: viewModel) { (result) in
                switch result {
                case .value:
                    self.internalResult = .success
                case .failed(let error):
                    
                    switch error {
                    case .noNetwork:
                        self.internalResult = .noInternet
                    case .denied:
                        self.daoService.markAsEditionDone(byId: self.id) { (_) in
                            let message = "error_adding_task_denied".localized(arguments: viewModel.comment)
                            self.internalResult = .errorUpload(message)
                        }
                    default:
                        let message = "error_adding_task".localized(arguments: viewModel.comment)
                        self.internalResult = .errorUpload(message)
                    }
                }
            }
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
