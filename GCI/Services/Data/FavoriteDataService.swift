//
//  FavoriteDataService.swift
//  GCI
//
//  Created by Florian ALONSO on 7/1/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

protocol FavoriteDataService {
    
    typealias StatusCallback = (_ result: UIResult) -> Void
    
    func syncFavoritesFromServer(completionHanlder: @escaping StatusCallback)
    func setTaskAsFavorite(byTaskId taskId: Int, completionHanlder: @escaping StatusCallback)
    func removeTaskAsFavorite(byTaskId taskId: Int, completionHanlder: @escaping StatusCallback)
    func forceSynchronize(actionFavorite: ActionFavoriteViewModel, completionHandler: @escaping StatusCallback)
}
