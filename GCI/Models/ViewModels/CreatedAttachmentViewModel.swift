//
//  CreatedAttachment.swift
//  GCI
//
//  Created by Florian ALONSO on 4/24/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit
import MobileCoreServices

class CreatedAttachmentViewModel: ViewableAttachment {
    
    let fileUrl: URL
    let mimeType: String
    var uuid: String?
    
    var isPicture: Bool {
        return AttachmentViewModel.mimeTypePictures.contains(mimeType.lowercased())
    }
    
    var icon: UIImage {
        if isPicture {
            if FileManager.default.fileExists(atPath: fileUrl.path) {
                return UIImage(contentsOfFile: fileUrl.path)!
            } else {
                return UIImage()
            }
        }
        return UIImage(named: "ico_pdf")!
    }
    
    var synchronizedAttachment: AttachmentViewModel? {
        return nil
    }
    
    var identifier: String {
        return self.fileUrl.lastPathComponent
    }
    
    init(fileName: String, uuid: String? = nil) {
        self.fileUrl = AttachmentViewModel.folder.appendingPathComponent(fileName)
        self.uuid = uuid
        
        let pathExtension = fileUrl.pathExtension as NSString
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, nil)?.takeRetainedValue(),
            let mimetypeDetected = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
            mimeType = mimetypeDetected as String
        } else {
            // SHould not appen
            mimeType = ""
        }
    }
}

extension CreatedAttachmentViewModel: Convertible {
    
    static func from(db: CreatedAttachment) -> CreatedAttachmentViewModel? {
        guard let fileName = db.fileName else {
                return nil
        }
        return CreatedAttachmentViewModel(fileName: fileName,
                                   uuid: db.uuid)
    }
}
