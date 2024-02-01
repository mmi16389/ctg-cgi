//
//  LoginDataService.swift
//  GCI
//
//  Created by Florian ALONSO on 3/11/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol LoginDataService {
    
    typealias AuthenticateCallback = (_ result: ViewModelResult<User>) -> Void
    typealias VoidCallback = () -> Void
    
    func authenticateUser(login: String, password: String, completionHandler: @escaping AuthenticateCallback)
    
    func makeSecureAPICall(completionHandler: @escaping VoidCallback)
}
