//
//  WorkflowAPIServiceImpl.swift
//  GCI
//
//  Created by Florian ALONSO on 5/23/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class WorkflowAPIServiceImpl: BaseAPISerivceImpl, WorkflowAPIService {
    
    func next(forViewModel viewModel: ActionWorkflowViewModel, completionHandler: @escaping RequestJSONCallback) {
        let parameters = viewModel.webParameters
        
        alamoFireManager.request(Constant.API.EndPoint.workflowNext(forTaskId: viewModel.taskId),
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
    
    func cancel(forViewModel viewModel: ActionWorkflowViewModel, completionHandler: @escaping RequestJSONCallback) {
        let parameters = viewModel.webParameters
        
        alamoFireManager.request(Constant.API.EndPoint.workflowCancel(forTaskId: viewModel.taskId),
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
    
    func reject(forViewModel viewModel: ActionWorkflowViewModel, completionHandler: @escaping RequestJSONCallback) {
        let parameters = viewModel.webParameters
        
        alamoFireManager.request(Constant.API.EndPoint.workflowReject(forTaskId: viewModel.taskId),
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
    
    func undo(forViewModel viewModel: ActionWorkflowViewModel, completionHandler: @escaping RequestJSONCallback) {
        var headers = defaultHeaders
        
        let parameters = viewModel.webParameters
        
        alamoFireManager.request(Constant.API.EndPoint.workflowUndo(forTaskId: viewModel.taskId),
                                 method: .post,
                                 parameters: parameters,
                                 encoding: JSONEncoding.default,
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
    
}
