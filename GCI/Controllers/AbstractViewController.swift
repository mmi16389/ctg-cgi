//
//  AbstractViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 24/04/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class AbstractViewController: UIViewController {
    typealias DialogCompletion = (_ accept: Bool) -> Void

    var wizzardIndex: Int = 0
    var loader: LoaderViewController?
    let configuration = AppDynamicConfiguration.current()
    let settingsManager = SettingsManager()
    let licenceManager = LicenceManager()
    
    var scrollViewTopColoredView: UIView?
    var scrollViewTopColoredUIScrollView: UIScrollView?
    var loaderIsPlaying: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(onLicenceExpired(_:)), name: .licenceExpired, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onAppShouldLogout(_:)), name: .applicationShouldLogout, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onConfigurationChanded(_:)), name: .appConfigurationChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onPushNotifReceived(_:)), name: .pushNotificationReceived, object: nil)
        
        self.setNavBar()
        self.refreshUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        self.refreshUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func refreshUI() {
        self.changeStatusBarColor(color: configuration?.mainColor ?? UIColor.white)
    }
    
    func refreshConfig() {
        licenceManager.refresh { (config, error) in
            //
        }
    }
    
    func setNavBar() {
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = configuration?.mainColor ?? UIColor.red
        self.navigationController?.navigationBar.tintColor = UIColor.white

        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "ico_arrow_back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "ico_arrow_back")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override var title: String? {
        didSet {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
            view.backgroundColor = .clear
            
            let backbutton = UIButton(type: .custom)
            backbutton.setImage(UIImage(named: "ico_arrow_back"), for: .normal)
            backbutton.setTitle("", for: .normal)
            backbutton.setTitleColor(backbutton.tintColor, for: .normal)
            backbutton.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
            backbutton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            
            let titleLabel = UILabel()
            titleLabel.text = self.title
            titleLabel.font = UIFont.gciFontBold(16)
            titleLabel.textColor = .white
            titleLabel.sizeToFit()
            titleLabel.frame = CGRect(x: 56, y: 0, width: titleLabel.width, height: 44)
            
            view.addSubview(backbutton)
            view.addSubview(titleLabel)
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: view)
            
            super.title = ""
        }
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    func displayLoader(completionHandler: @escaping (_ loader: LoaderViewController?) -> Void = { _ in }) {
        DispatchQueue.main.async {
            if self.loaderIsPlaying {
                completionHandler(nil)
            } else {
                self.loader = LoaderViewController(isTransparent: false)
                if let loader = self.loader {
                    loader.modalPresentationStyle = .overFullScreen
                    self.present(loader, animated: true) {
                        self.loaderIsPlaying = true
                        completionHandler(loader)
                    }
                } else {
                    completionHandler(nil)
                }
            }
        }
    }
    
    func hideLoader(completionHandler: @escaping (_ loader: LoaderViewController?) -> Void = { _ in }) {
        DispatchQueue.main.async {
            if let loader = self.loader {
                loader.dismiss(animated: true) {
                    completionHandler(loader)
                    self.loader = nil
                    self.loaderIsPlaying = false
                }
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func displayAlert(withTitle title: String, andMessage message: String, andValidButtonText buttonAcceptText: String = "general_ok".localized, orCancelText buttonCancelTextOpt: String? = nil, andNerverAskCode dialogCodeOpt: DialogCode? = nil, completionHandler: DialogCompletion? = nil) {
        
        if let dialogCode = dialogCodeOpt, UserDefaultManager.shared.neverAskCodes.contains(dialogCode) {
            completionHandler?(true)
            return
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let actionOk = UIAlertAction(title: buttonAcceptText,
                                     style: .default,
                                     handler: { (actionSheetController) -> Void in
                                        completionHandler?(true)
        })
        
        let actionCancel: UIAlertAction?
        let actionNeverDisplayAgain: UIAlertAction?
        let usableButtonCancelTextOpt: String?
        
        if buttonCancelTextOpt == nil && dialogCodeOpt != nil {
            usableButtonCancelTextOpt = "general_cancel".localized
        } else {
            usableButtonCancelTextOpt = buttonCancelTextOpt
        }
        
        if let buttonCancelText = usableButtonCancelTextOpt {
            actionCancel = UIAlertAction(title: buttonCancelText,
                                             style: .cancel,
                                             handler: { (actionSheetController) -> Void in
                                                completionHandler?(false)
            })
        } else {
            actionCancel = nil
        }
        
        if dialogCodeOpt != nil {
            actionNeverDisplayAgain = UIAlertAction(title: buttonAcceptText + ", " + "general_do_not_display_anymore".localized,
                                                        style: .default,
                                                        handler: { (actionSheetController) -> Void in
                                                            if let dialogCode = dialogCodeOpt {
                                                                var previousNeverAskedCodes = UserDefaultManager.shared.neverAskCodes
                                                                previousNeverAskedCodes.append(dialogCode)
                                                                UserDefaultManager.shared.neverAskCodes = previousNeverAskedCodes
                                                            }
                                                            completionHandler?(true)
            })
        } else {
            actionNeverDisplayAgain = nil
        }
        
        if let actionNeverDisplayAgain = actionNeverDisplayAgain, let actionCancel = actionCancel {
            alertController.addAction(actionOk)
            alertController.addAction(actionCancel)
            alertController.addAction(actionNeverDisplayAgain)
        } else if let actionCancel = actionCancel {
            alertController.addAction(actionCancel)
            alertController.addAction(actionOk)
        } else {
            alertController.addAction(actionOk)
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - TableView With Header
    func setupTopColored(inScrollView scrollView: UIScrollView, withColor color: UIColor) {
        if scrollViewTopColoredView != nil {
            if scrollViewTopColoredView?.backgroundColor == color {
                return
            } else {
                scrollViewTopColoredView?.removeFromSuperview()
            }
        }
        scrollViewTopColoredUIScrollView = scrollView
        scrollViewTopColoredView = UIView()
        scrollViewTopColoredView?.backgroundColor = color
        self.view.addSubview(scrollViewTopColoredView!)
        self.view.sendSubviewToBack(scrollViewTopColoredView!)
    }
    
    // MARK: - Banner
    func showBanner(withTitle title: String, withColor color: UIColor, duration: Double = 3.0) {
        let font = UIFont.gciFontMedium(15)
        let widthOfText = self.view.frame.size.width-60
        let heightOfLabel = title.height(withConstrainedWidth: widthOfText, font: font)
        var heightOfBanner = heightOfLabel + 20 // 10 padding top and bottom
        
        var paddingBottomSafeArea = CGFloat(0)
        if self.tabBarController == nil || self.tabBarController?.tabBar.isHidden == true {
            if #available(iOS 11.0, *) {
                paddingBottomSafeArea += UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            }
            heightOfBanner += paddingBottomSafeArea // Just adding safe aread
        }
        
        let bannerView = UIView(frame: CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.size.width, height: heightOfBanner))
        bannerView.backgroundColor = color
        
        let closeButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 30, y: 10, width: 20, height: 20))
        closeButton.setImage(UIImage(named: "ico_cross_filter"), for: .normal)
        closeButton.addTarget(self, action: #selector(self.hideBanner(bannerView:)), for: .touchUpInside)
        bannerView.addSubview(closeButton)
        
        let label = UILabel(frame: CGRect(x: 30, y: 10, width: widthOfText, height: heightOfLabel))
        label.font = font
        label.textColor = UIColor.white
        label.textAlignment = .left
        label.numberOfLines = 0
        label.text = title
        bannerView.addSubview(label)
        
        self.view.addSubview(bannerView)
        
        UIView.animate(withDuration: 0.95, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
            bannerView.center = CGPoint(x: bannerView.center.x, y: bannerView.center.y-heightOfBanner)
        }, completion: { (_) in
            self.perform(#selector(self.hideBanner(bannerView:)), with: bannerView, afterDelay: duration)
        })
    }
    
    @objc func hideBanner(bannerView: UIView) {
        // can be done from button
        let toUseView: UIView
        if bannerView is UIButton, let superview = bannerView.superview {
            toUseView = superview
        } else {
            toUseView = bannerView
        }
        if toUseView.superview == nil {
            return
        }
        UIView.animate(withDuration: 0.99, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
            toUseView.center = CGPoint(x: toUseView.center.x, y: self.view.frame.height+200)
        }, completion: { (_) in
            toUseView.removeFromSuperview()
        })
    }
    
    func goToLogin(navController: UINavigationController) {
        UserDefaultManager.shared.isSessionExpired = true
        if self.loader != nil {
            self.hideLoader { _ in
                navController.popToRootViewController(animated: true)
            }
        } else {
            DispatchQueue.main.async {
                navController.popToRootViewController(animated: true)
            }
        }
    }
}

// MARK: - UIScrollViewDelegate
extension AbstractViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollViewTopColoredUIScrollView,
            let blueView = self.scrollViewTopColoredView {
            // Making the top blue view bigger
            if scrollView.contentOffset.y == 0 && blueView.frame.size.height > 0 {
                return
            }
            DispatchQueue.main.async {
                let frame =  CGRect(x: 0, y: scrollView.frame.origin.y, width: self.view.frame.width, height: -scrollView.contentOffset.y + 200)
                blueView.frame = frame
            }
        }
    }
}

extension AbstractViewController {
    @objc func onLicenceExpired(_ notification: Notification) {
        self.settingsManager.resetLicence {
            if let navController = self.tabBarController?.navigationController {
                self.goToLogin(navController: navController)
            }
        }
    }

    @objc func onAppShouldLogout(_ notification: Notification) {
        self.settingsManager.logout {
            DispatchQueue.main.async {
                if let navController = self.tabBarController?.navigationController {
                    self.goToLogin(navController: navController)
                } else if let navController = self.navigationController {
                    self.goToLogin(navController: navController)
                } else {
                    self.dismiss(animated: false, completion: nil)
                }
            }
        }
    }

    @objc func onConfigurationChanded(_ notification: Notification) {
        self.refreshConfig()
        self.refreshUI()
    }

    @objc func onPushNotifReceived(_ notification: Notification) {
        guard let title = UserDefaultManager.shared.notificationPushEventTitle else {
            return
        }
        
        if let taskID = UserDefaultManager.shared.notificationPushEventTaskId {
            HomeManager().getTask(byId: taskID) { (task, _) in
                self.displayAlert(withTitle: title, andMessage: UserDefaultManager.shared.notificationPushEventMessage ?? "", andValidButtonText: "general_ok".localized, orCancelText: "general_cancel".localized) { accept in
                    if accept {
                        let storyboard = UIStoryboard(name: "DetailTask", bundle: nil)
                        if let detailTaskViewController = storyboard.instantiateViewController(withIdentifier: "detailTaskViewController") as? DetailTaskViewController {
                            detailTaskViewController.selectedTask = task
                            UserDefaultManager.shared.removePushNotification()
                            
                            self.hideLoader { _ in
                                self.navigationController?.pushViewController(detailTaskViewController)
                            }
                        }
                    }
                }
                UserDefaultManager.shared.removePushNotification()
            }
        } else {
            self.hideLoader { _ in
                self.displayAlert(withTitle: title, andMessage: UserDefaultManager.shared.notificationPushEventMessage ?? "")
                UserDefaultManager.shared.removePushNotification()
            }
        }
    }
    
    override func overrideTraitCollection(forChild childViewController: UIViewController) -> UITraitCollection? {
        if DeviceType.isIpad && UIDevice.current.orientation.isPortrait || UIDevice.current.orientation.isFlat {
            return UITraitCollection(traitsFrom: [UITraitCollection(horizontalSizeClass: .compact), UITraitCollection(verticalSizeClass: .regular)])
        }
        return super.traitCollection
    }
}
