//
//  AttachmentAPIService.swift
//  GCI
//
//  Created by Florian ALONSO on 5/10/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol AttachmentAPIService {
    typealias UUIDCallback = (_ uuid: String?, _ requestStatus: RequestStatus) -> Void
    
    func file(forAttachment attachment: ViewableAttachment, completionHandler: @escaping RequestStatusCallback)
    func upload(forFileURL url: URL, completionHandler: @escaping UUIDCallback)
    
}
