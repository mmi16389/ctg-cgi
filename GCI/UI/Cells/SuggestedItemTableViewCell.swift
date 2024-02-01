//
//  SuggestedItemTableViewCell.swift
//  GCI
//
//  Created by Anthony on 20/01/2023.
//  Copyright © 2023 Citegestion. All rights reserved.
//

import UIKit

class SuggestedItemTableViewCell: UITableViewCell {

    @IBOutlet weak var lblSuggestedItem: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    func setText(withText text: String, withFont font: UIFont = UIFont.gciFont(10), withAlignment alignment: NSTextAlignment = NSTextAlignment.left) {
        self.lblSuggestedItem.font = font
        self.lblSuggestedItem.textColor = UIColor.black
        self.lblSuggestedItem.textAlignment = alignment
        self.lblSuggestedItem.text = text
    }
}
