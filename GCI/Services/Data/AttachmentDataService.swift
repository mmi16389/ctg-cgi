//
//  FileDataService.swift
//  GCI
//
//  Created by Florian ALONSO on 5/10/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

protocol AttachmentDataService {
    
    typealias AttacmentCallback = (_ result: ViewModelResult<ViewableAttachment>) -> Void
    typealias UUIDCallback = (_ result: ViewModelResult<String>) -> Void
    typealias StatusCallback = (_ result: UIResult) -> Void
    
    func loadFile(fromAttachment attachment: ViewableAttachment, completion: @escaping AttacmentCallback)
    func deleteAllFiles(completion: @escaping StatusCallback)
    func upload(fromFileUrl url: URL, withCompletion completion: @escaping UUIDCallback)
}
