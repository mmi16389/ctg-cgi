//
//  DetailTaskManager.swift
//  GCI
//
//  Created by Anthony Chollet on 22/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class DetailTaskManager: NSObject {

    typealias AttachmentCallback = (_ attachementImage: UIImage?, _ error: ViewModelError?) -> Void
    typealias AttachmentPDFCallback = (_ attachementPDFURL: URL?, _ error: ViewModelError?) -> Void
    typealias TasksRefreshCompletionHandler = (_ task: TaskViewModel?, _ error: ViewModelError?) -> Void
    
    var internalAttachement: AttachmentDataService?
    var internalTaskDataService: TaskDataService?
    
    func attachementDataService() -> AttachmentDataService {
        if internalAttachement == nil {
            internalAttachement = AttachmentDataServiceImpl()
        }
        return internalAttachement!
    }
    
    func taskDataService() -> TaskDataService {
        if internalTaskDataService == nil {
            internalTaskDataService = TaskDataServiceImpl()
        }
        return internalTaskDataService!
    }
    
    func loadImageFile(fromAttachment attachment: ViewableAttachment, completion: @escaping AttachmentCallback) {
        if attachment.isPicture {
            DispatchQueue.global().async {
                if let attachment = attachment.synchronizedAttachment {
                    self.attachementDataService().loadFile(fromAttachment: attachment, completion: { (attachementResult) in
                        switch attachementResult {
                        case .value(let attachement):
                            completion(attachement.icon, nil)
                        case .failed(let error):
                            completion(nil, error)
                        }
                    })
                } else {
                    completion(attachment.icon, nil)
                }
            }
        } else {
            completion (nil, nil)
        }
    }
    
    func loadPDFFile(fromAttachement attachement: ViewableAttachment, completion: @escaping AttachmentPDFCallback) {
        self.attachementDataService().loadFile(fromAttachment: attachement) { (attachementResult) in
            switch attachementResult {
            case .value(let attachement):
                completion(attachement.fileUrl, nil)
            case .failed(let error):
                completion(nil, error)
            }
        }
    }
    
    func refreshTask(task: TaskViewModel, completionHandler: @escaping TasksRefreshCompletionHandler) {
        taskDataService().task(byId: task.id, withAForcedRefresh: false) { (result) in
            switch result {
            case .value(let task):
                completionHandler(task, nil)
            case .failed(let error):
                completionHandler(nil, error)
            }
        }
    }
}
