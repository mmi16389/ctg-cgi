//
//  ModalPDFViewerViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 29/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit
import WebKit

class ModalPDFViewerViewController: AbstractViewController {

    @IBOutlet weak var webview: WKWebView!
    @IBOutlet weak var btnQuit: UIButton!
    @IBOutlet weak var headerView: UIView!
    
    var pdfFileUrl: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.headerView.backgroundColor = configuration?.mainColor ?? UIColor.cerulean
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        do {
            let data = try Data(contentsOf: pdfFileUrl)
            webview.load(data, mimeType: "application/pdf", characterEncodingName: "", baseURL: pdfFileUrl.deletingLastPathComponent())
        } catch {
            print("---- error pdf read ----")
        }
    }

    @IBAction func btnCloseTouched(_ sender: Any) {
        UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        self.dismiss(animated: true)
    }

}
