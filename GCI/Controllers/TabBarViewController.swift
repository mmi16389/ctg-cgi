//
//  TabBarViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 07/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addViewControllers()
        
        self.tabBar.barStyle = .default
        self.tabBar.isTranslucent = false
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            
            tabBar.scrollEdgeAppearance = appearance
            tabBar.standardAppearance = appearance
        }
    }
    
    func addViewControllers() {
        var arrayOfVC = [UIViewController]()
        
        if let homeVC = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "homeViewController") as? HomeViewController {
            homeVC.tabBarItem = UITabBarItem(title: "menu_dashboard".localized,
                                             image: DeviceType.isIpad ? UIImage(named: "ico_dashboard_tab_bar_tablet") : UIImage(named: "ico_dashboard_tab_bar"),
                                             tag: 0)
            homeVC.tabBarItem.selectedImage = DeviceType.isIpad ? UIImage(named: "ico_dashboard_selected_tab_bar_tablet") : UIImage(named: "ico_dashboard_selected_tab_bar")
            arrayOfVC.append(homeVC)
        }
        
        if let currentStoryboard = self.storyboard {
            if let listDIVC = currentStoryboard.instantiateViewController(withIdentifier: "ListTaskViewController") as? ListTaskViewController {
                listDIVC.tabBarItem = UITabBarItem(title: "menu_tasks".localized,
                                                   image: DeviceType.isIpad ? UIImage(named: "ico_list_DI_tab_bar_tablet") : UIImage(named: "ico_list_DI_tab_bar"),
                                                   tag: 0)
                listDIVC.tabBarItem.selectedImage = DeviceType.isIpad ? UIImage(named: "ico_list_DI_selected_tab_bar_tablet") : UIImage(named: "ico_list_DI_selected_tab_bar")
                arrayOfVC.append(listDIVC)
            }
        }
        
        if let createDIVC = UIStoryboard.init(name: "CreateOrEditTaskStoryboard", bundle: nil).instantiateViewController(withIdentifier: "InterventionTypeAndDomainViewController") as? InterventionTypeAndDomainViewController {
            createDIVC.tabBarItem = UITabBarItem(title: "menu_create".localized,
                                                 image: DeviceType.isIpad ? UIImage(named: "ico_create_DI_tab_bar_tablet") : UIImage(named: "ico_create_DI_tab_bar"),
                                                 tag: 0)
            createDIVC.tabBarItem.selectedImage = DeviceType.isIpad ? UIImage(named: "ico_create_DI_selected_tab_bar_tablet") : UIImage(named: "ico_create_DI_selected_tab_bar")
            
            createDIVC.tabBarItem.isEnabled = User.currentUser()?.permissions.contains(.createtask) == true
            
            arrayOfVC.append(createDIVC)
        }
        
        if let currentStoryboard = self.storyboard {
            if let SettingsVC = currentStoryboard.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController {
                SettingsVC.tabBarItem = UITabBarItem(title: "menu_settings".localized,
                                                     image: DeviceType.isIpad ? UIImage(named: "ico_settings_tab_bar_tablet") : UIImage(named: "ico_settings_tab_bar"),
                                                     tag: 0)
                SettingsVC.tabBarItem.selectedImage = DeviceType.isIpad ? UIImage(named: "ico_settings_selected_tab_bar_tablet") : UIImage(named: "ico_settings_selected_tab_bar")
                arrayOfVC.append(SettingsVC)
            }
        }
        
        self.viewControllers = arrayOfVC.map({
            let navController = UINavigationController(rootViewController: $0)
            navController.isNavigationBarHidden = true
            return navController
        })
    }
}
