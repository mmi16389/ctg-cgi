//
//  CreatedStepDAOService.swift
//  GCI
//
//  Created by Anthony Chollet on 24/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

protocol CreatedStepDAOService {
    typealias ListCallback = (_ list: [CreatedStep]) -> Void
    typealias UniqueCallback = (_ object: CreatedStep?) -> Void
    typealias StatusCallback = (_ success: Bool) -> Void
    func update(fromViewModel viewModel: CreatedStepViewModel, completion: @escaping CreatedStepDAOService.UniqueCallback)
    func allPending(completion: @escaping ListCallback)
    func unique(byId id: Int, completion: @escaping UniqueCallback)
    func delete(byId id: Int, completion: @escaping StatusCallback)
    func deleteAll(completion: @escaping StatusCallback)
    func add(fromViewModel viewModel: CreatedStepViewModel, completion: @escaping UniqueCallback)
}
