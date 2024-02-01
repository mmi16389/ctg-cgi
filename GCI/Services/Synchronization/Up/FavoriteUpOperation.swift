//
//  FavoriteUpOperation.swift
//  GCI
//
//  Created by Florian ALONSO on 7/1/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class FavoriteUpOperation: GCIOperationPairable {
    
    let dataService: FavoriteDataService
    let daoService: FavoriteDAOService
    let id: Int
    
    init(forId id: Int, dataService: FavoriteDataService, daoService: FavoriteDAOService, nextOperation: GCIOperation? = nil) {
        self.dataService = dataService
        self.daoService = daoService
        self.id = id
        super.init(nextOperation: nextOperation)
    }
    
    override func run() {
        daoService.unique(byId: id) { (actionFavoriteOpt) in
            guard let actionFavorite = actionFavoriteOpt,
                let viewModel = ActionFavoriteViewModel.from(db: actionFavorite) else {
                self.internalResult = .errorUpload("error_general".localized)
                return
            }
            
            self.dataService.forceSynchronize(actionFavorite: viewModel, completionHandler: { (result) in
                switch result {
                case .success:
                    self.internalResult = .success
                case .failed(let error):
                    
                    switch error {
                    case .noNetwork:
                        self.internalResult = .noInternet
                    case .denied:
                        
                        self.daoService.delete(byTaskId: self.id, completion: { (_) in
                            
                            self.internalResult = .errorUpload("error_general".localized)
                        })
                        
                    default:
                        self.internalResult = .errorUpload("error_general".localized)
                    }
                }
            })
        }
    }
    
    override func runRollback() {
        // DO NOTHING
    }
    
    override func runSuccess() {
        self.daoService.delete(byTaskId: self.id, completion: { (_) in
        })
    }
}
