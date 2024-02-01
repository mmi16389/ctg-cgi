//
//  ConfigurationDataService.swift
//  GCI
//
//  Created by Florian ALONSO on 3/11/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

protocol ConfigurationDataService {
    
    typealias RequestStatusCallback = (_ result: ViewModelResult<AppDynamicConfiguration>) -> Void
    typealias MapConfigCallback = (_ result: ViewModelResult<AppDynamicMapConfiguration>) -> Void
    
    func test(licence: String, completionHandler: @escaping RequestStatusCallback)
    
    func refresh(completionHandler: @escaping RequestStatusCallback)
    
    func mapConfiguration(completionHandler: @escaping MapConfigCallback)
}
