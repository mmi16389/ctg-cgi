//
//  ModalExplationFieldsViewController.swift
//  GCI
//
//  Created by Florian ALONSO on 6/7/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

enum PrefilledType {
    
}

class ModalExplanationFieldsViewController: AbstractViewController {
    
    enum ExplanationType {
        case rejectOrCancel
        case rejectAndTransfer
    }
    
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var lbltitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnQuit: UIButton!
    @IBOutlet weak var btnValidate: GCIButton!
    @IBOutlet weak var btnPrefilledSelection: GCIButton!
    @IBOutlet weak var fieldLabel: UILabel!
    @IBOutlet weak var titleTextField: GCITextfield!
    @IBOutlet weak var descriptionTextView: GCITextview!
    @IBOutlet weak var serviceTextField: GCITextfield!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var serviceLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var serviceLabelTop: NSLayoutConstraint!
    @IBOutlet weak var serviceLabelBottom: NSLayoutConstraint!
    @IBOutlet weak var serviceTextFieldHeight: NSLayoutConstraint!
    
    var serviceList = [ServiceViewModel]()
    var selectedService: ServiceViewModel?
    var type: ExplanationType = .rejectOrCancel
    
    private var canBeValidated: Bool {
        guard let title = titleTextField.text else {
            return false
        }
        return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && (type == .rejectOrCancel || selectedService != nil)
    }
    
    typealias Action = (_ title: String, _ description: String, _ service: ServiceViewModel?) -> Void
    var actionOnValidate: Action?
    var pageTitleText = ""
    var pageDescriptionText = ""
    var pageValidationText = ""
    var prefilledValues = [PrefilledMessageViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setInterface()
    }
    
    func setInterface() {
        self.viewHeader.backgroundColor = configuration?.mainColor ?? UIColor.cerulean
        
        if type == .rejectOrCancel {
            serviceLabelTop.constant = 0
            serviceLabelHeight.constant = 0
            serviceLabelBottom.constant = 0
            serviceTextFieldHeight.constant = 0
        }
        
        self.lbltitle.textColor = UIColor.white
        self.lbltitle.font = UIFont.gciFontBold(17)
        self.lbltitle.text = pageTitleText
        
        self.lblDescription.textColor = UIColor.white
        self.lblDescription.font = UIFont.gciFontRegular(14)
        self.lblDescription.text = pageDescriptionText
        
        self.fieldLabel.textColor = UIColor.cerulean
        self.fieldLabel.font = UIFont.gciFontBold(17)
        self.fieldLabel.text = "reject_page_field_title".localized
        
        self.serviceLabel.textColor = UIColor.cerulean
        self.serviceLabel.font = UIFont.gciFontBold(17)
        self.serviceLabel.text = "transfer_to_service_label".localized
        
        self.serviceTextField.placeholder = "transfer_to_service_placeholder".localized
        self.serviceTextField.isEnabled = true
        self.serviceTextField.isUserInteractionEnabled = true
        self.serviceTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didSelectServiceTextField)))
        
        self.btnValidate.setTitle(pageValidationText, for: .normal)
        self.btnValidate.isEnabled = canBeValidated
        
        self.btnPrefilledSelection.setTitle("steps_page_select_prefilled".localized, for: .normal)
        self.btnPrefilledSelection.isEnabled = !prefilledValues.isEmpty
        
        self.titleTextField.placeholder = "reject_page_title_hint".localized
        self.titleTextField.text = ""
        self.titleTextField.defineLimitation(limitation: 30)
        
        self.descriptionTextView.isUserInteractionEnabled = true
        self.descriptionTextView.isEditable = true
        self.descriptionTextView.placeholder = "reject_page_description_hint".localized
        self.descriptionTextView.text = "reject_page_description_hint".localized
        self.descriptionTextView.defineLimitation(limitation: 500)
    }
    
    @objc func didSelectServiceTextField() {
        if let selectView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalSelectListViewController") as? ModalSelectListViewController {
            selectView.modalPresentationStyle = .fullScreen
            selectView.initModal(withTitle: "service_transfert_page_title".localized,
                                 buttonText: "general_valdiate".localized,
                                 listOfChoice: serviceList,
                                 searchPlaceHolder: "creation_search_hint_service".localized,
                                 isMultiSelection: false) { (selectedIndexes) in
                                    guard let index = selectedIndexes.first else {
                                        return
                                    }
                                    self.selectedService = self.serviceList[index]
                                    self.serviceTextField.text = self.serviceList[index].name
                                    self.btnValidate.isEnabled = self.canBeValidated
            }
            DispatchQueue.main.async {
                self.present(selectView, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func btnQuitTouched(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnValidateTouched(_ sender: Any) {
        guard let title = titleTextField.text else {
            return
        }
        
        self.dismiss(animated: true) {
            let content = self.descriptionTextView.text ?? ""
            let description = content != self.descriptionTextView.placeholder ? content : ""
            self.actionOnValidate?(title, description, self.selectedService)
        }
    }
    
    @IBAction func didTapOnPrefilledSelection(_ sender: Any) {
        guard let selectView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalSelectListViewController") as? ModalSelectListViewController else {
            return
        }
        
        self.titleTextField.resignFirstResponder()
        self.descriptionTextView.resignFirstResponder()
        selectView.modalPresentationStyle = .fullScreen
        selectView.initModal(withTitle: "reject_page_reason".localized,
                             buttonText: "general_valdiate".localized,
                             listOfChoice: prefilledValues,
                             searchPlaceHolder: "creation_search_hint_motif".localized,
                             isMultiSelection: false) { (selectedIndexes) in
                                guard let index = selectedIndexes.first else {
                                    return
                                }
                                
                                let message = self.prefilledValues[index]
                                self.titleTextField.text = message.title
                                self.descriptionTextView.text = message.content
                                self.btnValidate.isEnabled = self.canBeValidated
        }
        DispatchQueue.main.async {
            self.present(selectView, animated: true, completion: nil)
        }
    }
    
    @IBAction func titleDidChange(_ sender: Any) {
        self.btnValidate.isEnabled = canBeValidated
    }
    
}
