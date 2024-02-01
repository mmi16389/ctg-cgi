//
//  pickerFileView.swift
//  GCI
//
//  Created by Anthony Chollet on 06/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class PickerFileView: UIView {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgIconPicker: UIImageView!
    @IBOutlet weak var viewSelectedContent: UIView!
    @IBOutlet weak var imgSelectedContent: UIImageView!
    @IBOutlet weak var btnDeleteSelectedContent: UIButton!
    
    override func awakeFromNib() {
        self.setInterface()
    }
    
    func setInterface() {
        self.addShadow()
        self.layer.cornerRadius = 4
        
        self.lblTitle.font = UIFont.gciFontMedium(16)
        self.lblTitle.textColor = UIColor.cerulean
    }
}
