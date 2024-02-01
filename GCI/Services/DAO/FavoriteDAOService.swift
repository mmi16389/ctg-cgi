//
//  FavoriteDAOService.swift
//  GCI
//
//  Created by Florian ALONSO on 7/1/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

protocol FavoriteDAOService {
    
    typealias ListCallback = (_ list: [ActionFavorite]) -> Void
    typealias UniqueCallback = (_ object: ActionFavorite?) -> Void
    typealias StatusCallback = (_ success: Bool) -> Void
    
    func unique(byId id: Int, completion: @escaping UniqueCallback)
    func allAction(completion: @escaping ListCallback)
    func addToActionFavorite(forTaskId taskId: Int, isBecommingFavorite: Bool, completion: @escaping StatusCallback)
    func delete(byTaskId taskId: Int, completion: @escaping StatusCallback)
    func deleteAll(completion: @escaping StatusCallback)
    
}
