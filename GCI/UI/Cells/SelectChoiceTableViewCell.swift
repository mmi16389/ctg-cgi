//
//  SelectChoiceTableViewCell.swift
//  GCI
//
//  Created by Anthony Chollet on 03/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class SelectChoiceTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblAnnotation: UILabel!
    @IBOutlet weak var imgSelect: UIImageView!
    @IBOutlet weak var constraintTitleLabelCenter: NSLayoutConstraint!
    @IBOutlet weak var viewSeparator: UIView!
    
    private var isDirectSelectable = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setInterface()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if isDirectSelectable {
            if selected {
                self.lblTitle.textColor = UIColor.cerulean
                self.imgSelect.isHidden = true
            } else {
                self.lblTitle.textColor = UIColor.charcoalGrey
                self.imgSelect.isHidden = false
            }
        } else {
            if selected {
                self.imgSelect.image = UIImage(named: "ico_check_list")
            } else {
                self.imgSelect.image = UIImage(named: "ico_round_list")
            }
        }
        self.layoutIfNeeded()
    }
    
    func initCell(withTitle title: String, subtitle: String = "", annotation: String = "", imageAnnotation: UIImage = UIImage(named: "ico_round_list")!, isDirectSelectable: Bool = false, isDisplaySeparator: Bool = true, interaction: Bool = true) {
        if subtitle.isEmpty {
            self.constraintTitleLabelCenter.constant = 0
        } else {
            self.constraintTitleLabelCenter.constant = -15
        }
        self.layoutIfNeeded()
        
        self.lblTitle.text = title
        self.lblSubtitle.text = subtitle
        self.lblAnnotation.text = annotation
        self.imgSelect.image = imageAnnotation
        self.isDirectSelectable = isDirectSelectable
        self.isUserInteractionEnabled = interaction
        
        if self.isUserInteractionEnabled {
            self.imgSelect.alpha = 1
            self.lblTitle.alpha = 1
        } else {
            self.imgSelect.alpha = 0.5
            self.lblTitle.alpha = 0.5
        }
        
        if isDisplaySeparator {
            self.viewSeparator.backgroundColor = UIColor.veryLightPink
        } else {
            self.viewSeparator.backgroundColor = UIColor.white
        }
    }
    
    func setInterface() {
        self.lblTitle.font = UIFont.gciFontRegular(17)
        self.lblTitle.textColor = UIColor.charcoalGrey
        
        self.lblSubtitle.font = UIFont.gciFontRegular(14)
        self.lblSubtitle.textColor = UIColor.charcoalGrey
        
        self.lblAnnotation.font = UIFont.gciFontRegular(14)
        self.lblAnnotation.textColor = UIColor.charcoalGrey
    }
}
