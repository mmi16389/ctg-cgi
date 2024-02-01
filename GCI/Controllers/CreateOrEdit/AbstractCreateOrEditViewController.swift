//
//  AbstractCreateOrEditViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 05/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class AbstractCreateOrEditViewController: AbstractViewController {

    var taskWizzard = TaskWizzard()
    var arrayOfController = [AbstractCreateOrEditViewController]()
    var isAccessible: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func exitWizzardWithSuccess() {
        guard let tabbar = self.tabBarController,
            let listOfTab = tabbar.viewControllers,
            let navController = listOfTab[0] as? UINavigationController,
            let homePage = navController.topViewController as? HomeViewController else {
                self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                return
        }
        self.navigationController?.popToViewController(self.arrayOfController[0], animated: false)
        self.arrayOfController[0].taskWizzard = TaskWizzard()
        tabbar.selectedIndex = 0
        homePage.showBanner(withTitle: "creation_banner_success".localized, withColor: .green)
    }

    func navigateToControllers(index: Int) {
        
        if let _ = arrayOfController[index] as? TaskLocationViewController {
            if !NetworkReachabilityHelper.isReachable() {
                self.showBanner(withTitle: "error_reachability".localized, withColor: .redPink)
                return
            }
        }
        
        if index < self.wizzardIndex {
            self.navigationController?.popToViewController(self.arrayOfController[index], animated: false)
        } else if index > self.wizzardIndex {
            for i in self.wizzardIndex+1..<index {
                self.arrayOfController[i].arrayOfController = self.arrayOfController
                self.arrayOfController[i].taskWizzard = self.taskWizzard
                self.navigationController?.viewControllers.append(self.arrayOfController[i])
            }
            self.arrayOfController[index].arrayOfController = self.arrayOfController
            self.arrayOfController[index].taskWizzard = self.taskWizzard
            self.navigationController?.pushViewController(self.arrayOfController[index], animated: false)
        }
    }
    
    func checkViewControllersAccessibility() {
        //page map
        let isStep2accessible = (taskWizzard.interventionType != nil || !taskWizzard.interventionComment.isEmpty) && taskWizzard.getDomain() != nil
        //page service
        var isStep3AfterMapAccessibleAndPatrimony = false
        var isStep3AfterMapAccessible = false
        if let domain = taskWizzard.getDomain() {
            isStep3AfterMapAccessibleAndPatrimony = taskWizzard.shouldDisplayMap && domain.usePatrimony && taskWizzard.getTaskPatrimony() != nil && taskWizzard.getLocation() != nil && isStep2accessible
            
            isStep3AfterMapAccessible = taskWizzard.shouldDisplayMap && !domain.usePatrimony && taskWizzard.getLocation() != nil && isStep2accessible
        }
        let isStep3WithoutMapAccessible = !taskWizzard.shouldDisplayMap && isStep2accessible
        //page comment
        let isStep4Accessible = (isStep3AfterMapAccessible || isStep3WithoutMapAccessible || isStep3AfterMapAccessibleAndPatrimony) && taskWizzard.service != nil
        //page resume
        let isStep5MapAccessible = isStep4Accessible
        
        for viewController in arrayOfController {
            switch viewController {
            case let viewController as InterventionTypeAndDomainViewController:
                viewController.isAccessible = true
                
            case viewController as TaskLocationViewController:
                if isStep2accessible {
                    viewController.isAccessible = true
                } else {
                    viewController.isAccessible = false
                }
                
            case viewController as ServiceTypeViewController:
                if isStep3AfterMapAccessible || isStep3WithoutMapAccessible || isStep3AfterMapAccessibleAndPatrimony {
                    viewController.isAccessible = true
                } else {
                    viewController.isAccessible = false
                }
                
            case viewController as MediaAndCommentViewController:
                if isStep4Accessible {
                    viewController.isAccessible = true
                } else {
                    viewController.isAccessible = false
                }
                
            case viewController as ResumeEditOrCreationViewController:
                if isStep5MapAccessible {
                    viewController.isAccessible = true
                } else {
                    viewController.isAccessible = false
                }
                
            default:
                break
            }
        }
    }
}
