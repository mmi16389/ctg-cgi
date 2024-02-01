//
//  Hey.swift
//  GCI
//
//  Created by Florian ALONSO on 5/8/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreStore

protocol JSONParcelable {
    associatedtype Current
    
    static func findOrCreate(fromJSON json: JSON, inTransaction transaction: AsynchronousDataTransaction) -> Current
    
    func update(fromJSON json: JSON, inTransaction transaction: AsynchronousDataTransaction)
}

extension JSONParcelable {
    
    static func findOrCreate(fromJSON json: [JSON], inTransaction transaction: AsynchronousDataTransaction) -> [Current] {
        return json.map {
            findOrCreate(fromJSON: $0, inTransaction: transaction)
        }
    }
}
