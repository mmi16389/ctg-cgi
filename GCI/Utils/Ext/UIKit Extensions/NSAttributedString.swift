//
//  NSAttributedString.swift
//  GCI
//
//  Created by Anthony Chollet on 21/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.width)
    }
    
    static func commentMessage(withMessage comment: String, font: UIFont) -> NSAttributedString {
        var textAttributeComment: NSMutableAttributedString = NSMutableAttributedString()
        let comment = "\("task_commentary".localized) \(comment)"
        textAttributeComment = NSMutableAttributedString(string: comment, attributes: [NSAttributedString.Key.font: font])
        textAttributeComment.addAttributes([NSAttributedString.Key.font: UIFont.gciFontBold(Int(font.pointSize))], range: NSRange(location: 0, length: "task_commentary".localized.count))
        
        return textAttributeComment
    }
    
    static func addSimpleCell(message: String, font: UIFont) -> NSAttributedString {
        var textAttribute: NSMutableAttributedString = NSMutableAttributedString()
        textAttribute = NSMutableAttributedString(string: message, attributes: [NSAttributedString.Key.font: font])
        
        return textAttribute
    }
    
    static func addUnderlineCell(messageFull: String, underlinePart: String, font: UIFont) -> NSAttributedString {
        var textAttribute: NSMutableAttributedString = NSMutableAttributedString()
        let message = NSString(string: messageFull)
        let range = message.range(of: underlinePart)
        
        textAttribute = NSMutableAttributedString(string: messageFull, attributes: [NSAttributedString.Key.font: font])
        textAttribute.addAttributes([NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: range)
        
        return textAttribute
    }
    
    static func addColoredCell(messageFull: String, coloredPart: String, font: UIFont, fontColor: UIFont, color: UIColor) -> NSAttributedString {
        var textAttribute: NSMutableAttributedString = NSMutableAttributedString()
        let message = NSString(string: messageFull)
        let range = message.range(of: coloredPart)
        
        textAttribute = NSMutableAttributedString(string: messageFull, attributes: [NSAttributedString.Key.font: font])
        textAttribute.addAttributes([NSAttributedString.Key.foregroundColor: color], range: range)
        textAttribute.addAttributes([NSAttributedString.Key.font: fontColor], range: range)
        
        return textAttribute
    }
    
    static func asterixTextCenter(message: String, font: UIFont, color: UIColor) -> NSAttributedString {
        var textAttribute: NSMutableAttributedString = NSMutableAttributedString()
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
        textAttribute = NSMutableAttributedString(string: message, attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.paragraphStyle: style])
        
        return textAttribute
    }
}
