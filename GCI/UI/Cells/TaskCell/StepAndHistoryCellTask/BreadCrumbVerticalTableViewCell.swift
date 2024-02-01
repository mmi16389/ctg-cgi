//
//  BreadCrumbVerticalTableViewCell.swift
//  GCI
//
//  Created by Anthony Chollet on 21/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

protocol BreadCrumbVerticalTableViewCellDelegate: class {
    func attachmentTouched(attachment: ViewableAttachment)
}

class BreadCrumbVerticalTableViewCell: UITableViewCell {

    @IBOutlet weak var viewStepId: UIView!
    @IBOutlet weak var lblStepNumber: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCreated: UILabel!
    @IBOutlet weak var viewVertical: UIView!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var imgIconAttachment: UIImageView!
    @IBOutlet weak var viewAttachment: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    weak var delegate: BreadCrumbVerticalTableViewCellDelegate?
    private var attachementImage: UIImage?
    private var manager = DetailTaskManager()
    private var currentStep: ViewableStep?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setInterface()
        self.setText()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setInterface() {
        self.viewStepId.setRounded()
        self.imgIconAttachment.layer.cornerRadius = 3
        
        self.viewStepId.backgroundColor = UIColor.tangerine
        self.viewVertical.backgroundColor = UIColor.tangerine
    }
    
    func setText() {
        self.lblTitle.font = UIFont.gciFontBold(16)
        self.lblStepNumber.font = UIFont.gciFontBold(16)
        self.lblCreated.font = UIFont.gciFontLight(15)
        self.lblComment.font = UIFont.gciFontRegular(16)
        
        self.lblStepNumber.textColor = UIColor.white
        self.lblTitle.textColor = UIColor.tangerine
        self.lblCreated.textColor = UIColor.charcoalGrey
        self.lblComment.textColor = UIColor.black
    }
    
    func define(withStep stepOpt: ViewableStep?, stepNumber: Int, isLastStep: Bool) {
        guard let step = stepOpt else {
            return
        }
        self.currentStep = stepOpt
        self.define(withTimeable: step, number: stepNumber, isLast: isLastStep)
        
        if let attachment = step.displayableAttachment {
            self.viewAttachment.isHidden = false
            if attachment.isPicture {
                self.loadImage(attachement: attachment)
            } else {
                self.indicator.isHidden = true
                self.imgIconAttachment.image = attachment.icon
            }
            
            self.viewAttachment.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.touchAttachment(_:)))
            self.viewAttachment.addGestureRecognizer(tap)
            
        }
    }
    
    func define(withHistory historyOpt: HistoryViewModel?, historyNumber: Int, isLastHistory: Bool) {
        
        self.currentStep = nil
        guard let history = historyOpt else {
            return
        }
        
        self.define(withTimeable: history, number: historyNumber, isLast: isLastHistory)
    }
    
    private func define(withTimeable timeable: TimeableViewModel, number: Int, isLast: Bool) {
        self.lblStepNumber.text = "\(number)"
        self.lblTitle.text = timeable.title
        self.lblCreated.text = "steps_short_descriptin".localized(arguments: timeable.userFullName, timeable.date.toDateString(style: .short), timeable.date.toTimeString(style: .medium))
        self.lblComment.text = timeable.description
        
        self.viewAttachment.isHidden = true
        
        if isLast {
            self.viewVertical.backgroundColor = UIColor.clear
        } else {
            self.viewVertical.backgroundColor = UIColor.tangerine
        }
        
    }
    
    func loadImage(attachement: ViewableAttachment) {
        indicator.isHidden = false
        indicator.startAnimating()
        self.imgIconAttachment.image = nil
        manager.loadImageFile(fromAttachment: attachement) { (image, error) in
            if let image = image {
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    self.indicator.isHidden = true
                    self.imgIconAttachment.isHidden = false
                    self.attachementImage = image
                    self.imgIconAttachment.image = image
                }
            } else {
                self.imgIconAttachment.isHidden = true
            }
        }
    }
    
    @objc func touchAttachment(_ sender: UITapGestureRecognizer? = nil) {
        self.viewAttachment.backgroundColor = UIColor.lightPeriwinkle
        if let attachment = self.currentStep?.displayableAttachment {
            self.delegate?.attachmentTouched(attachment: attachment)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.viewAttachment.backgroundColor = UIColor.clear
            }
        }
    }
}
