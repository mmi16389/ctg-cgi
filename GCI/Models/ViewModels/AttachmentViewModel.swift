//
//  AttachementViewModel.swift
//  GCI
//
//  Created by Florian ALONSO on 4/24/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol ViewableAttachment {
    var isPicture: Bool { get }
    var icon: UIImage { get }
    var fileUrl: URL { get }
    var synchronizedAttachment: AttachmentViewModel? { get }
}

class AttachmentViewModel: ViewableAttachment {
    static let mimeTypePictures = [
        "image/jpeg",
        "image/png"
    ]
    static let mimeTypePDF = "application/pdf"
    static let folder: URL = {
        let path = FileManager.default.getDocumentsDirectoryURL().appendingPathComponent("attachment")
        if !FileManager.default.fileExists(atPath: path.path) {
             try? FileManager.default.createDirectory(atPath: path.path, withIntermediateDirectories: true, attributes: nil)
        }
        return path
    }()
    
    let uuid: String
    let mimeType: String
    
    var isPicture: Bool {
        return AttachmentViewModel.mimeTypePictures.contains(mimeType.lowercased())
    }
    
    var filename: String {
        let mimeTypeCFString = mimeType as CFString
        guard
            let mimeUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeTypeCFString, nil)?.takeUnretainedValue(),
            let extUTI = UTTypeCopyPreferredTagWithClass(mimeUTI, kUTTagClassFilenameExtension)
            else {
            return uuid
        }
        
        return "\(uuid).\(extUTI.takeRetainedValue())"
    }
    
    var icon: UIImage {
        if isPicture {
            if let image = UIImage(contentsOfFile: fileUrl.absoluteString.replacingOccurrences(of: "file:///", with: "")) {
                return image
            } else {
                return UIImage()
            }
        }
        return UIImage(named: "ico_pdf")!
    }
    
    var synchronizedAttachment: AttachmentViewModel? {
        return self
    }
    
    var fileUrl: URL {
        let path = AttachmentViewModel.folder
        return path.appendingPathComponent(filename)
    }
    
    init(uuid: String, mimeType: String) {
        self.uuid = uuid
        self.mimeType = mimeType
    }
}

extension AttachmentViewModel: Convertible {
    
    static func from(db: Attachment) -> AttachmentViewModel? {
        guard let uuid = db.uuid,
            let mimeType = db.mimeType else {
                return nil
        }
        return AttachmentViewModel(uuid: uuid,
                                   mimeType: mimeType)
    }
}
