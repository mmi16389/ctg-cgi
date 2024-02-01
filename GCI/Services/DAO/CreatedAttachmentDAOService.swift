//
//  CreatedFileDAOService.swift
//  GCI
//
//  Created by Florian ALONSO on 6/3/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

protocol CreatedAttachmentDAOService {
    
    typealias ListCallback = (_ list: [CreatedAttachment]) -> Void
    typealias UniqueCallback = (_ object: CreatedAttachment?) -> Void
    typealias StatusCallback = (_ success: Bool) -> Void
    
    func unique(byId id: String, completion: @escaping UniqueCallback)
    func delete(byId id: String, completion: @escaping StatusCallback)
    func deleteAll(completion: @escaping StatusCallback)
    func rollbackUUID(byId id: String, completion: @escaping StatusCallback)
    func updatedUUID(byId id: String, withNewUUID uuid: String, completion: @escaping StatusCallback)
}
