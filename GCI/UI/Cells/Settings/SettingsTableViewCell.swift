//
//  SettingsTableViewCell.swift
//  GCI
//
//  Created by Anthony Chollet on 10/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var lblSettingName: UILabel!
    @IBOutlet weak var imgSettingIcon: UIImageView!
    @IBOutlet weak var viewContentCell: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        setText()
        setInterface()
    }
    
    func setInterface() {
        self.viewContentCell.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.lightPeriwinkle
        self.backgroundColor = UIColor.lightPeriwinkle
        self.viewContentCell.addShadow(offset: CGSize(width: 0, height: 1))
        self.viewContentCell.layer.cornerRadius = 5
    }
    
    func setText() {
        self.lblSettingName.font = UIFont.gciFontMedium(16)
        self.lblSettingName.textColor = UIColor.cerulean
    }
 
    func initWithSettings(name: String?, icon: UIImage?) {
        if let name = name {
            self.lblSettingName.text = name
        }
        
        if let icon = icon {
            self.imgSettingIcon.image = icon
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super .setSelected(selected, animated: animated)
        self.viewContentCell.backgroundColor = selected ? UIColor.lightPeriwinkle : UIColor.white
    }
}
