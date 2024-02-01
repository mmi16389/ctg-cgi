//
//  ModalCommentaryViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 11/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class ModalCommentaryViewController: AbstractViewController {

    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var lbltitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnQuit: UIButton!
    @IBOutlet weak var btnValidate: GCIButton!
    @IBOutlet weak var commentaryTextView: GCITextview!
    
    typealias Action = (_ commentary: String) -> Void
    var titleLabel = ""
    var descriptionLabel = ""
    var placeholder = ""
    var validationButton = ""
    var prefilledCommentary = ""
    var actionOnValidate: Action?
    var charLimitation: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setInterface()
        self.setText()
    }
    
    func define(withTitle title: String, andLblDescription description: String, andTextViewPlaceholder placeholder: String, AndExistingCommentary prefilledText: String, andValidationButtonLabel buttonValidation: String, charLimitation: Int, completionHandler: @escaping (String) -> Void) {
        
        self.titleLabel = title
        self.descriptionLabel = description
        self.placeholder = placeholder
        self.validationButton = buttonValidation
        self.actionOnValidate = completionHandler
        self.prefilledCommentary = prefilledText
        self.charLimitation = charLimitation
    }
    
    func setText() {
        self.lbltitle.textColor = UIColor.white
        self.lbltitle.font = UIFont.gciFontBold(17)
        self.lbltitle.text = titleLabel
        
        self.lblDescription.textColor = UIColor.cerulean
        self.lblDescription.font = UIFont.gciFontBold(17)
        self.lblDescription.text = descriptionLabel
    
        self.btnValidate.setTitle(validationButton, for: .normal)
        
        self.commentaryTextView.placeholder = placeholder
        if !prefilledCommentary.isEmpty {
            self.commentaryTextView.text = prefilledCommentary
        } else {
            self.commentaryTextView.text = placeholder
        }
        self.commentaryTextView.defineLimitation(limitation: charLimitation)
    }

    func setInterface() {
        self.viewHeader.backgroundColor = configuration?.mainColor ?? UIColor.cerulean
        
        self.btnValidate.isEnabled = canBeValidated
        self.commentaryTextView.isUserInteractionEnabled = true
        self.commentaryTextView.isEditable = true
        
        self.commentaryTextView.delegate = self
    }
    
    private var canBeValidated: Bool {
        guard let _ = commentaryTextView.text else {
            return false
        }
        return true//!commentary.isEmpty
    }
    
    @IBAction func btnQuitTouched(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnValidateTouched(_ sender: Any) {
        guard let commentary = commentaryTextView.text else {
            return
        }
        
        self.dismiss(animated: true) {
            self.actionOnValidate?(commentary != self.placeholder ? commentary : "")
        }
    }
}

extension ModalCommentaryViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.btnValidate.isEnabled = self.canBeValidated
    }
}
