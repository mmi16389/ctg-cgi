//
//  String.swift
//  neopixl_ext
//
//  Created by Joris Thiery on 14/12/2017.
//  Copyright © 2017 Joris Thiery. All rights reserved.
//

import UIKit
import CommonCrypto

extension String {
    
    // MARK: Validation of Pattern
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isValidPhoneNumber() -> Bool {
        let phoneRegEx = "^[0-9-+]{9,15}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phoneTest.evaluate(with: self)
    }
    
    // MARK: Transformation
    var capitalizedFirstLetter: String {
        if self.count == 0 {
            return self
        }
        
        return String(self[self.startIndex]).capitalized + String(self.dropFirst()).localizedLowercase
    }
    
    // MARK: Localization
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(arguments: CVarArg...) -> String {
        let localazied = self.localized
        let value = String(format: localazied, arguments: arguments)
        return value
    }
    
    func localized(file localizationFile: String) -> String {
        return NSLocalizedString(self, tableName: localizationFile, bundle: Bundle.main, comment: "")
    }
    
    func localized(file localizationFile: String, arguments: CVarArg...) -> String {
        let localazied = localized(file: localizationFile)
        let value = String(format: localazied, arguments: arguments)
        return value
    }
    
    // MARK: BASE 64
    var base64Decoded: String? {
        
        guard let decodedData = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: decodedData, encoding: .utf8)
    }
    
    var base64Encoded: String? {
        
        let plainData = data(using: .utf8)
        return plainData?.base64EncodedString()
    }
    
    // MARK: UNDERLINED attributed string
    func underlinedAttributedString(withTextToUnderline underlinedString: String) -> NSAttributedString {
        
        //create attributed string from all of the text
        let attributedString = NSMutableAttributedString(string: self)
        
        //convert string to NSString to find the range
        let str = NSString(string: self)
        
        //found the range
        let rangeOfUnderline = str.range(of: underlinedString)
        
        //add Underline attribute in attributed string
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: rangeOfUnderline)
        
        return attributedString
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    // MARK: Generation Lorem ipsum
    func loremIpsumString(ofLength length: Int = 445) -> String {
        guard length > 0 else { return "" }
        
        let loremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        if loremIpsum.count > length {
            return String(loremIpsum[loremIpsum.startIndex..<loremIpsum.index(loremIpsum.startIndex, offsetBy: length)])
        }
        return loremIpsum
    }
    
    func sha256() -> String {
        if let stringData = self.data(using: String.Encoding.utf8) {
            return hexStringFromData(input: digest(input: stringData as NSData))
        }
        return ""
    }
    
    private func digest(input: NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format: "%02x", UInt8(byte))
        }
        
        return hexString
    }
    
    // MARK: Regex
    func ranges(for regexPattern: String) -> [Range<String.Index>] {
        do {
            let text = self
            let regex = try NSRegularExpression(pattern: regexPattern)
            let matches = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            
            return matches.flatMap { match in
                return (0..<match.numberOfRanges).flatMap {
                    let nsrange = match.range(at: $0)
                    guard let range = Range(nsrange, in: text) else {
                        return nil
                    }
                    return range
                }
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func heightInsideLabel(withFont font: UIFont, andWidth width: CGFloat) -> CGFloat {
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 2
        label.font = font
        label.text = self
        
        label.sizeToFit()
        return label.height
        
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
