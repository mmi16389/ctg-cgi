//
//  ConfigurationManager.swift
//  GCI
//
//  Created by Anthony Chollet on 26/04/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class LicenceManager: NSObject {

    typealias ConfigurationViewModelCompletionHandler = (_ consumption: AppDynamicConfiguration?, _ error: ViewModelError?) -> Void
    typealias MapConfigurationViewModelCompletion = (_ configuration: AppDynamicMapConfiguration?, _ error: ViewModelError?) -> Void
    var internalConfigurationDataService: ConfigurationDataService?
    
    func configurationDataService() -> ConfigurationDataService {
        if internalConfigurationDataService == nil {
            internalConfigurationDataService = ConfigurationDataServiceImpl()
        }
        return internalConfigurationDataService!
    }
    
    func test(license: String, completionHandler: @escaping ConfigurationViewModelCompletionHandler) {
        configurationDataService().test(licence: license) { (result) in
            switch result {
            case .value(let config):
                completionHandler(config, nil)
            case .failed(let error):
                completionHandler(nil, error)
            }
        }
    }
    
    func refresh(completionHandler: @escaping ConfigurationViewModelCompletionHandler) {
        configurationDataService().refresh { (result) in
            switch result {
            case .value(let value):
                completionHandler(value, nil)
            case .failed(let error):
                completionHandler(nil, error)
            }
        }
    }
    
    func mapConfiguration(completionHandler: @escaping MapConfigurationViewModelCompletion) {
        configurationDataService().mapConfiguration { (result) in
            switch result {
            case .value(let value):
                completionHandler(value, nil)
            case .failed(let error):
                completionHandler(nil, error)
            }
        }
    }
}
