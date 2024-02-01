//
//  EntryPointViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 06/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class EntryPointViewController: AbstractViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.launchStartViewController()
    }
    
    func launchStartViewController() {
        
        var pageToCall = ""
        var StoryboardName = ""
        
        if AppDynamicConfiguration.current() == nil {
            pageToCall = "LicenceViewController"
            StoryboardName = "Login"
        } else if User.currentUser() == nil {
            pageToCall = "LoginViewController"
            StoryboardName = "Login"
        } else {
            pageToCall = "startViewController"
            StoryboardName = "MainStoryboard"
        }
        
        let storyboard = UIStoryboard(name: StoryboardName, bundle: nil)
        let pageToDisplay = storyboard.instantiateViewController(withIdentifier: pageToCall)
        self.navigationController?.pushViewController(pageToDisplay)
    }

}
