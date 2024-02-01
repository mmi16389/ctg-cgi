//
//  FavoriteAPIServiceImpl.swift
//  GCI
//
//  Created by Florian ALONSO on 7/1/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class FavoriteAPIServiceImpl: BaseAPISerivceImpl, FavoriteAPIService {
    
    func favoriteList(completionHandler: @escaping FavoritesListCallback) {
        
        alamoFireManager.request(Constant.API.EndPoint.favorite,
                                 method: .get,
                                 parameters: nil,
                                 encoding: JSONEncoding.default,
                                 headers: defaultHeaders)
            .responseData { response in
                
                let requestStatus = RequestStatus.fromHTTPCode(statusCode: response.response?.statusCode)
                
                if requestStatus == RequestStatus.success, let value = response.data, let jsonObj = try? JSON(data: value) {
                    let values = jsonObj["favoriteTaskIds"].arrayValue
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
    
    func addAsFavorite(theTaskId taskId: Int, completionHandler: @escaping RequestStatusCallback) {
        
        alamoFireManager.request(Constant.API.EndPoint.favorite(byTaskId: taskId),
                                 method: .post,
                                 parameters: nil,
                                 encoding: JSONEncoding.default,
                                 headers: defaultHeaders)
            .responseData { response in
                
                let requestStatus = RequestStatus.fromHTTPCode(statusCode: response.response?.statusCode)
                completionHandler(requestStatus)
        }
    }
    
    func removeFromFavorite(theTaskId taskId: Int, completionHandler: @escaping RequestStatusCallback) {
        
        alamoFireManager.request(Constant.API.EndPoint.favorite(byTaskId: taskId),
                                 method: .delete,
                                 parameters: nil,
                                 encoding: JSONEncoding.default,
                                 headers: defaultHeaders)
            .responseData { response in
                
                let requestStatus = RequestStatus.fromHTTPCode(statusCode: response.response?.statusCode)
                completionHandler(requestStatus)
        }
    }
    
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
