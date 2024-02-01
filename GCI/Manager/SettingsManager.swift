//
//  SettingsManager.swift
//  GCI
//
//  Created by Anthony Chollet on 10/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class SettingsManager: NSObject {
    typealias SynchViewModelCompletionHandler = (_ synchInfo: GCIOperationResult) -> Void
    typealias NotifViewModelCompletionHandler = (_ success: Bool, _ error: ViewModelError?) -> Void
    var internalNotificationDataService: NotificationDataService?
    
    func notificationService() -> NotificationDataService {
        if internalNotificationDataService == nil {
            internalNotificationDataService = NotificationDataServiceImpl()
        }
        return internalNotificationDataService!
    }
    
    func resetLicence(completion: @escaping () -> Void) {
        AppDynamicConfiguration.remove()
        completion()
    }
    
    func logout(completion: @escaping () -> Void) {
        User.currentUser()?.logout()
        SynchronizationService.shared.forceStop()
        completion()
    }
    
    func lauchSync(completionHandler: @escaping SynchViewModelCompletionHandler) {
        SynchronizationService.shared.startUpSynchronization(withCompletion: { (result) in
            switch result {
            case .success:
                completionHandler(.success)
            default:
                completionHandler(result)
            }
        })
    }
    
    func setRemoteNotification(notifications: [Constant.Notification.Code], withCompletion completion: @escaping NotifViewModelCompletionHandler) {
        notificationService().updateSubscription(withNotificationCode: notifications) { (result) in
            switch result {
            case .success:
                completion(true, nil)
            case .failed(let error):
                completion(false, error)
            }
        }
    }
    
    func getRemoteNotification(withCompletion completion: @escaping NotifViewModelCompletionHandler) {
        notificationService().refreshSubscription { (result) in
            switch result {
            case .success:
                completion(true, nil)
            case .failed(let error):
                completion(false, error)
            }
        }
    }
}
