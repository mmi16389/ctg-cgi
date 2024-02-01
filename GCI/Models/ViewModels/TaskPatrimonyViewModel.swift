//
//  TaskPatrimonyViewModel.swift
//  GCI
//
//  Created by Florian ALONSO on 4/25/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import ArcGIS

class TaskPatrimonyViewModel: Comparable {
    
    typealias TaskPatrimonyViewModelCompletion = (TaskPatrimonyViewModel?) -> Void
    
    static func == (lhs: TaskPatrimonyViewModel, rhs: TaskPatrimonyViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: TaskPatrimonyViewModel, rhs: TaskPatrimonyViewModel) -> Bool {
        return lhs.key < rhs.key
    }
    
    let id: Int
    let key: String
    let description: String
    let feature: AGSFeature?
    var categorie: String = ""
    var distance: Int?
    var address: String = ""
    
    init(id: Int, key: String, categorie: String = "", feature: AGSFeature? = nil, description descriptionOpt: String? = nil) {
        self.id = id
        self.key = key
        self.description = descriptionOpt ?? ""
        self.feature = feature
        self.categorie = categorie
    }
    
    var distanceAsString: String? {
        guard let distance = self.distance else {
            return nil
        }
        return "task_patrimony_distance".localized(arguments: String(distance))
    }
}

extension TaskPatrimonyViewModel: Convertible {
    
    static func from(db: TaskPatrimony) -> TaskPatrimonyViewModel? {
        guard let key = db.key else {
            return nil
        }
        
        return TaskPatrimonyViewModel(id: Int(db.id),
                                      key: key,
                                      description: db.desc)
    }
    
    static func from(feature: AGSFeature, completion: @escaping TaskPatrimonyViewModelCompletion) {
        if let feature = feature as? AGSArcGISFeature {
            feature.load { (error) in
                
                if error != nil {
                    completion(nil)
                } else {
                    guard let domainId = feature.attributes["ID_ELEMENT"] == nil ? 0 : feature.attributes["ID_ELEMENT"] as? Int else {
                        completion(nil)
                        return
                    }
                    guard let descriptionValue = feature.attributes["ELECLE"] == nil ? "" : feature.attributes["ELECLE"] as? String else {
                        completion(nil)
                        return
                    }
                    guard let categorieValue = feature.attributes["ETYLIBELLE"] == nil ? "" : feature.attributes["ETYLIBELLE"] as? String else {
                        completion(nil)
                        return
                    }
                    
                    completion(TaskPatrimonyViewModel(id: domainId,
                                                      key: descriptionValue,
                                                      categorie: categorieValue,
                                                      feature: feature,
                                                      description: descriptionValue))
                }
            }
        } else {
            completion(nil)
        }
    }
}

extension TaskPatrimonyViewModel: ModalSelectListItemsDataSource {
    var displayableTitle: String {
        if !self.categorie.isEmpty {
            return "\(categorie) - \(self.key)"
        } else {
            return self.key
        }
    }
    
    var displayableSubtitle: String? {
        return self.address
    }
    var displayableAnnotation: String? {
        return self.distanceAsString
    }
}
