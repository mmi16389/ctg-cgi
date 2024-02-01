//
//  AttachmentDataServiceImpl.swift
//  
//
//  Created by Florian ALONSO on 5/10/19.
//

import Foundation

class AttachmentDataServiceImpl: NSObject, AttachmentDataService {
    
    var internalLoginDataService: LoginDataService?
    var internalApiService: AttachmentAPIService?
    
    func apiService() -> AttachmentAPIService {
        if internalApiService == nil {
            self.internalApiService = AttachmentAPIServiceImpl()
        }
        return internalApiService!
    }
    
    func loginService() -> LoginDataService {
        if internalLoginDataService == nil {
            self.internalLoginDataService = LoginDataServiceImpl()
        }
        return internalLoginDataService!
    }
    
    func loadFile(fromAttachment attachment: ViewableAttachment, completion: @escaping AttacmentCallback) {
        let fileStillExist = (try? attachment.fileUrl.checkResourceIsReachable()) ?? false
        if fileStillExist {
            completion(.value(attachment))
            return
        }
        
        loginService().makeSecureAPICall {
            
            self.apiService().file(forAttachment: attachment, completionHandler: { (requestStatus) in
                if requestStatus == .shouldRelogin {
                    User.currentUser()?.invalidateToken()
                    self.loadFile(fromAttachment: attachment, completion: completion)
                    return
                } else if requestStatus == .noInternet {
                    DispatchQueue.main.async {
                        completion(.failed(.noNetwork))
                    }
                    return
                } else if requestStatus == .success {
                    DispatchQueue.main.async {
                        completion(.value(attachment))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failed(ViewModelError.from(networkRequest: requestStatus)))
                    }
                }
            })
        }
        
    }
    
    func deleteAllFiles(completion: @escaping StatusCallback) {
        DispatchQueue.global().async {
            let ok: Bool
            do {
                let fileManager = FileManager.default
                try fileManager.removeItem(at: AttachmentViewModel.folder)
                ok = true
            } catch let error {
                print("Ooops! Something went wrong: \(error)")
                ok = false
            }
            
            DispatchQueue.main.async {
                completion(ok ? .success : .failed(.error))
            }
        }
    }
    
    func upload(fromFileUrl url: URL, withCompletion completion: @escaping UUIDCallback) {
        loginService().makeSecureAPICall {
            self.apiService().upload(forFileURL: url, completionHandler: { (uuidOpt, requestStatus) in
                if requestStatus == .shouldRelogin {
                    User.currentUser()?.invalidateToken()
                    self.upload(fromFileUrl: url, withCompletion: completion)
                    return
                } else if requestStatus == .noInternet {
                    DispatchQueue.main.async {
                        completion(.failed(.noNetwork))
                    }
                    return
                } else if requestStatus == .success {
                    guard let uuid = uuidOpt else {
                        DispatchQueue.main.async {
                            completion(.failed(ViewModelError.from(networkRequest: requestStatus)))
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        completion(.value(uuid))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failed(ViewModelError.from(networkRequest: requestStatus)))
                    }
                }
            })
        }
    }
}
