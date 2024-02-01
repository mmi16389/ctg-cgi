//
//  LoadingViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 21/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class ModalLoadingViewController: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.cerulean.withAlphaComponent(0.9)
        self.lblTitle.text = "\("popup_map_download_warning_title".localized) : \(0)%"
        self.progressBar.progressTintColor = AppDynamicConfiguration.current()?.mainColor ?? UIColor.green
    }

    func update(percent: Float) {
        self.lblTitle.text = "\("popup_map_download_warning_title".localized) : \(Int(percent * 100))%"
        self.progressBar.progress = percent
    }
}
