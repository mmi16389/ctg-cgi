//
//  TaskDownOperation.swift
//  GCI
//
//  Created by Florian ALONSO on 5/13/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class TaskDownOperation: GCIOperation {
    
    let dataService: TaskDataService
    
    init(dataService: TaskDataService, nextOperation: GCIOperation? = nil) {
        self.dataService = dataService
        super.init(nextOperation: nextOperation)
    }
    
    override func run() {
        self.dataService.taskList(withAForcedRefresh: true) { (result) in
            switch result {
            case .value:
                self.internalResult = .success
            case .cached:
                // SHOULD DO NOTHING
                break
            case .failed(let error):
                self.internalResult = error == ViewModelError.noNetwork ? .noInternet : .errorDownload
            }
        }
    }
}
