//
//  SpaceTableViewCell.swift
//  GCI
//
//  Created by Anthony Chollet on 20/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class SpaceTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initCell(backgroundColor: UIColor) {
        self.contentView.backgroundColor = backgroundColor
        self.backgroundColor = backgroundColor
    }
    
}
