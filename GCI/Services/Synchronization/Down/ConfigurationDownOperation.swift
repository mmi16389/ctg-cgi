//
//  ConfigurationDownOperation.swift
//  GCI
//
//  Created by Florian ALONSO on 5/13/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class ConfigurationDownOperation: GCIOperation {
    
    let dataService: ConfigurationDataService
    
    init(dataService: ConfigurationDataService, nextOperation: GCIOperation? = nil) {
        self.dataService = dataService
        super.init(nextOperation: nextOperation)
    }
    
    override func run() {
        self.dataService.refresh { (result) in
            switch result {
            case .value:
                self.internalResult = .success
            case .failed(let error):
                let noInternet = error == .noNetwork
                self.internalResult = noInternet ? .noInternet : .errorDownload
            }
        }
    }
}
