//
//  PrefilledMessageViewModel.swift
//  GCI
//
//  Created by Florian ALONSO on 4/25/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

class PrefilledMessageViewModel: Comparable {
    static func == (lhs: PrefilledMessageViewModel, rhs: PrefilledMessageViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: PrefilledMessageViewModel, rhs: PrefilledMessageViewModel) -> Bool {
        let value = lhs.shortTitle.caseInsensitiveCompare(rhs.shortTitle)
        guard value != .orderedSame else {
            return false
        }
        return value == .orderedAscending
    }
    
    let id: Int
    let title: String
    let content: String
    let shortTitle: String
    
    init(id: Int, title: String, content: String, shortTitle: String) {
        self.id = id
        self.title = title
        self.content = content
        self.shortTitle = shortTitle
    }
}

extension PrefilledMessageViewModel {
    
    static func from(rejectMessage: RejectMessage) -> PrefilledMessageViewModel? {
        guard let title = rejectMessage.title,
            let content = rejectMessage.content,
            let shortTitle = rejectMessage.shortTitle else {
                return nil
        }
        
        return PrefilledMessageViewModel(id: Int(rejectMessage.id),
                                         title: title,
                                         content: content,
                                         shortTitle: shortTitle)
    }
    
    static func from(cancelMessage: CancelMessage) -> PrefilledMessageViewModel? {
        guard let title = cancelMessage.title,
            let content = cancelMessage.content,
            let shortTitle = cancelMessage.shortTitle else {
                return nil
        }
        
        return PrefilledMessageViewModel(id: Int(cancelMessage.id),
                                         title: title,
                                         content: content,
                                         shortTitle: shortTitle)
    }
}

extension PrefilledMessageViewModel: ModalSelectListItemsDataSource {
    var displayableTitle: String {
        return shortTitle
    }
    var displayableSubtitle: String? { return nil }
    var displayableAnnotation: String? { return nil }
}
