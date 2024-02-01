//
//  CreatedTaskDAOService.swift
//  GCI
//
//  Created by Florian ALONSO on 6/3/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

protocol CreatedTaskDAOService {
    
    typealias ListCallback = (_ list: [CreatedTask]) -> Void
    typealias UniqueCallback = (_ object: CreatedTask?) -> Void
    typealias StatusCallback = (_ success: Bool) -> Void
    
    func allPending(completion: @escaping ListCallback)
    func unique(byId id: Int, completion: @escaping UniqueCallback)
    func delete(byId id: Int, completion: @escaping StatusCallback)
    func deleteAll(completion: @escaping StatusCallback)
    func add(fromViewModel viewModel: CreatedTaskViewModel, completion: @escaping UniqueCallback)
    
}
