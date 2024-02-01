//
//  WorkflowDAOService.swift
//  GCI
//
//  Created by Florian ALONSO on 5/23/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

protocol WorkflowDAOService {
    
    typealias ListCallback = (_ list: [ActionWorkflow]) -> Void
    typealias UniqueCallback = (_ object: ActionWorkflow?) -> Void
    typealias StatusCallback = (_ success: Bool) -> Void
    
    func allOrdered(completion: @escaping ListCallback)
    
    func unique(byId id: Int, completion: @escaping UniqueCallback)
    
    func delete(byId id: Int, completion: @escaping StatusCallback)
    
    func deleteAllPending(completion: @escaping StatusCallback)
    
    func add(fromViewModel viewModel: ActionWorkflowViewModel, completion: @escaping UniqueCallback)
    
}
