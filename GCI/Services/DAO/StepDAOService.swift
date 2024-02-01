//
//  StepDAOService.swift
//  GCI
//
//  Created by Anthony Chollet on 24/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol StepDAOService {
    typealias ListCallback = (_ list: [Step]) -> Void
    typealias UniqueCallback = (_ object: Step?) -> Void
    typealias StatusCallback = (_ success: Bool) -> Void
    
    func all(completion: @escaping ListCallback)
    func allModified(completion: @escaping ListCallback)
    func unique(byId id: Int, completion: @escaping UniqueCallback)
    func delete(byId id: Int, completion: @escaping StatusCallback)
    func deleteAll(completion: @escaping StatusCallback)
    func update(fromViewModel viewModel: StepViewModel, oldAttachment: AttachmentViewModel?, completion: @escaping StepDAOService.UniqueCallback)
    func add(fromViewModel viewModel: StepViewModel, completion: @escaping StepDAOService.UniqueCallback)
    func markAsEditionDone(byId id: Int, completion: @escaping StepDAOService.UniqueCallback)
    func saveResponse(fromJson json: JSON, completion: @escaping StepDAOService.UniqueCallback)
    func saveResponses(fromJson json: JSON, completion: @escaping ListCallback)
}
