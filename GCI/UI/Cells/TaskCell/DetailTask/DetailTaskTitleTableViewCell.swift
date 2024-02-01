//
//  DetailTaskTitleTableViewCell.swift
//  GCI
//
//  Created by Anthony Chollet on 20/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class DetailTaskTitleTableViewCell: UITableViewCell {

    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgCollapsed: UIImageView!
    @IBOutlet weak var constraintTextToleading: NSLayoutConstraint!
    @IBOutlet weak var imgRight: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setText()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setText() {
        self.lblTitle.font = UIFont.gciFontBold(17)
        self.lblTitle.textColor = UIColor.cerulean
    }
    
    func initCell(withTitle title: String, andIcon icon: UIImage?, isCollapsable: Bool, isCollapsed: Bool, imageRight: UIImage? = nil) {
        self.lblTitle.text = title
        if let icon = icon {
            self.imgIcon.isHidden = false
            self.imgIcon.image = icon
            constraintTextToleading.constant = 45
        } else {
            self.imgIcon.isHidden = true
            constraintTextToleading.constant = 24
        }
        
        if imageRight != nil {
            self.imgRight.isHidden = false
            self.imgRight.image = imageRight
        } else {
            self.imgRight.isHidden = true
        }
        
        if isCollapsable {
            self.imgCollapsed.isHidden = false
            if isCollapsed {
                self.imgCollapsed.image = UIImage(named: "ico_circle_arrow_close_details_DI")
            } else {
                self.imgCollapsed.image = UIImage(named: "ico_circle_arrow_open_details_DI")
            }
        } else {
            self.imgCollapsed.isHidden = true
        }
    }
    
    func setColapsed(isCollapsed: Bool) {
        if isCollapsed {
            self.imgCollapsed.image = UIImage(named: "ico_circle_arrow_close_details_DI")
        } else {
            self.imgCollapsed.image = UIImage(named: "ico_circle_arrow_open_details_DI")
        }
    }
}
