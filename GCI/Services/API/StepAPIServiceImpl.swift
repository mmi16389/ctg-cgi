//
//  StepAPIServiceImpl.swift
//  GCI
//
//  Created by Anthony Chollet on 25/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class StepAPIServiceImpl: BaseAPISerivceImpl, StepAPIService {
    func create(fromViewModel viewModel: CreatedStepViewModel, completionHandler: @escaping RequestJSONCallback) {
        
        let parameters = viewModel.webParameters
        
        alamoFireManager.request(Constant.API.EndPoint.steps(byId: viewModel.taskId),
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
    
    func update(fromViewModel viewModel: StepViewModel, taskID: Int, completionHandler: @escaping RequestJSONCallback) {
        
        let parameters = viewModel.webParameters
        
        alamoFireManager.request(Constant.API.EndPoint.editSteps(byTaskId: taskID, stepId: viewModel.id),
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
}
