//
//  SettingsNotificationsTypeTableViewCell.swift
//  GCI
//
//  Created by Anthony Chollet on 10/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

protocol SettingsNotificationsTypeTableViewCellDelegate: class {
    func didValueChanged(isOn: Bool, notifCode: Constant.Notification.Code)
}

class SettingsNotificationsTypeTableViewCell: UITableViewCell {

    @IBOutlet weak var lblNotificationType: UILabel!
    @IBOutlet weak var switchAcceptNotification: UISwitch!
    
    weak var delegate: SettingsNotificationsTypeTableViewCellDelegate?
    private var code: Constant.Notification.Code = .general
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setText()
        self.backgroundColor = UIColor.clear
        
        self.switchAcceptNotification.onTintColor = UIColor.cerulean.withAlphaComponent(0.3)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setText() {
        self.lblNotificationType.font = UIFont.gciFontRegular(15)
        self.lblNotificationType.textColor = UIColor.charcoalGrey
    }
    
    func initCell(notificationTypeName: String?, isActive: Bool, notifCode: Constant.Notification.Code) {
        self.code = notifCode
        
        if let notificationTypeName = notificationTypeName {
            self.lblNotificationType.text = notificationTypeName
        }
        
        if isActive {
            self.switchAcceptNotification.isOn = true
        } else {
            self.switchAcceptNotification.isOn = false
        }
        
        if self.switchAcceptNotification.isOn {
            self.switchAcceptNotification.thumbTintColor = UIColor.cerulean
        } else {
            self.switchAcceptNotification.thumbTintColor = UIColor.brownGrey
        }
    }
    
    @IBAction func valueChanged(_ sender: Any) {
        self.delegate?.didValueChanged(isOn: self.switchAcceptNotification.isOn, notifCode: self.code)
        
        if self.switchAcceptNotification.isOn {
            self.switchAcceptNotification.thumbTintColor = UIColor.cerulean
        } else {
            self.switchAcceptNotification.thumbTintColor = UIColor.brownGrey
        }
    }
}
