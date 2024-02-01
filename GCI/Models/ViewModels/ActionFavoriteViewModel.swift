//
//  ActionFavoriteViewModel.swift
//  GCI
//
//  Created by Florian ALONSO on 4/24/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class ActionFavoriteViewModel {
    let taskId: Int
    let becommingFavorite: Bool
    
    init(taskId: Int, becommingFavorite: Bool) {
        self.taskId = taskId
        self.becommingFavorite = becommingFavorite
    }
}

extension ActionFavoriteViewModel: Convertible {
    
    static func from(db: ActionFavorite) -> ActionFavoriteViewModel? {
        return ActionFavoriteViewModel(taskId: Int(db.taskId),
                                       becommingFavorite: db.isBecomingFavorite)
    }
}
