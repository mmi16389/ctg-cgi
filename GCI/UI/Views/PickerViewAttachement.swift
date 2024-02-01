//
//  PickerViewAttachement.swift
//  GCI
//
//  Created by Anthony Chollet on 13/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class PickerViewAttachement: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var lbltitle: UILabel!
    @IBOutlet weak var imgIconPicker: UIImageView!
    @IBOutlet weak var viewSelectedContent: UIView!
    @IBOutlet weak var imgSelectedContent: UIImageView!
    @IBOutlet weak var btnDeleteSelectedContent: UIButton!
    
    typealias Action = () -> Void
    var actionpickerOnTouch: Action?
    var actionDeleteOnTouch: Action?
    
    var title = ""
    var iconPicker: UIImage?
    var imageOfSelectedContent: UIImage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
            self.commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("PickerViewAttachement", owner: self, options: nil)
        guard let content = contentView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
    }
    
    func setInterface() {
        self.addShadow(radius: 1, offset: CGSize(width: 0, height: 1))
        self.layer.cornerRadius = 4
        
        self.lbltitle.font = UIFont.gciFontMedium(16)
        self.lbltitle.textColor = UIColor.cerulean
        
        self.lbltitle.text = title
        self.imgIconPicker.image = iconPicker
        
        if let imageOfSelectedContent = imageOfSelectedContent {
            self.viewSelectedContent.isHidden = false
            self.imgSelectedContent.image = imageOfSelectedContent
        } else {
            self.viewSelectedContent.isHidden = true
            self.imgSelectedContent.image = nil
        }
        
        self.btnDeleteSelectedContent.setRounded()
    }
    
    func define(WithIcon icon: UIImage, title: String, imageOfSelectedContent: UIImage? = nil) {
        self.title = title
        self.iconPicker = icon
        self.imageOfSelectedContent = imageOfSelectedContent
        
        self.setInterface()
    }
    
    @IBAction func btnDeleteContentTouched(_ sender: Any) {
        self.actionDeleteOnTouch?()
        self.viewSelectedContent.isHidden = true
        self.imgSelectedContent.image = nil
    }
    
    @IBAction func pickerTouched(_ sender: Any) {
        self.contentView.backgroundColor = UIColor.lightPeriwinkle
        if self.viewSelectedContent.isHidden == true {
            self.actionpickerOnTouch?()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.contentView.backgroundColor = UIColor.white
        })
    }

}
