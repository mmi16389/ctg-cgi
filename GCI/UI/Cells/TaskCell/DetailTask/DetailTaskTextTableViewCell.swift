//
//  DetailTaskTextTableViewCell.swift
//  GCI
//
//  Created by Anthony Chollet on 21/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class DetailTaskTextTableViewCell: UITableViewCell {

    @IBOutlet weak var imgIconLate: UIImageView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var constraintTextToleading: NSLayoutConstraint!
    
    private var hasAction: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if self.hasAction && selected {
            self.contentView.backgroundColor = UIColor.lightPeriwinkle
        } else {
            self.contentView.backgroundColor = .clear
        }
    }
    
    func initCell(withMessage messageAttribute: NSAttributedString?, AndIsLate isLate: Bool, hasActionOnTouch: Bool, marginLeft: CGFloat = 46) {
        if !isLate {
            self.imgIconLate.isHidden = true
            constraintTextToleading.constant = marginLeft
        } else {
            self.imgIconLate.isHidden = false
            constraintTextToleading.constant = self.imgIconLate.width + 18 + marginLeft
        }
        self.layoutIfNeeded()
    
        self.lblMessage.attributedText = messageAttribute
        
        self.hasAction = hasActionOnTouch
    }
}
