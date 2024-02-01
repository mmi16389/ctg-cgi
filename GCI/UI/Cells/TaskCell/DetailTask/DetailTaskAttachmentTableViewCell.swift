//
//  DetailTaskImageTableViewCell.swift
//  GCI
//
//  Created by Anthony Chollet on 21/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class DetailTaskAttachmentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var imgPdf: UIImageView!
    @IBOutlet weak var constraitLeadingPhoto: NSLayoutConstraint!
    @IBOutlet weak var constraintLeadingPDF: NSLayoutConstraint!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var attachement: ViewableAttachment!
    
    var attachementImage: UIImage?
    var manager = DetailTaskManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.contentView.backgroundColor = UIColor.lightPeriwinkle
        } else {
            self.contentView.backgroundColor = UIColor.white
        }
    }
    
    func initCell(attachement: ViewableAttachment?, isTitlePadding isPadding: Bool = true, forceReloadImage: Bool = false) {
        if let attachement = attachement {
            self.attachement = attachement
            if attachement.isPicture { //Image
                self.imgPdf.isHidden = true
                self.imgPhoto.isHidden = false
                if let image = attachementImage, !forceReloadImage {
                    self.imgPhoto.image = image
                } else {
                    self.loadImage(attachement: attachement)
                }
            } else { //PDF
                self.indicator.isHidden = true
                self.imgPdf.isHidden = false
                self.imgPhoto.isHidden = true
                self.imgPdf.image = attachement.icon
                
            }
            
            if isPadding {
                self.constraintLeadingPDF.constant = 58
                self.constraitLeadingPhoto.constant = 58
            } else {
                self.constraintLeadingPDF.constant = 34
                self.constraitLeadingPhoto.constant = 34
            }
            
            self.layoutIfNeeded()
        }
    }
    
    func loadImage(attachement: ViewableAttachment) {
        indicator.isHidden = false
        indicator.startAnimating()
        
        if FileManager.default.fileExists(atPath: attachement.fileUrl.path) {
            let image = UIImage(contentsOfFile: attachement.fileUrl.path)
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.indicator.isHidden = true
                self.attachementImage = image
                self.imgPhoto.image = image
                self.imgPhoto.isHidden = false
            }
        } else {
            manager.loadImageFile(fromAttachment: attachement) { (image, error) in
                if let image = image {
                    DispatchQueue.main.async {
                        self.indicator.stopAnimating()
                        self.indicator.isHidden = true
                        self.attachementImage = image
                        self.imgPhoto.image = image
                        self.imgPhoto.isHidden = false
                    }
                } else {
                    self.imgPhoto.isHidden = true
                    self.imgPhoto.backgroundColor = UIColor.clear
                }
            }
        }
    }
    
}
