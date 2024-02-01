//
//  SectionTitleFilterCollectionReusableView.swift
//  GCI
//
//  Created by Anthony Chollet on 09/07/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class SectionTitleFilterCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var lblTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lblTitle.textColor = UIColor.white
        self.lblTitle.font = UIFont.gciFontMedium(16)
    }
    
    func initCell(withTitle title: String) {
        self.lblTitle.text = title
    }
}
