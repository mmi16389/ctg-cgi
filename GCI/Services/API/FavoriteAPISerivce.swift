//
//  FavoriteAPISerivce.swift
//  GCI
//
//  Created by Florian ALONSO on 7/1/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol FavoriteAPIService {    
    typealias FavoritesListCallback = (_ taskIds: [Int], _ requestStatus: RequestStatus) -> Void
    
    func favoriteList(completionHandler: @escaping FavoritesListCallback)
    func addAsFavorite(theTaskId taskId: Int, completionHandler: @escaping RequestStatusCallback)
    func removeFromFavorite(theTaskId taskId: Int, completionHandler: @escaping RequestStatusCallback)
}
