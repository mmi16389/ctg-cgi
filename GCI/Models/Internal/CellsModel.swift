//
//  CellsModel.swift
//  GCI
//
//  Created by Anthony Chollet on 03/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import UIKit

enum CellType {
    case taskLinked
    case taskTitle
    case space
    case taskText
    case textfield
    case attachementTask
    case textview
    case selectItem
    case picker
    case verticalBreadcrumb
    case textfieldDateHourPicker
}

struct DataCell {
    typealias Action = (_ cell: UITableViewCell) -> Void
    var title: String
    var placeHolder: String
    var prefilledText: String
    var icon: UIImage?
    var isLate: Bool
    var isSelected: Bool
    var messageAttribute: NSAttributedString?
    var typeCell: CellType
    var previousTask: [TaskViewModel]?
    var nextTask: [TaskViewModel]?
    var backgroundColor: UIColor
    var attachement: ViewableAttachment?
    var actionOnTouch: Action?
    var isCollapsable: Bool
    var isCollapsed: Bool
    var isTextFieldEditable: Bool
    var rightIcon: UIImage?
    var step: ViewableStep?
    var history: HistoryViewModel?
    var charLimitation: Int?
    var intreactionEnabled: Bool?
    
    init(typeCell: CellType, title: String = "", icon: UIImage? = nil, rightIcon: UIImage? = nil, isCollapsable: Bool = false, isLate: Bool = false, isSelected: Bool = false, messageAttribute: NSAttributedString? = nil, previousTask: [TaskViewModel]? = nil, nextTask: [TaskViewModel]? = nil, backgroundColor: UIColor = UIColor.lightPeriwinkle, attachement: ViewableAttachment? = nil, isCollapsed: Bool = false, placeHolder: String = "", prefilledText: String = "", isTextFieldEditable: Bool = false, intreactionEnabled: Bool? = true, actionOnTouch: Action? = nil, step: ViewableStep? = nil, history: HistoryViewModel? = nil, charLimitation: Int? = 0) {
        
        self.typeCell = typeCell
        self.title = title
        self.icon = icon
        self.isLate = isLate
        self.messageAttribute = messageAttribute
        self.previousTask = previousTask
        self.nextTask = nextTask
        self.backgroundColor = backgroundColor
        self.attachement = attachement
        self.actionOnTouch = actionOnTouch
        self.isCollapsable = isCollapsable
        self.isCollapsed = isCollapsed
        self.placeHolder = placeHolder
        self.prefilledText = prefilledText
        self.isTextFieldEditable = isTextFieldEditable
        self.rightIcon = rightIcon
        self.isSelected = isSelected
        self.step = step
        self.history = history
        self.charLimitation = charLimitation
        self.intreactionEnabled = intreactionEnabled
    }
}
