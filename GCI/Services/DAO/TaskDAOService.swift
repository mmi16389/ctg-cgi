//
//  TaskDAOService.swift
//  GCI
//
//  Created by Florian ALONSO on 5/8/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol TaskDAOService {
    
    typealias ListCallback = (_ list: [Task]) -> Void
    typealias UniqueCallback = (_ object: Task?) -> Void
    typealias StatusCallback = (_ success: Bool) -> Void
    
    func all(completion: @escaping ListCallback)
    func allModified(completion: @escaping ListCallback)
    func unique(byId id: Int, completion: @escaping UniqueCallback)
    func delete(byId id: Int, completion: @escaping StatusCallback)
    func deleteAll(completion: @escaping StatusCallback)
    func update(fromViewModel viewModel: TaskViewModel, completion: @escaping TaskDAOService.UniqueCallback)
    func markAsEditionDone(byId id: Int, completion: @escaping TaskDAOService.UniqueCallback)
    func setFavorite(byTaskId taskId: Int, isBecomingFavorite: Bool, completion: @escaping TaskDAOService.UniqueCallback)
    func setAllFavorites(byIds ids: [Int], completion: @escaping TaskDAOService.StatusCallback)
    func saveResponse(fromJson json: JSON, completion: @escaping TaskDAOService.UniqueCallback)
    func saveResponses(fromJson json: JSON, completion: @escaping ListCallback)
}
