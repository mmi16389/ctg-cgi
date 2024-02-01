//
//  CGITextfield.swift
//  GCI
//
//  Created by Anthony Chollet on 25/04/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class GCITextfield: UITextField {
    
    var charLimitation = 0
    var labelLimitation: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setInterface()
        
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 57))
        
        self.addTarget(self, action: #selector(textFieldDidChange), for: .allEditingEvents)
    }
    
    func defineLimitation(limitation: Int) {
        self.layoutIfNeeded()
        if labelLimitation == nil {
            self.labelLimitation = UILabel(frame: CGRect(x: 0, y: self.bounds.size.height + 5, width: self.width, height: 10))
            
            self.labelLimitation!.font = UIFont.gciFontLight(12)
            self.labelLimitation?.textAlignment = .right
            self.labelLimitation?.alpha = 0
            self.addSubview(self.labelLimitation!)
            
            if limitation > 0 {
                self.charLimitation = limitation
                labelLimitation?.text = "\(self.text?.count ?? 0)/\(limitation)"
            } else {
                self.charLimitation = 0
            }
        } else {
            self.labelLimitation?.alpha = 0
        }
    }
    
    func setInterface() {
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
        self.setPlaceHolderTextColor(UIColor.brownGrey)
        self.layer.borderColor = UIColor.veryLightPink.cgColor
        self.textColor = UIColor.charcoalGrey
        
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 13, height: 0))
        self.leftViewMode = .always
        
        self.clipsToBounds = false
    }
    
    @objc func textFieldDidChange() {
        if let text = self.text, !text.isEmpty {
            self.layer.borderColor = UIColor.cerulean.cgColor
            self.font = UIFont.gciFontRegular(15)
        } else {
            self.layer.borderColor = UIColor.veryLightPink.cgColor
            self.font = UIFont.gciFontRegular(15)
        }
        
        if charLimitation > 0 && (self.text?.count ?? 0) > charLimitation {
//            self.deleteBackward()
            let subStr = self.text!.prefix(charLimitation)
            self.text = "\(subStr)"
        } else {
            if labelLimitation != nil {
                labelLimitation?.text = "\(self.text?.count ?? 0)/\(self.charLimitation)"
                self.labelLimitation?.frame = CGRect(x: 0, y: self.bounds.size.height + 5, width: self.width, height: 10)
            }
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        if labelLimitation != nil {
            self.labelLimitation!.alpha = 1
        }
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        if labelLimitation != nil {
            self.labelLimitation!.alpha = 0
        }
        return super.resignFirstResponder()
    }
    
     override var text: String? {
        didSet {
            self.textFieldDidChange()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            self.backgroundColor = UIColor.white
        }
    }
    
    deinit {
        self.removeTarget(nil, action: nil, for: .allEvents)
    }
}
