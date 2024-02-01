//
//  ReferentialDaoService.swift
//  GCI
//
//  Created by Florian ALONSO on 5/8/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ReferentialMapZone {
    let zones: [Zone]
    let maps: [MapReferential]
}

protocol ReferentialDaoService {
    
    typealias StateCallback = (_ result: Bool) -> Void
    typealias ReferentialMapZoneCallbak = (_ result: ReferentialMapZone) -> Void
    typealias PermissionCodeCallbak = (_ result: [Int]) -> Void
    typealias InterventionTypeListCallback = (_ result: [InterventionType]) -> Void
    typealias DomainListCallback = (_ result: [Domain]) -> Void
    typealias ServiceListCallback = (_ result: [Service]) -> Void
    
    func saveResponses(fromJson json: JSON, completion: @escaping StateCallback)
    func savePermissionsResponses(fromJson jsonArray: [JSON], completion: @escaping StateCallback)
    func allMapZone(completion: @escaping ReferentialMapZoneCallbak)
    func uniquePermissionCodes(completion: @escaping PermissionCodeCallbak)
    func clearPermissions(completion: @escaping StateCallback)
    func deleteAll(completion: @escaping StateCallback)
    
    func allInterventionTypes(completion: @escaping InterventionTypeListCallback)
    func allDomains(completion: @escaping DomainListCallback)
    func allServices(completion: @escaping ServiceListCallback)
    func services(byIds ids: [Int], completion: @escaping ServiceListCallback)
}
