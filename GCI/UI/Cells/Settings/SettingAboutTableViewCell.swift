//
//  SettingAboutTableViewCell.swift
//  GCI
//
//  Created by Anthony Chollet on 10/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit
import WebKit
import ArcGIS

class SettingAboutTableViewCell: UITableViewCell {

    @IBOutlet weak var viewContentCell: UIView!
    @IBOutlet weak var lblAbout: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var webView: WKWebView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.setText()
        self.setInterface()
        self.setWebView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.viewContentCell.backgroundColor = selected ? UIColor.lightPeriwinkle : UIColor.white
    }
    
    func changeIconExtented(isExtented: Bool) {
        self.imgIcon.image = isExtented ? UIImage(named: "ico_circle_arrow_open_details_DI") : UIImage(named: "ico_circle_arrow_close_details_DI")
    }
    
    func setInterface() {
        self.viewContentCell.backgroundColor = UIColor.white
        self.contentView.backgroundColor = UIColor.lightPeriwinkle
        self.backgroundColor = UIColor.lightPeriwinkle
        self.viewContentCell.addShadow(offset: CGSize(width: 0, height: 1))
        self.viewContentCell.layer.cornerRadius = 5
        self.imgIcon.image = UIImage(named: "ico_circle_arrow_close_details_DI")
    }
    
    func setText() {
        self.lblAbout.font = UIFont.gciFontBold(16)
        self.lblAbout.textColor = UIColor.cerulean
        self.lblAbout.text = "settings_page_about".localized
    }
    
    func setWebView() {
        self.webView.backgroundColor = UIColor.clear
        self.webView.scrollView.isScrollEnabled = false
        
        let htmlFile = Bundle.main.path(forResource: "about", ofType: "html")
        var html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
        if let releaseVersionNumber = Bundle.main.releaseVersionNumber, let buildVersionNumber = Bundle.main.buildVersionNumber {
            html = html?.replacingOccurrences(of: "{APP_VERSION}", with: "settings_page_version".localized(arguments: releaseVersionNumber, String(buildVersionNumber)))
        } else {
            html = html?.replacingOccurrences(of: "{APP_VERSION}", with: "")
        }
        
        html = html?.replacingOccurrences(of: "{ARCGIS_VERSION}", with: AGSBundle()?.releaseVersionNumber ?? "")
        webView.loadHTMLString(html!, baseURL: nil)
    }
}
