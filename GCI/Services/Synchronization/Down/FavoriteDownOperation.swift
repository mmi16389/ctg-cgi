//
//  FavoriteDownOperation.swift
//  GCI
//
//  Created by Florian ALONSO on 5/13/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class FavoriteDownOperation: GCIOperation {
    
    let dataService: FavoriteDataService
        
    init(dataService: FavoriteDataService, nextOperation: GCIOperation? = nil) {
        self.dataService = dataService
        super.init(nextOperation: nextOperation)
    }
    
    override func run() {
        self.dataService.syncFavoritesFromServer { (result) in
            switch result {
            case .success:
                self.internalResult = .success
            case .failed(let error):
                self.internalResult = error == ViewModelError.noNetwork ? .noInternet : .errorDownload
            }
        }
    }
}
