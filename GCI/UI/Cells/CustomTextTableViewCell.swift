//
//  CustomTextTableViewCell.swift
//  GCI
//
//  Created by Anthony Chollet on 13/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class CustomTextTableViewCell: UITableViewCell {
    @IBOutlet weak var lblText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.setInterface()
        self.setText(withText: "")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setInterface() {
        self.contentView.backgroundColor = UIColor.lightPeriwinkle
        self.backgroundColor = UIColor.lightPeriwinkle
    }
    
    func setText(withText text: String, withFont font: UIFont = UIFont.gciFont(10), withAlignment alignment: NSTextAlignment = NSTextAlignment.left) {
        self.lblText.font = font
        self.lblText.textColor = UIColor.brownGrey
        self.lblText.textAlignment = alignment
        self.lblText.text = text
    }
    
}
