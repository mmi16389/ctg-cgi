//
//  UserDataFilter.swift
//  GCI
//
//  Created by Florian ALONSO on 5/14/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class UserDataFilter: Equatable {
    
    static func == (lhs: UserDataFilter, rhs: UserDataFilter) -> Bool {
        return lhs.urgentOnly == rhs.urgentOnly
            && lhs.lateOnly == rhs.lateOnly
            && lhs.favoritesOnly == rhs.favoritesOnly
            && lhs.publicOnly == rhs.publicOnly
            && lhs.statusList == rhs.statusList
            && lhs.serviceList == rhs.serviceList
            && lhs.visibility == rhs.visibility
            && lhs.startDate == rhs.startDate
            && lhs.endDate == rhs.endDate
            && lhs.fullText == rhs.fullText
    }
    
    static let unique: UserDataFilter = {
       return UserDataFilter()
    }()
    
    var urgentOnly = false
    var lateOnly = false
    var favoritesOnly = false
    var publicOnly = false
    var statusList = [TaskViewModel.Status]()
    var serviceList = [Int]()
    var visibility: Visibility?
    var startDate: Date?
    var endDate: Date?
    var fullText: String?
    
    var isFilterActivated: Bool {
        return !(fullText?.isEmpty ?? true) || startDate != nil || !serviceList.isEmpty || visibility != nil
    }
    
    var isFilterPublicActivated: Bool {
        return isFilterActivated || !statusList.isEmpty
    }
    
    var isFilterMapActivated: Bool {
        return !(fullText?.isEmpty ?? true) || startDate != nil || !serviceList.isEmpty || !statusList.isEmpty
    }
    
    private init() {
        reset()
    }
    
    func reset() {
        urgentOnly = false
        lateOnly = false
        publicOnly = false
        favoritesOnly = false
        statusList.removeAll()
        serviceList.removeAll()
        visibility = nil
        startDate = nil
        endDate = nil
        fullText = nil
    }
    
    func checkUrgentOk(forTask task: TaskViewModel) -> Bool {
        return !urgentOnly || task.isUrgent
    }
    
    func checkFavoriteOk(forTask task: TaskViewModel) -> Bool {
        return !favoritesOnly || task.isFavorite
    }
    
    func checkPublicOk(forTask task: TaskViewModel) -> Bool {
        return !publicOnly || task.isPublic
    }
    
    func checkLateOk(forTask task: TaskViewModel) -> Bool {
        return !lateOnly || task.isLate
    }
    
    func checkVisibilityOk(forTask task: TaskViewModel) -> Bool {
        guard let visibility = self.visibility else {
            return true
        }
        
        switch visibility {
        case .notOnMap:
            return task.domain == nil || !task.domain!.useMap
        case .onMap:
            return task.domain != nil && task.domain!.useMap && task.location != nil
        }
    }
    
    func checkServiceOk(forTask task: TaskViewModel) -> Bool {
        guard let service = task.service else {
            return !serviceList.isEmpty
        }
        return serviceList.isEmpty || serviceList.contains(service.id)
    }
    
    func checkStatusOk(forTask task: TaskViewModel) -> Bool {
        return statusList.isEmpty || statusList.contains(task.status)
    }
    
    func checkDateOk(forTask task: TaskViewModel) -> Bool {
        guard let startDate = self.startDate else {
            return true
        }
        guard let endDate = self.endDate else {
            return task.isCreatedSameDay(than: startDate)
        }
        return task.isCreated(after: startDate, andBefore: endDate)
    }
    
    func checkFullTextOk(forTask task: TaskViewModel) -> Bool {
        guard let fulltext = self.fullText else {
            return true
        }
        return task.searchDefinition.contains(fulltext.lowercased())
    }
}

extension UserDataFilter {
    enum Visibility {
        case onMap
        case notOnMap
    }
}

extension TaskViewModel {
    
    var isValidForFastFilters: Bool {
        return UserDataFilter.unique.checkFavoriteOk(forTask: self)
            && UserDataFilter.unique.checkUrgentOk(forTask: self)
            && UserDataFilter.unique.checkLateOk(forTask: self)
            && UserDataFilter.unique.checkVisibilityOk(forTask: self)
            && UserDataFilter.unique.checkServiceOk(forTask: self)
            && UserDataFilter.unique.checkDateOk(forTask: self)
            && UserDataFilter.unique.checkFullTextOk(forTask: self)
    }
    
    var isValidForFastAndPublicFilters: Bool {
        return self.isValidForFastFilters
            && UserDataFilter.unique.checkPublicOk(forTask: self)
            && UserDataFilter.unique.checkStatusOk(forTask: self)
    }
    
    var isValidForMapFilters: Bool {
        return UserDataFilter.unique.checkFavoriteOk(forTask: self)
            && UserDataFilter.unique.checkUrgentOk(forTask: self)
            && UserDataFilter.unique.checkLateOk(forTask: self)
            && UserDataFilter.unique.checkServiceOk(forTask: self)
            && UserDataFilter.unique.checkDateOk(forTask: self)
            && UserDataFilter.unique.checkStatusOk(forTask: self)
            && UserDataFilter.unique.checkFullTextOk(forTask: self)
    }
}

extension Array where Element: TaskViewModel {
    
    func applyGCIDashboardFilters() -> [Element] {
        return self.filter {
            $0.isValidForFastFilters
            }
            .sorted()
    }
    
    func applyGCIGlobalFilters() -> [Element] {
        return self.filter {
            $0.isValidForFastAndPublicFilters
            }
            .sorted()
    }
    
    func applyGCIMapFilters() -> [Element] {
        return self.filter {
            $0.isValidForMapFilters
            }
            .sorted()
    }
    
}
