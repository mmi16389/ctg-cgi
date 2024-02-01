//
//  SettingNotificationTableViewCell.swift
//  GCI
//
//  Created by Anthony Chollet on 10/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit
import UserNotifications

protocol SettingNotificationTableViewCellDelegate: class {
    func didValueChanged(isOn: Bool, notifCode: Constant.Notification.Code)
}

class SettingNotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var viewContentCell: UIView!
    @IBOutlet weak var lblNotifications: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var tableViewNotificationsType: UITableView!
    
    let manager = SettingsManager()
    weak var delegate: SettingNotificationTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setText()
        self.setInterface()
        self.configureTableView()
        
        self.tableViewNotificationsType.delegate = self
        self.tableViewNotificationsType.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.viewContentCell.backgroundColor = selected ? UIColor.lightPeriwinkle : UIColor.white
    }
    
    func changeIconExtented(isExtented: Bool) {
        self.imgIcon.image = isExtented ? UIImage(named: "ico_circle_arrow_open_details_DI") : UIImage(named: "ico_circle_arrow_close_details_DI")
        
        if isExtented {
            self.manager.getRemoteNotification { (result, error) in
                self.tableViewNotificationsType.reloadData()
            }
        }
    }
    
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            if newValue {
                self.viewContentCell.backgroundColor = UIColor.lightPeriwinkle
            } else {
                self.viewContentCell.backgroundColor = UIColor.white
            }
            super.isHighlighted = newValue
        }
    }
    
    func setInterface() {
        self.viewContentCell.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.lightPeriwinkle
        self.backgroundColor = UIColor.lightPeriwinkle
        self.viewContentCell.addShadow(offset: CGSize(width: 0, height: 1))
        self.viewContentCell.layer.cornerRadius = 5
    }
    
    func setText() {
        self.lblNotifications.font = UIFont.gciFontBold(16)
        self.lblNotifications.textColor = UIColor.cerulean
        self.lblNotifications.text = "settings_page_notification_push".localized
        self.imgIcon.image = UIImage(named: "ico_circle_arrow_close_details_DI")
    }
}

extension SettingNotificationTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func configureTableView() {
        self.tableViewNotificationsType.backgroundColor = UIColor.clear
        self.tableViewNotificationsType.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.tableViewNotificationsType.register(UINib(nibName: "SettingsNotificationsTypeTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsNotificationsCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsNotificationsCell") as! SettingsNotificationsTypeTableViewCell
        
        var listOfActiveCode = [Constant.Notification.Code]()
        if UIApplication.shared.isRegisteredForRemoteNotifications {
            listOfActiveCode = UserDefaultManager.shared.notificationPushPreference
        }
        
        switch indexPath.row {
        case 0:
            cell.initCell(notificationTypeName: "settings_page_notification_push_general".localized, isActive: listOfActiveCode.contains(Constant.Notification.Code.general), notifCode: Constant.Notification.Code.general)
        case 1:
            cell.initCell(notificationTypeName: "settings_page_notification_push_my_task".localized, isActive: listOfActiveCode.contains(Constant.Notification.Code.myTask), notifCode: Constant.Notification.Code.myTask)
        case 2:
            cell.initCell(notificationTypeName: "settings_page_notification_push_my_favorite".localized, isActive: listOfActiveCode.contains(Constant.Notification.Code.myFavorite), notifCode: Constant.Notification.Code.myFavorite)
        default:
            cell.initCell(notificationTypeName: "", isActive: false, notifCode: Constant.Notification.Code.general)
        }
        
        cell.delegate = self
        
        return cell
    }
}

extension SettingNotificationTableViewCell: SettingsNotificationsTypeTableViewCellDelegate {
    func didValueChanged(isOn: Bool, notifCode: Constant.Notification.Code) {
        self.delegate?.didValueChanged(isOn: isOn, notifCode: notifCode)
    }
}
