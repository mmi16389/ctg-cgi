//
//  HomeDITypeCollectionViewCell.swift
//  GCI
//
//  Created by Anthony Chollet on 07/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class HomeTaskTypeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblNumberOfDI: UILabel!
    @IBOutlet weak var lblTodayDI: UILabel!
    @IBOutlet weak var viewTypeHeader: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setInterface()
        setText()
    }

    func setInterface() {
        self.layer.cornerRadius = 3
        self.viewTypeHeader.backgroundColor = UIColor.white
    }
    
    func setText() {
        self.lblType.font = UIFont.gciFontMedium(18)
        self.lblNumberOfDI.font = UIFont.gciFontBold(38)
        self.lblTodayDI.font = UIFont.gciFontMedium(12)
        
        self.lblType.textColor = UIColor.cerulean
        self.lblNumberOfDI.textColor = UIColor.brownGrey
        self.lblTodayDI.textColor = UIColor.brownGreyTwo
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.viewTypeHeader.backgroundColor = UIColor.tangerine
                self.lblType.textColor = UIColor.white
                self.lblNumberOfDI.textColor = UIColor.tangerine
                self.lblTodayDI.textColor = UIColor.tangerine
                self.addShadow(radius: 12)
            } else {
                self.viewTypeHeader.backgroundColor = UIColor.white
                self.lblType.textColor = UIColor.cerulean
                self.lblNumberOfDI.textColor = UIColor.brownGrey
                self.lblTodayDI.textColor = UIColor.brownGreyTwo
                self.removeShadow()
            }
        }
    }
    
    func setCell(withCategory category: TaskCategory, numberOfTask tasksCount: Int, numberOfTaskToday tasksCountToday: Int? = nil, isSelectCategory: Bool = false) {
        self.lblType.text = category.title
        self.lblNumberOfDI.text = "\(tasksCount)"
        
        if let tasksCountToday = tasksCountToday, tasksCountToday > 0 {
            self.lblTodayDI.text = "+" + "dashboard_category_today".localized(arguments: String(tasksCountToday))
        } else {
            self.lblTodayDI.text = ""
        }
        
        if isSelectCategory {
            self.isSelected = true
        } else {
            self.isSelected = false
        }
    }
}
