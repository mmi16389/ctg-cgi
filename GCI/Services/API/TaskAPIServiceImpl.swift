//
//  TaskAPIServiceImpl.swift
//  GCI
//
//  Created by Florian ALONSO on 5/8/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class TaskAPIServiceImpl: BaseAPISerivceImpl, TaskAPIService {
    
    func taskList(alreadyKnowsIds: [Int], completionHandler: @escaping RequestJSONCallback) {
        var parameters: [String: Any] = [
            "knownTasks": alreadyKnowsIds
        ]
        var headers = defaultHeaders
        if let previousDate = UserDefaultManager.shared.lastTaskListRequestDate {
            headers[Constant.API.HeadersName.ifRange] = DateHelper.ifRangeDateFormater.string(from: previousDate)
            parameters["lastPulling"] = DateHelper.requestDateFormater.string(from: previousDate)
        }
        
        alamoFireManager.request(Constant.API.EndPoint.tasks,
                                 method: .put,
                                 parameters: parameters,
                                 encoding: JSONEncoding.default,
                                 headers: headers)
            .responseData { response in
                
                let requestStatus = RequestStatus.fromHTTPCode(statusCode: response.response?.statusCode)
                if response.response?.statusCode == 304 {
                    UserDefaultManager.shared.lastTaskListRequestDate = Date()
                    completionHandler(nil, requestStatus)
                } else if response.response?.statusCode == 206 || response.response?.statusCode == 200 {
                    var jsonValue: JSON? = nil
                    
                    if let value = response.data, let jsonObj = try? JSON(data: value) {
                        
                        //check lastModified header and compare to the lastLaboratoriesRequest Date
                        if let lastModified = response.response?.allHeaderFields[Constant.API.HeadersName.lastModified] as? String {
                            let dateFormater = DateHelper.ifRangeDateFormater
                            if let dateAPI = dateFormater.date(from: lastModified) {
                                var shouldSaveJSON = true
                                
                                if let lastLaboratoriesRequestDate = UserDefaultManager.shared.lastTaskListRequestDate {
                                    if dateAPI <= lastLaboratoriesRequestDate {
                                        shouldSaveJSON = false
                                    } else {
                                        UserDefaultManager.shared.lastTaskListRequestDate = dateAPI
                                    }
                                } else {
                                    UserDefaultManager.shared.lastTaskListRequestDate = Date()
                                }
                                
                                if shouldSaveJSON {
                                    jsonValue = jsonObj
                                }
                            }
                            
                        } else {
                            jsonValue = jsonObj
                            UserDefaultManager.shared.lastTaskListRequestDate = Date()
                        }
                        
                    } else {
                        print("Error API : \(String(describing: response.error))")
                    }
                    
                    if let json = jsonValue {
                        completionHandler(json, requestStatus)
                    } else {
                        completionHandler(nil, requestStatus)
                    }
                    
                } else {
                    
                    completionHandler(nil, requestStatus)
                }
        }
    }
    
    func task(byId id: Int, completionHandler: @escaping RequestJSONCallback) {
        self.task(byId: id, lastRefreshDate: nil, completionHandler: completionHandler)
    }
    
    func task(byId id: Int, lastRefreshDate: Date?, completionHandler: @escaping RequestJSONCallback) {
        
        var headers = defaultHeaders
        
        if let previousDate = lastRefreshDate {
            headers[Constant.API.HeadersName.ifRange] = DateHelper.ifRangeDateFormater.string(from: previousDate)
        }
        
        alamoFireManager.request(Constant.API.EndPoint.task(byId: id),
                                 method: .get,
                                 parameters: nil,
                                 encoding: URLEncoding.default,
                                 headers: headers)
            .responseData { response in
                
                let requestStatus = RequestStatus.fromHTTPCode(statusCode: response.response?.statusCode)
                
                if requestStatus == RequestStatus.success, let value = response.data, let jsonObj = try? JSON(data: value) {
                    completionHandler(jsonObj, requestStatus)
                } else {
                    print("Error API : \(String(describing: response.error))")
                    completionHandler(nil, requestStatus)
                }
        }
    }
    
    func create(fromViewModel viewModel: CreatedTaskViewModel, completionHandler: @escaping RequestJSONCallback) {
        
        let parameters = viewModel.webParameters
        
        alamoFireManager.request(Constant.API.EndPoint.tasks,
                                 method: .post,
                                 parameters: parameters,
                                 encoding: JSONEncoding.default,
                                 headers: defaultHeaders)
            .responseData { response in
                
                let requestStatus = RequestStatus.fromHTTPCode(statusCode: response.response?.statusCode)
                
                if requestStatus == RequestStatus.success, let value = response.data, let jsonObj = try? JSON(data: value) {
                    completionHandler(jsonObj, requestStatus)
                } else {
                    print("Error API : \(String(describing: response.error))")
                    completionHandler(nil, requestStatus)
                }
        }
    }
    
    func update(fromViewModel viewModel: TaskViewModel, completionHandler: @escaping RequestJSONCallback) {
        let parameters = viewModel.webParameters
        
        alamoFireManager.request(Constant.API.EndPoint.task(byId: viewModel.id),
                                 method: .put,
                                 parameters: parameters,
                                 encoding: JSONEncoding.default,
                                 headers: defaultHeaders)
            .responseData { response in
                
                let requestStatus = RequestStatus.fromHTTPCode(statusCode: response.response?.statusCode)
                
                if requestStatus == RequestStatus.success, let value = response.data, let jsonObj = try? JSON(data: value) {
                    completionHandler(jsonObj, requestStatus)
                } else {
                    print("Error API : \(String(describing: response.error))")
                    completionHandler(nil, requestStatus)
                }
        }
    }
    
    func assignableUser(forTaskId id: Int, completionHandler: @escaping RequestJSONCallback) {
        alamoFireManager.request(Constant.API.EndPoint.taskAssignable(byId: id),
                                 method: .get,
                                 parameters: nil,
                                 encoding: URLEncoding.default,
                                 headers: defaultHeaders)
            .responseData { response in
                
                let requestStatus = RequestStatus.fromHTTPCode(statusCode: response.response?.statusCode)
                
                if requestStatus == RequestStatus.success, let value = response.data, let jsonObj = try? JSON(data: value) {
                    completionHandler(jsonObj, requestStatus)
                } else {
                    print("Error API : \(String(describing: response.error))")
                    completionHandler(nil, requestStatus)
                }
        }
    }
    
    func changeService(forTaskId id: Int, toServiceId serviceId: Int, title: String?, description: String?, completionHandler: @escaping RequestJSONCallback) {
        
        var parameters: [String: Any] = [
            "serviceId": String(serviceId)
        ]
        var serviceTransferReason: [String: Any] = [:]
        if let safeDescription = description {
            serviceTransferReason["comment"] = safeDescription
        }
        if let safeTitle = title {
            serviceTransferReason["reason"] = safeTitle
            parameters["serviceTransferReason"] = serviceTransferReason
        }
        
        alamoFireManager.request(Constant.API.EndPoint.taskServiceChange(byId: id),
                                 method: .post,
                                 parameters: parameters,
                                 encoding: JSONEncoding.default,
                                 headers: defaultHeaders)
            .responseData { response in
                
                let requestStatus = RequestStatus.fromHTTPCode(statusCode: response.response?.statusCode)
                
                if requestStatus == RequestStatus.success, let value = response.data, let jsonObj = try? JSON(data: value) {
                    completionHandler(jsonObj, requestStatus)
                } else {
                    print("Error API : \(String(describing: response.error))")
                    completionHandler(nil, requestStatus)
                }
        }
    }
    
    func availableServices(forTaskId id: Int, completionHandler: @escaping ServiceListCallback) {
        alamoFireManager.request(Constant.API.EndPoint.taskServices(byId: id),
                                method: .get,
                                parameters: nil,
                                encoding: URLEncoding.default,
                                headers: defaultHeaders)
            .responseData { response in
                
                let requestStatus = RequestStatus.fromHTTPCode(statusCode: response.response?.statusCode)
                
                if requestStatus == RequestStatus.success, let value = response.data, let jsonObj = try? JSON(data: value) {
                    
                    let values = jsonObj["services"].arrayValue
                        .compactMap {
                            $0.int
                    }
                    completionHandler(values, requestStatus)
                } else {
                    print("Error API : \(String(describing: response.error))")
                    completionHandler([], requestStatus)
                }
        }
    }
}
