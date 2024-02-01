//
//  TimeableViewModel.swift
//  GCI
//
//  Created by Florian ALONSO on 4/26/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

protocol TimeableViewModel {
    var title: String { get }
    var description: String { get }
    var date: Date { get }
    var userFullName: String { get }
    var userIdentifier: String { get }
}
