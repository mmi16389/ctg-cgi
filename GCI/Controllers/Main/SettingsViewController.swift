//
//  SettingsViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 07/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit
import ArcGIS

struct SettingsElements {
    typealias Action = () -> Void
    let title: String
    let icon: UIImage
    let actionOnTouch: Action?
}

class SettingsViewController: AbstractViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var tableViewSettings: UITableView!
    
    var expandedIndexPath = IndexPath()
    let manager = SettingsManager()
    var settings = [SettingsElements]()
    let offlineMapHelper = ArcgisMapOfflineHelper()
    var loaderMapView: ModalLoadingViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setInterface()
        self.setText()
        self.configureTableview()
        self.setSettingsElements()
        self.tableViewSettings.dataSource = self
        self.tableViewSettings.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Constant.haveToRefresh = false
    }
    
    func setInterface() {
        self.view.backgroundColor = configuration?.mainColor ?? UIColor.cerulean
        self.viewHeader.backgroundColor = configuration?.mainColor ?? UIColor.cerulean
    }
    
    func setText() {
        self.lblTitle.font = UIFont.gciFontBold(16)
        self.lblTitle.textColor = UIColor.white
        
        self.lblTitle.text = "menu_settings".localized
    }

    func setSettingsElements() {
        settings.append(SettingsElements(
            title: "settings_page_synchronise".localized,
            icon: UIImage(named: "ico_synchro_settings")!,
            actionOnTouch: {
                self.synchroniseTouched()
        }))
        
        settings.append(SettingsElements(
            title: "settings_page_logout".localized,
            icon: UIImage(named: "ico_logout_settings")!,
            actionOnTouch: {
                self.logOutTouched()
        }))
        
        settings.append(SettingsElements(
            title: "settings_page_reset_licence".localized,
            icon: UIImage(named: "ico_code_reset_settings")!,
            actionOnTouch: {
                self.resetLicenceTouched()
        }))
        
        settings.append(SettingsElements(
            title: "settings_download_map".localized,
            icon: UIImage(named: "ico_download_map_offline")!,
            actionOnTouch: {
                self.downloadMapTouched()
        }))
    }
}

//Mark :- Setting Touched
extension SettingsViewController {
    func synchroniseTouched() {
        self.displayLoader { _ in
            self.settingsManager.lauchSync(completionHandler: { (success) in
                self.hideLoader { _ in
                    switch success {
                    case .success:
                        break
                    case .errorUpload(let errorMessage):
                        self.showBanner(withTitle: errorMessage, withColor: .redPink)
                    case .errorDownload:
                        self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                    case .noInternet:
                        self.showBanner(withTitle: "error_reachability".localized, withColor: .redPink)
                    }
                }
            })
        }
    }
    
    func logOutTouched() {
        self.displayAlert(withTitle: "", andMessage: "settings_page_confirmation_logout".localized, andValidButtonText: "general_ok".localized, orCancelText: "general_cancel".localized) { (isOk) in
            guard isOk else {
                return
            }
            
            self.displayLoader()
            self.manager.logout {
                if let navController = self.tabBarController?.navigationController {
                    navController.popToRootViewController(animated: true)
                    self.hideLoader()
                }
            }
        }
    }
    
    func resetLicenceTouched() {
        self.displayAlert(withTitle: "", andMessage: "settings_page_confirmation_reset".localized, andValidButtonText: "general_ok".localized, orCancelText: "general_cancel".localized) { (isOk) in
            guard isOk else {
                return
            }
            
            self.displayLoader()
            self.manager.resetLicence {
                if let navController = self.tabBarController?.navigationController {
                    navController.popToRootViewController(animated: true)
                    self.hideLoader()
                }
            }
        }
    }
    
    func downloadMapTouched() {
        self.displayLoader()
        offlineMapHelper.prepareDownloadMap { (success, message, exportTileCacheTask, exportTileCacheParameter, error) in
            if success {
                self.hideLoader { _ in
                    self.displayAlert(withTitle: "", andMessage: message, andValidButtonText: "general_ok".localized, orCancelText: "general_cancel".localized, completionHandler: { (accept) in
                        if accept {
                            self.offlineMapHelper.delegate = self
                            if let exportTileCacheTask = exportTileCacheTask, let exportTileCacheParameter = exportTileCacheParameter {
                                
                                guard let modalView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalLoadingViewController") as? ModalLoadingViewController else {
                                    return
                                }
                                modalView.modalPresentationStyle = .fullScreen
                                self.loaderMapView = modalView
                                DispatchQueue.main.async {
                                    self.present(self.loaderMapView!, animated: true, completion: nil)
                                }
                                UIApplication.shared.isIdleTimerDisabled = true
                                self.offlineMapHelper.downloadMap(exportTileCacheTask: exportTileCacheTask, exportParameter: exportTileCacheParameter)
                            }
                        }
                    })
                }
            } else {
                self.hideLoader { _ in
                    if let error = error {
                        switch error {
                        case .noNetwork:
                            self.showBanner(withTitle: "error_reachability".localized, withColor: .redPink)
                        default:
                            self.showBanner(withTitle: "map_download_fail".localized, withColor: .redPink)
                        }
                    } else {
                        self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                    }
                }
            }
        }
    }
}

extension SettingsViewController: ArcgisMapOfflineHelperDelegate {
    func getDownloadProgress(percent: Double) {
        self.loaderMapView?.update(percent: Float(percent))
    }
    
    func failToLoadMap(error: Error?) {
        self.loaderMapView!.dismiss(animated: true) {
            self.showBanner(withTitle: "map_download_fail".localized, withColor: .redPink)
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    func successToLoadMap() {
        self.loaderMapView!.dismiss(animated: true) {
            self.showBanner(withTitle: "map_download_success".localized, withColor: .green)
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
   
    func configureTableview() {
        self.tableViewSettings.backgroundColor = UIColor.lightPeriwinkle
        self.tableViewSettings.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.tableViewSettings.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsCell")
        self.tableViewSettings.register(UINib(nibName: "SettingNotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingNotificationCell")
        self.tableViewSettings.register(UINib(nibName: "SettingAboutTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingAboutCell")
        self.tableViewSettings.register(UINib(nibName: "CustomTextTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomTextCell")
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return settings.count + 1
        case 1:
            return 2 + 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 { // nom de l'utilisateur
                let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTextCell") as! CustomTextTableViewCell
                cell.setText(withText: User.currentUser()?.fullname ?? "", withFont: UIFont.gciFontBold(20), withAlignment: .center)
                return cell
            } else { // settings classique
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell") as! SettingsTableViewCell
                let setting = settings[indexPath.row - 1]
                cell.initWithSettings(name: setting.title, icon: setting.icon)
                
                return cell
            }
        } else {
            switch indexPath.row { //settings expendables
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingNotificationCell") as! SettingNotificationTableViewCell
                cell.delegate = self
                if expandedIndexPath == indexPath {
                    cell.changeIconExtented(isExtented: true)
                } else {
                    cell.changeIconExtented(isExtented: false)
                }
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingAboutCell") as! SettingAboutTableViewCell
                if expandedIndexPath == indexPath {
                    cell.changeIconExtented(isExtented: true)
                } else {
                    cell.changeIconExtented(isExtented: false)
                }
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTextCell") as! CustomTextTableViewCell
                if let releaseVersionNumber = Bundle.main.releaseVersionNumber, let buildVersionNumber = Bundle.main.buildVersionNumber {
                    cell.setText(withText: "settings_page_version".localized(arguments: releaseVersionNumber, String(buildVersionNumber)), withFont: UIFont.gciFontRegular(10), withAlignment: .right)
                }
                return cell
            default:
                return UITableViewCell()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //Sections settings & expandables cell
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == expandedIndexPath {
            if let cell: SettingAboutTableViewCell = tableView.cellForRow(at: indexPath) as? SettingAboutTableViewCell {
                return cell.webView.scrollView.contentSize.height + 70
            } else {
                return 270
            }
        }
        
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableViewSettings.width, height: 40))
        view.backgroundColor = UIColor.lightPeriwinkle
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 40
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        if let cell = tableView.cellForRow(at: indexPath) as? SettingNotificationTableViewCell {
            if indexPath != expandedIndexPath {
                expandedIndexPath = indexPath
            } else {
                expandedIndexPath = IndexPath()
            }
            
        } else if let cell = tableView.cellForRow(at: indexPath) as? SettingAboutTableViewCell {
            if indexPath != expandedIndexPath {
                expandedIndexPath = indexPath
            } else {
                expandedIndexPath = IndexPath()
            }
        } else {
            expandedIndexPath = IndexPath()
            if indexPath.section == 0 {
                if indexPath.row > 0 {
                    let setting = settings[indexPath.row - 1]
                    setting.actionOnTouch?()
                }
            }
        }
        
        tableView.endUpdates()
//        tableView.reloadRows(at: [indexPath], with: .none)
        tableView.reloadSections(IndexSet(integer: 1), with: .none)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.tableViewSettings.deselectRow(at: indexPath, animated: true)
        })
    }
}

extension SettingsViewController: SettingNotificationTableViewCellDelegate {
    func didValueChanged(isOn: Bool, notifCode: Constant.Notification.Code) {
        if UIApplication.shared.isRegisteredForRemoteNotifications {
            var currentNotif = UserDefaultManager.shared.notificationPushPreference
            if isOn && !currentNotif.contains(notifCode) {
                currentNotif.append(notifCode)
            } else if !isOn, let index = currentNotif.firstIndex(of: notifCode) {
                currentNotif.remove(at: index)
            }
            manager.setRemoteNotification(notifications: currentNotif) { (success, error) in
                if let error = error {
                    switch error {
                    case .noNetwork, .offlineNotAuthorized:
                        self.showBanner(withTitle: "error_reachability".localized, withColor: .redPink)
                    default:
                        self.displayAlert(withTitle: "error_general".localized, andMessage: "error_network".localized)
                    }
                }
                self.tableViewSettings.reloadData()
            }
        } else {
            //popup no remote
            self.displayAlert(withTitle: "", andMessage: "TBL vous devez accepter les notifications dans les réglages de l'app", andValidButtonText: "TBL réglages", orCancelText: "general_cancel".localized) { (accept) in
                self.tableViewSettings.reloadData()
                if accept {
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
                        UIApplication.shared.canOpenURL(settingsURL) else {
                            return
                    }
                    UIApplication.shared.open(settingsURL)
                }
            }
        }
    }
}
