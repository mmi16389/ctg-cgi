//
//  GCIButton.swift
//  GCI
//
//  Created by Anthony Chollet on 25/04/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class GCIButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 5
        self.layer.backgroundColor = UIColor.tangerine.cgColor
        self.titleLabel?.font = UIFont.gciFontBold(17)
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(UIColor.white, for: .disabled)
        
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 49))
    }
    
    open override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.3
        }
    }
}
