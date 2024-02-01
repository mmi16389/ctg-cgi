//
//  AttachmentAPIServiceImpl.swift
//  GCI
//
//  Created by Florian ALONSO on 5/10/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import MobileCoreServices

class AttachmentAPIServiceImpl: BaseAPISerivceImpl, AttachmentAPIService {
    
    func file(forAttachment attachment: ViewableAttachment, completionHandler: @escaping RequestStatusCallback) {
        let url: String
        if Constant.API.mockFileUrl {
            url = attachment.isPicture ?
                "https://www.citegestion.com/wp-content/uploads/2018/03/250145.jpg" : "https://www.chiny.me/docs/ExemplePDF.pdf"
        } else {
            if let attachment = attachment as? AttachmentViewModel {
                url = Constant.API.EndPoint.file(byUUID: attachment.uuid)
            } else {
                url = ""
            }
        }
        
        let documentDestination: DownloadRequest.Destination = { _, _ in
            return (attachment.fileUrl, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        alamoFireManager.download(url,
                                  method: .get,
                                  parameters: nil,
                                  encoding: URLEncoding.default,
                                  headers: defaultHeaders,
                                  to: documentDestination)
            .response(completionHandler: { response in                
                let requestStatus = RequestStatus.fromHTTPCode(statusCode: response.response?.statusCode)
                completionHandler(requestStatus)
            })
    }
    
    func upload(forFileURL url: URL, completionHandler: @escaping UUIDCallback) {
        AF.upload(
            multipartFormData: { (multipartFormData) in
                multipartFormData.append(url, withName: "file")
        },
            to: Constant.API.EndPoint.file,
            method: .post,
            headers: defaultHeaders).validate().responseData { result in
                switch result.result {
                case .success:
                    let requestStatus = RequestStatus.fromHTTPCode(statusCode: result.response?.statusCode)
                    
                    if requestStatus == RequestStatus.success, let value = result.data, let jsonObj = try? JSON(data: value) {
                        completionHandler(jsonObj["fileId"].string, requestStatus)
                    } else {
                        print("Error API : \(String(describing: result.error))")
                        completionHandler(nil, requestStatus)
                    }
                case .failure:
                    completionHandler(nil, RequestStatus.badRequest)
                }
        }
    }
}
