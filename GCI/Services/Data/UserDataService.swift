//
//  UserDataService.swift
//  GCI
//
//  Created by Florian ALONSO on 5/10/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

protocol UserDataService {
    
    typealias StateCallback = (_ result: UIResult) -> Void
    typealias MessageCallbak = (_ result: [PrefilledMessageViewModel]) -> Void
    
    func update(completion: @escaping StateCallback)

    func cancelMessages(completion: @escaping MessageCallbak)
    func rejectMessages(completion: @escaping MessageCallbak)
}
