//
//  GCITextview.swift
//  GCI
//
//  Created by Anthony Chollet on 06/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import UIKit

class GCITextview: UITextView {
    
    var placeholder: String = ""
    var charLimitation = 0
    var labelLimitation: UILabel?
    
    override var isEditable: Bool {
        didSet {
            if self.isEditable {
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(textDidChange),
                                                       name: UITextView.textDidChangeNotification,
                                                       object: nil)
                
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(textDidBegingEditing),
                                                       name: UITextView.textDidBeginEditingNotification,
                                                       object: nil)
                
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(textDidEndEditing),
                                                       name: UITextView.textDidEndEditingNotification,
                                                       object: nil)
                self.isScrollEnabled = true
            } else {
                self.isScrollEnabled = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setInterface()
    }
    
    deinit {
        if isEditable {
            NotificationCenter.default.removeObserver(self,
                                                      name: UITextView.textDidChangeNotification,
                                                      object: nil)
            
            NotificationCenter.default.removeObserver(self,
                                                      name: UITextView.textDidBeginEditingNotification,
                                                      object: nil)
            
            NotificationCenter.default.removeObserver(self,
                                                      name: UITextView.textDidEndEditingNotification,
                                                      object: nil)
        }
    }
    
    func defineLimitation(limitation: Int) {
        self.layoutIfNeeded()
        if self.labelLimitation == nil {
            self.labelLimitation = UILabel(frame: CGRect(x: 0, y: self.frame.origin.y + self.bounds.height + 5, width: self.frame.origin.x + self.bounds.size.width , height: 10))
            
            self.labelLimitation!.font = UIFont.gciFontLight(12)
            self.labelLimitation?.textAlignment = .right
            self.labelLimitation?.alpha = 0
            self.superview!.addSubview(self.labelLimitation!)
            
            if limitation > 0 {
                self.charLimitation = limitation
                if self.text != placeholder {
                    labelLimitation?.text = "\(self.text?.count ?? 0)/\(limitation)"
                } else {
                    labelLimitation?.text = "0/\(limitation)"
                }
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
        
        self.layer.borderColor = UIColor.veryLightPink.cgColor
        self.textColor = UIColor.cerulean
        
        self.textContainerInset = UIEdgeInsets(top: 12, left: 5, bottom: 15, right: 5)
        self.font = UIFont.gciFontRegular(14)
    }
    
    override var text: String? {
        didSet {
            self.textDidChange()
        }
    }
    
    @objc private func textDidChange() {
        if let text = self.text, !text.isEmpty, self.text != placeholder {
            DispatchQueue.main.async {
                self.textColor = UIColor.charcoalGrey
                self.layer.borderColor = UIColor.cerulean.cgColor
                self.font = UIFont.gciFontRegular(15)
            }
        } else {
            DispatchQueue.main.async {
                self.textColor = UIColor.veryLightPink
                self.layer.borderColor = UIColor.veryLightPink.cgColor
                self.font = UIFont.gciFontRegular(15)
            }
        }
        
        if charLimitation > 0 && (self.text?.count ?? 0) > charLimitation {
            let subStr = self.text!.prefix(500)
            self.text = "\(subStr)"
        } else {
            if labelLimitation != nil {
                if self.text != placeholder {
                    labelLimitation?.text = "\(self.text?.count ?? 0)/\(self.charLimitation)"
                } else {
                    labelLimitation?.text = "0/\(self.charLimitation)"
                }
                self.labelLimitation?.frame = CGRect(x: 0, y: self.frame.origin.y + self.bounds.size.height + 5, width: self.frame.origin.x + self.bounds.size.width, height: 10)
            }
        }
        
        self.delegate?.textViewDidChange?(self)
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
    
    @objc private func textDidBegingEditing() {
        if let text = self.text, text == placeholder {
            DispatchQueue.main.async {
                self.text = ""
            }
        }
    }
    
    @objc private func textDidEndEditing() {
        if let text = self.text, text.isEmpty {
            DispatchQueue.main.async {
                self.text = self.placeholder
            }
        }
    }
}
