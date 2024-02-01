//
//  CGIShortcutButton.swift
//  GCI
//
//  Created by Anthony Chollet on 08/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class CGIShortcutButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setInterface()
        self.addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
    }
    
    func setInterface() {
        self.layer.cornerRadius = 4
        self.layer.backgroundColor = UIColor.white.cgColor
        self.setTitleColor(UIColor.charcoalGrey, for: .normal)
        self.setTitleColor(UIColor.white, for: .selected)
        
        self.titleLabel?.font = UIFont.gciFontRegular(15)
    }
    
    @objc func touchUpInside(sender: UIButton!) {
        if isSelected {
            self.isSelected = false
        } else {
            self.isSelected = true
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.layer.backgroundColor = UIColor.redPink.cgColor
            } else {
                self.layer.backgroundColor = UIColor.white.cgColor
            }
        }
    }
}
