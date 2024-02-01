//
//  LoginAPIService.swift
//  GCI
//
//  Created by Florian ALONSO on 3/11/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol LoginAPIService {
    
    func authenticateUser(login: String, password: String, clientId: String, completionHandler: @escaping RequestJSONCallback)
    
    func refreshUserToken(refreshToken: String, clientId: String, completionHandler: @escaping RequestJSONCallback)
    
    func logout(completionHandler: @escaping RequestStatusCallback)
    
    func makeSecureCall(completionHandler: @escaping RequestJSONCallback)
}
