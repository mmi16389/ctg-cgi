//
//  StepAPIService.swift
//  GCI
//
//  Created by Anthony Chollet on 25/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

protocol StepAPIService {
    func create(fromViewModel viewModel: CreatedStepViewModel, completionHandler: @escaping RequestJSONCallback)
    
    func update(fromViewModel viewModel: StepViewModel, taskID: Int, completionHandler: @escaping RequestJSONCallback)
}
