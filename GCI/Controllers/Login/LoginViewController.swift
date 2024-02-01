//
//  LoginViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 25/04/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Alamofire
import AlamofireImage

class LoginViewController: AbstractViewController {

    @IBOutlet weak var loginField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordField: SkyFloatingLabelTextField!
    @IBOutlet weak var labelConnect: UILabel!
    @IBOutlet weak var btnConnect: GCIButton!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var labelVersion: UILabel!
    @IBOutlet weak var imgWave: UIImageView!
    
    let manager = LoginManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initText()
        initField()
        loginField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        self.textFieldDidChange(passwordField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setInterface()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaultManager.shared.isSessionExpired {
            displayAlert(withTitle: "", andMessage: "error_session_expired".localized)
            UserDefaultManager.shared.isSessionExpired = false
        }
    }
    
    func initText() {
        loginField.placeholderFont = UIFont.gciFontLight(16)
        loginField.titleFont = UIFont.gciFontLight(12)
        passwordField.placeholderFont = UIFont.gciFontLight(16)
        passwordField.titleFont = UIFont.gciFontLight(12)
        labelConnect.font = UIFont.gciFontBold(18)
        labelVersion.font = UIFont.gciFontLight(14)
        
        loginField.textColor = UIColor.white
        passwordField.textColor = UIColor.white
        loginField.placeholderColor = UIColor.white
        passwordField.placeholderColor = UIColor.white
        loginField.selectedTitleColor = UIColor.white
        passwordField.selectedTitleColor = UIColor.white
        loginField.titleColor = UIColor.white
        passwordField.titleColor = UIColor.white
        labelConnect.textColor = UIColor.white
        labelVersion.textColor = UIColor.white
        
        loginField.placeholder = "login_page_user_hint".localized
        loginField.title = "login_page_user_hint".localized
        loginField.selectedTitle = "login_page_user_hint".localized
        loginField.text = Constant.Prefilled.login
        passwordField.placeholder = "login_page_password_hint".localized
        passwordField.title = "login_page_password_hint".localized
        passwordField.selectedTitle = "login_page_password_hint".localized
        passwordField.text = Constant.Prefilled.password
        passwordField.isSecureTextEntry = true
        labelConnect.text = "login_page_title".localized
        btnConnect.setTitle("login_page_title".localized, for: .normal)
        if let releaseVersionNumber = Bundle.main.releaseVersionNumber, let buildVersionNumber = Bundle.main.buildVersionNumber {
            labelVersion.text = "settings_page_version".localized(arguments: releaseVersionNumber, String(buildVersionNumber))
        } else {
            labelVersion.text = ""
        }
    }

    override func refreshUI() {
        super.refreshUI()
        self.setInterface()
    }
    
    func setInterface() {
        self.view.backgroundColor = configuration?.mainColor ?? UIColor.white
        self.changeStatusBarColor(color: configuration?.mainColor ?? UIColor.cerulean)
        
        if let logoStringURL = configuration?.logoUrl, let imgLogoName = URL(string: logoStringURL)?.lastPathComponent {
            let path = FileManager.default.getDocumentsDirectoryURL().appendingPathComponent("\(imgLogoName).jpg")
            let fileStillExist = (try? path.checkResourceIsReachable()) ?? false
            if fileStillExist {
                self.imgLogo.image = UIImage(contentsOfFile: path.absoluteString.replacingOccurrences(of: "file:///", with: ""))
            } else {
                var header: HTTPHeaders = [:]
                if let key = KeychainManager.shared.licenceKey {
                    header[Constant.API.HeadersName.apiKey] = key
                }
                
                if let urlString = configuration?.logoUrl {
                    AF.request(urlString,
                                      method: .get,
                                      parameters: nil,
                                      encoding: URLEncoding.default,
                                      headers: header)
                    .validate()
                    .responseData { response in
                        if let imageData = response.data, let image = UIImage(data: imageData) {
                            _ = image.saveImageInDisk(withName: imgLogoName)
                            self.imgLogo.image = image
                        }
                    }
                }
            }
        }
        
        self.imgWave.layer.zPosition = 98
        self.imgLogo.layer.zPosition = 99
        
        self.loginField.tintColor = UIColor.white
        self.passwordField.tintColor = UIColor.white
    }
    
    @IBAction func btnConnectTouched(_ sender: Any) {
        if let login = loginField.text, let password = passwordField.text, !login.isEmpty, !password.isEmpty {

                self.displayLoader { (_) in
                    self.manager.authenticateUser(login: login, password: password, completionHandler: { (user, error) in
                        if user != nil {
                            let storyboard = UIStoryboard(name: "MainStoryboard", bundle: nil)
                            let startView = storyboard.instantiateViewController(withIdentifier: "startViewController")
                            self.hideLoader { _ in
                                self.navigationController?.pushViewController(startView)
                            }
                        } else {
                            self.hideLoader { _ in
                                
                                if let error = error {
                                    switch error {
                                    case .denied:
                                        self.displayAlert(withTitle: "error_general".localized, andMessage: "error_general".localized)
                                    case .noNetwork, .offlineNotAuthorized:
                                        self.displayAlert(withTitle: "error_reachability".localized, andMessage: "error_banner_internet".localized)
                                    case .notRightUsername:
                                        self.displayAlert(withTitle: "error_general".localized, andMessage: "error_login".localized)
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
extension LoginViewController {
    func initField() {
        loginField.lineHeight = 2
        loginField.lineColor = UIColor.white
        loginField.selectedLineColor = UIColor.white
        passwordField.lineHeight = 2
        passwordField.lineColor = UIColor.white
        passwordField.selectedLineColor = UIColor.white
    }
    
    @objc func textFieldDidChange(_ textfield: UITextField) {
        if let login = loginField.text, let password = passwordField.text, !login.isEmpty, !password.isEmpty {
            self.btnConnect.isEnabled = true
        } else {
            self.btnConnect.isEnabled = false
        }
    }
}
