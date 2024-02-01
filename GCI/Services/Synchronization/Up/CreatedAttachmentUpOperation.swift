//
//  CreatedAttachmentUpOperation.swift
//  GCI
//
//  Created by Florian ALONSO on 6/3/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import CoreData

class CreatedAttachmentUpOperation: GCIOperationPairable {
    
    let dataServce: AttachmentDataService
    let daoService: CreatedAttachmentDAOService
    let id: String
    
    init(forId id: String, dataServce: AttachmentDataService, daoService: CreatedAttachmentDAOService, nextOperation: GCIOperation? = nil) {
        self.dataServce = dataServce
        self.daoService = daoService
        self.id = id
        super.init(nextOperation: nextOperation)
    }
    
    override func run() {
        self.daoService.unique(byId: self.id) { (createdAttachmentOpt) in
            guard let createdAttachment = createdAttachmentOpt,
                let viewModel = CreatedAttachmentViewModel.from(db: createdAttachment) else {
                    self.internalResult = .errorUpload("error_general".localized)
                    return
            }
            
            let fileStillExist = (try? viewModel.fileUrl.checkResourceIsReachable()) ?? false
            if !fileStillExist {
                // File do not exist, so not uploading it
                self.daoService.delete(byId: self.id, completion: { (success) in
                    self.internalResult = success ? .success : .errorUpload("error_general".localized)
                })
                return
            }
            
            self.dataServce.upload(fromFileUrl: viewModel.fileUrl, withCompletion: { (result) in
                switch result {
                case .value(let newUUID):
                    self.daoService.updatedUUID(byId: self.id, withNewUUID: newUUID, completion: { (success) in
                        self.internalResult = success ? .success : .errorUpload("error_general".localized)
                    })
                case .failed(let error):
                    
                    switch error {
                    case .noNetwork:
                        self.internalResult = .noInternet
                    case .denied:
                        // File too large, ignoring it
                        self.daoService.delete(byId: self.id, completion: { (success) in
                            self.internalResult = success ? .success : .errorUpload("error_general".localized)
                        })
                    default:
                        let message = "error_file_upload".localized
                        self.internalResult = .errorUpload(message)
                    }
                }
            })
            
        }
        
    }
    
    override func runRollback() {
        daoService.rollbackUUID(byId: self.id) { (_) in
            
        }
    }
    
    override func runSuccess() {
        self.daoService.unique(byId: self.id) { (createdAttachmentOpt) in
            guard let attachment = createdAttachmentOpt else {
                return
            }
            do {
                if let filename = attachment.fileName {
                    try FileManager.default.removeItem(at: AttachmentViewModel.folder.appendingPathComponent(filename))
                }
            } catch let error as NSError {
                print("Error: \(error.domain)")
            }
            
            self.daoService.delete(byId: self.id, completion: { (_) in
                
            })
        }
    }
}
