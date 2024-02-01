//
//  FilterCollectionViewCell.swift
//  GCI
//
//  Created by Anthony Chollet on 08/07/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {

    typealias ActionOnTouch = (_ cell: FilterCollectionViewCell) -> Void
    
    @IBOutlet weak var lblFilterTitle: UILabel!
    @IBOutlet weak var iconCheck: UIImageView!
    
    var actionOnTouch: ActionOnTouch?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 9
    }
    
    override var isSelected: Bool {
        didSet {
            updateDesign()
        }
    }
    
    func updateDesign() {
        if isSelected {
            self.iconCheck.isHidden = false
            self.backgroundColor = UIColor.white
            self.lblFilterTitle.textColor = UIColor.cerulean
           self.lblFilterTitle.textAlignment = .left
        } else {
            self.iconCheck.isHidden = true
            self.backgroundColor = UIColor.white.withAlphaComponent(0.3)
            self.lblFilterTitle.textColor = UIColor.white
            self.lblFilterTitle.textAlignment = .center
        }
        
        self.layoutIfNeeded()
    }

    func setCell(withTitle title: String) {
        self.lblFilterTitle.font = UIFont.gciFontMedium(13)
        self.lblFilterTitle.text = title
    }
}
