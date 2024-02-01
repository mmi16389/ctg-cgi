//
//  LoginViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 25/04/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class ActivationCodeViewController: AbstractViewController {

    @IBOutlet weak var labelInformation: UILabel!
    @IBOutlet weak var labelNoCode: UILabel!
    @IBOutlet weak var textfieldActivationCode: GCITextfield!
    @IBOutlet weak var btnValidate: GCIButton!
    
    let manager = LicenceManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textfieldActivationCode.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        initLabel()
        self.textFieldDidChange(textfieldActivationCode)
    }
    
    func initLabel() {
        labelInformation.font = UIFont.gciFontMedium(19)
        labelInformation.textColor = UIColor.charcoalGrey
        labelInformation.text = "activation_page_explanation".localized
        
        labelNoCode.font = UIFont.gciFontLight(15)
        labelNoCode.textColor = UIColor.cerulean
        labelNoCode.text = "activation_page_help".localized
        
        textfieldActivationCode.placeholder = "activation_page_hint".localized
        textfieldActivationCode.text = Constant.Prefilled.activationCode
        
        btnValidate.setTitle("task_action_validate".localized, for: .normal)
        btnValidate.isEnabled = false
    }
    
    @IBAction func btnValidateTouched(_ sender: Any) {
        if let code = self.textfieldActivationCode.text, !code.isEmpty {
            self.displayLoader { (_) in
                self.manager.test(license: code, completionHandler: { (AppDynamicConfiguration, error) in
                    if AppDynamicConfiguration != nil {
                        if let storyboard = self.storyboard {
                            let loginView = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                            self.navigationController?.pushViewController(loginView)
                            self.hideLoader()
                        }
                    } else {
                        self.hideLoader { (_) in
                            
                            if let error = error {
                                switch error {
                                case .denied:
                                    self.displayAlert(withTitle: "error_general".localized, andMessage: "error_general".localized)
                                case .noNetwork, .offlineNotAuthorized:
                                    self.displayAlert(withTitle: "error_reachability".localized, andMessage: "error_banner_internet".localized)
                                case .canceled:
                                    self.displayAlert(withTitle: "error_general".localized, andMessage: "error_general".localized)
                                case .notRightUsername:
                                    self.displayAlert(withTitle: "error_general".localized, andMessage: "error_licence_code".localized)
                                default:
                                    self.displayAlert(withTitle: "error_general".localized, andMessage: "error_network".localized)
                                }
                            }
                        }
                    }
                })
            }
        }
    }
}

// MARK: - TextField
extension ActivationCodeViewController {

    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            btnValidate.isEnabled = true
        } else {
            btnValidate.isEnabled = false
        }
    }
}
