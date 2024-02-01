//
//  DatabaseParsable.swift
//  GCI
//
//  Created by Florian ALONSO on 5/2/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

protocol Convertible {
    associatedtype InputModel
    associatedtype OutputModel
    
    static func from(db: InputModel) -> OutputModel?
}

extension Convertible {
    typealias ParsedCompletionHandler = (OutputModel?) -> Void
    typealias ParsedArrayCompletionHandler = ([OutputModel]) -> Void
    
    static func from(dbList: [InputModel]) -> [OutputModel] {
        return dbList.flatMap({ (db) -> OutputModel? in
            return from(db: db)
        })
    }
    
    static func from(db: InputModel?) -> OutputModel? {
        guard let db = db else {
            return nil
        }
        return from(db: db)
    }
    
    static func from(db: InputModel, completion: @escaping ParsedCompletionHandler) {
        let closure = {
            let newObject = from(db: db)
            DispatchQueue.main.async {
                completion(newObject)
            }
        }
        
        if OperationQueue.current == DispatchQueue.main {
            DispatchQueue.global().async(execute: closure)
        } else {
            closure()
        }
    }
    
    static func from(dbList: [InputModel], completion: @escaping ParsedArrayCompletionHandler) {
        let closure = {
            let newArray = from(dbList: dbList)
            DispatchQueue.main.async {
                completion(newArray)
            }
        }
        
        if OperationQueue.current == DispatchQueue.main {
            DispatchQueue.global().async(execute: closure)
        } else {
            closure()
        }
    }
}
