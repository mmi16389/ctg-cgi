//
//  HomeViewControllerIpadExtension.swift
//  GCI
//
//  Created by Anthony Chollet on 03/07/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage

extension HomeViewController {
    
    func setInterfaceForiPad() {
        self.viewHeader.backgroundColor = AppDynamicConfiguration.current()?.mainColor ?? UIColor.cerulean
        
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
                                      headers: header).validate().responseData { response in
                                        if let imageData = response.data, let image = UIImage(data: imageData) {
                                            _ = image.saveImageInDisk(withName: imgLogoName)
                                            self.imgLogo.image = image
                                        }
                    }
                }
            }
        }
    }
    
    func setTextForiPad() {
        self.lblTitle.font = UIFont.gciFontBold(19)
        self.lblLastSynch.font = UIFont.gciFontRegular(12)
        
        self.lblTitle.textColor = UIColor.white
        self.lblLastSynch.textColor = UIColor.white
        
        self.lblTitle.text = "dashboard_title".localized
        self.refreshDateLastSynch()
    }
    
    func refreshDateLastSynch() {
        if let dateLastRequest = UserDefaultManager.shared.lastTaskListRequestDate {
            self.lblLastSynch.text = "dashboard_last_sync".localized(arguments: dateLastRequest.toDateString(style: .short), dateLastRequest.toTimeString(style: .medium))
        } else {
            self.lblLastSynch.text = ""
        }
    }
    
    @objc func iPadCanRotate() {}
    
    @objc func rotated() {
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight, .portrait:
            DispatchQueue.main.async {
                self.currentOrientation = UIDevice.current.orientation
                self.changeStatusBarColor(color: self.configuration?.mainColor ?? UIColor.white)
                self.tableViewContent.reloadData()
                self.selectedCategoryCell = UICollectionViewCell()
                self.collectionViewCategories.reloadData()
                self.view.layoutIfNeeded()
            }
        default:
            break
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func configureCollectionView() {
        self.collectionViewCategories.backgroundColor = UIColor.lightPeriwinkle
        
        self.collectionViewCategories.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.collectionViewCategories.register(UINib(nibName: "HomeTaskTypeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeTaskTypeCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoriesVisible.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeTaskTypeCell", for: indexPath) as! HomeTaskTypeCollectionViewCell
        if let user = User.currentUser() {
            
            var isSelected = false
            if selectedCategory == categoriesVisible[indexPath.row] {
                self.selectedCategoryCell = cell
                self.collectionViewCategories.selectItem(at: indexPath, animated: false, scrollPosition: .top)
                isSelected = true
            } else {
                isSelected = false
            }
            
            let taskListFiltered = tasksAllFilter.filter({ $0.category(forUser: user) == categoriesVisible[indexPath.row] })
            cell.setCell(withCategory: categoriesVisible[indexPath.row], numberOfTask: taskListFiltered.count, numberOfTaskToday: taskListFiltered.updatedTodayCount, isSelectCategory: isSelected)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionViewCategories.width - 80, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 31.0, left: 40.0, bottom: 5.0, right: 40.0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 24
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            if selectedCategoryCell == cell {
                collectionView.deselectItem(at: indexPath, animated: true)
                selectedCategoryCell = UICollectionViewCell()
                selectCategoryFromCollectionView(category: nil)
            } else {
                if let selectedCell = selectedCategoryCell as? HomeTaskTypeCollectionViewCell, let index = self.collectionViewCategories.indexPath(for: selectedCell) {
                    self.collectionViewCategories.deselectItem(at: index, animated: true)
                }
                
                selectedCategoryCell = cell
                selectCategoryFromCollectionView(category: categoriesVisible[indexPath.row])
            }
        }
    }
    
    func selectCategoryFromCollectionView(category: TaskCategory?) {
        self.selectedCategory = category
        self.filterTaskToDisplay()
        DispatchQueue.main.async {
            UIView.performWithoutAnimation {
                self.tableViewContent.reloadData()
            }
        }
    }
}

extension HomeViewController: TaskActionnableDelegate {
    func askForEditStepInfo(withCompletion completion: @escaping (ViewableStep, String, String, Date, URL?, AttachmentViewModel?) -> Void) {
//        DispatchQueue.main.async {
////            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
//            self.refreshUI()
//        }
        self.hideLoader { _ in
            if let user = User.currentUser(),
                let listOfChoice = self.selectedTask?.displayableAndEditableSteps(forUser: user),
                let selectView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalSelectListViewController") as? ModalSelectListViewController {
                selectView.modalPresentationStyle = .fullScreen
                selectView.initModal(withTitle: "task_action_step_edit".localized,
                                     buttonText: "task_action_edit".localized,
                                     listOfChoice: listOfChoice,
                                     isMultiSelection: false,
                                     isShowIndex: false) { (selectedIndexes) in
                                        guard let index = selectedIndexes.first else {
                                            return
                                        }
                                        
                                        if let selectView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalStepViewController") as? ModalStepViewController {
                                            selectView.modalPresentationStyle = .fullScreen
                                            selectView.initModal(editStep: listOfChoice[index], actionOnValidate: { (title, comment, date, url, oldAttachment) in
                                                self.displayLoader { (_) in
                                                    completion(listOfChoice[index], title, comment, date, url, oldAttachment)
                                                }
                                            })
                                            
                                            DispatchQueue.main.async {
                                                self.present(selectView, animated: true, completion: nil)
                                            }
                                        }
                }
                DispatchQueue.main.async {
                    self.present(selectView, animated: true, completion: nil)
                }
            }
        }
    }
    
    func askForStartOrEndStep(withCompletion completion: @escaping (Date) -> Void) {
        self.hideLoader { _ in
//            DispatchQueue.main.async {
////                UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
//                self.refreshUI()
//            }
            if let selectView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalDatePickerViewController") as? ModalDatePickerViewController {
                selectView.modalPresentationStyle = .fullScreen
                selectView.initModal(actionOnValidate: { (date) in
                    self.displayLoader { (_) in
                        completion(date)
                    }
                })
                
                DispatchQueue.main.async {
                    self.present(selectView, animated: true, completion: nil)
                }
            }
        }
    }
    
    func askForAddStepInfo(withCompletion completion: @escaping (String, String, Date, URL?) -> Void) {
        self.hideLoader { _ in
//            DispatchQueue.main.async {
////                UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
//                self.refreshUI()
//            }
            if let selectView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalStepViewController") as? ModalStepViewController {
                selectView.modalPresentationStyle = .fullScreen
                selectView.initModal(actionOnValidate: { (title, comment, date, url, oldURL) in
                    self.displayLoader { (_) in
                        completion(title, comment, date, url)
                    }
                })
                
                DispatchQueue.main.async {
                    self.present(selectView, animated: true, completion: nil)
                }
            }
        }
    }
    
    func showConfirmation(withMessage message: String, andNeverAskCode dialogCode: DialogCode?, withFinishedCompletion completion: @escaping () -> Void) {
//        DispatchQueue.main.async {
////            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
//            self.refreshUI()
//        }
        self.hideLoader { _ in
            self.displayAlert(withTitle: "", andMessage: message, andValidButtonText: "general_ok".localized, orCancelText: "general_cancel".localized, andNerverAskCode: dialogCode, completionHandler: { (didValidated) in
                
                if didValidated {
                    
                    self.displayLoader { (_) in
                        completion()
                        
                    }
                }
            })
        }
    }
    
    func didFinishTaskAction(withResult result: ViewModelResult<TaskViewModel>, withMessage message: String?) {
        
        self.hideLoader { _ in
            
            switch result {
            case .value(let task):
                self.selectedTask = task
                if let index = self.tasksAllFilter.firstIndex(of: task) {
                    self.tasksAllFilter.remove(at: index)
                    self.tasksAllFilter.insert(task, at: index)
                }
//                self.displayLoader { _ in
//                    self.pullToRefreshData(self)
//                }
                self.filterTaskToDisplay()
                self.tableViewContent.reloadData {
                    
                }
                if let message = message {
                    self.showBanner(withTitle: message, withColor: .green)
                }
                
            case .failed(let error):
                
                switch error {
                case .error:
                    self.showBanner(withTitle: "error_network".localized, withColor: .redPink)
                case .denied:
                    self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                case .noNetwork:
                    self.showBanner(withTitle: "error_banner_internet".localized, withColor: .redPink)
                case .offlineNotAuthorized:
                    self.showBanner(withTitle: "error_not_in_offline".localized, withColor: .redPink)
                case .canceled:
                    self.showBanner(withTitle: "Prochainement", withColor: .redPink)
                case .notRightUsername:
                    self.showBanner(withTitle: "error_licence_code".localized, withColor: .redPink)
                default:
                    self.displayAlert(withTitle: "error_general".localized, andMessage: "error_network".localized)
                }
            }
        }
    }
    
    func askFor(userSelection userList: [TaskUserViewModel], withSelectCompletion completion: @escaping (_ user: TaskUserViewModel) -> Void) {
//        DispatchQueue.main.async {
////            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
//            self.refreshUI()
//        }
        self.hideLoader { _ in
            if let selectView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalSelectListViewController") as? ModalSelectListViewController {
                var selectedIndex = -1
                if let assignUser = self.selectedTask?.assigned, let index = userList.firstIndex(of: assignUser) {
                    selectedIndex = index
                }
                selectView.modalPresentationStyle = .overFullScreen
                selectView.initModal(withTitle: "assign_page_title".localized,
                                     buttonText: "task_action_assign".localized,
                                     listOfChoice: userList,
                                     searchPlaceHolder: "assign_page_search_hint".localized,
                                     isMultiSelection: false, selectedIndex: [selectedIndex]) { (selectedIndexes) in
                                        guard let index = selectedIndexes.first else {
                                            return
                                        }
                                        
                                        self.displayLoader {_ in
                                            completion(userList[index])
                                        }
                }
                DispatchQueue.main.async {
                    self.present(selectView, animated: true, completion: nil)
                }
            }
        }
    }
    
    func getMoreService(completion: @escaping ([ServiceViewModel]?) -> Void) {
        createAndEditManager.getAvailableServices(forUpdatedTask: self.selectedTask!) { (services, error) in
            if let services = services {
                completion(services)
            } else {
                completion(nil)
            }
        }
    }
    
    func askFor(rejectAndTransfer serviceList: [ServiceViewModel], rejectMessages: [PrefilledMessageViewModel], withSelectCompletion completion: @escaping RejectAndTransferData) {
        self.hideLoader { _ in
            self.getMoreService(completion: { (moreServices) in
                var TotalServices = [ServiceViewModel]()
                TotalServices.append(contentsOf: serviceList)
                if let moreServices = moreServices {
                    TotalServices.append(contentsOf: moreServices)
                }
                if let explanationView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalExplanationFieldsViewController") as? ModalExplanationFieldsViewController {
                    explanationView.serviceList = TotalServices
                    explanationView.pageTitleText = "reject_and_transfer_title".localized
                    explanationView.pageDescriptionText = "reject_and_transfer_description".localized
                    explanationView.pageValidationText = "task_action_reject".localized
                    explanationView.prefilledValues = rejectMessages
                    explanationView.type = .rejectAndTransfer
                    explanationView.modalPresentationStyle = .overFullScreen
                    explanationView.actionOnValidate = { (title, description, service) in
                        self.displayLoader {_ in
                            completion(title, description, service)
                        }
                    }
                    DispatchQueue.main.async {
                        self.present(explanationView, animated: true, completion: nil)
                    }
                }
            })
        }
    }
    
    func askFor(serviceSelection serviceList: [ServiceViewModel], withSelectCompletion completion: @escaping (_ service: ServiceViewModel) -> Void) {
//        DispatchQueue.main.async {
////            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
//            self.refreshUI()
//        }
        self.hideLoader { _ in
            self.getMoreService(completion: { (moreServices) in
                var TotalServices = [ServiceViewModel]()
                TotalServices.append(contentsOf: serviceList)
                if let moreServices = moreServices {
                    TotalServices.append(contentsOf: moreServices)
                }
                if let selectView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalSelectListViewController") as? ModalSelectListViewController {
                    selectView.modalPresentationStyle = .overFullScreen
                    selectView.initModal(withTitle: "service_transfert_page_title".localized,
                                         buttonText: "general_valdiate".localized,
                                         listOfChoice: TotalServices,
                                         searchPlaceHolder: "creation_search_hint_service".localized,
                                         isMultiSelection: false) { (selectedIndexes) in
                                            guard let index = selectedIndexes.first else {
                                                return
                                            }
                                            
                                            self.displayLoader {_ in
                                                completion(TotalServices[index])
                                            }
                    }
                    DispatchQueue.main.async {
                        self.present(selectView, animated: true, completion: nil)
                    }
                }
            })
        }
    }
    
    func askForExplanation(withTitle title: String, withDescrtion description: String, andValidationText validationText: String, withPrefilledValues prefilledValues: [PrefilledMessageViewModel], hasToQuitAfter: Bool, withCompletion completion: @escaping (_ title: String, _ desription: String) -> Void) {
        self.hideLoader { _ in
            
            guard let explanationView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalExplanationFieldsViewController") as? ModalExplanationFieldsViewController  else {
                self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                return
            }
//            DispatchQueue.main.async {
////                UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
//                self.refreshUI()
//            }
            explanationView.modalPresentationStyle = .overFullScreen
            explanationView.pageTitleText = title
            explanationView.pageDescriptionText = description
            explanationView.pageValidationText = validationText
            explanationView.prefilledValues = prefilledValues
            explanationView.actionOnValidate = { (title, description, _) in
                self.displayLoader {_ in
                    completion(title, description)
                }
            }
            
            DispatchQueue.main.async {
                self.present(explanationView, animated: true, completion: nil)
            }
            
        }
    }
    
    func askForTaskEdition(forTask task: TaskViewModel, withCompletion completion: @escaping (_ task: TaskViewModel) -> Void) {
        self.hideLoader { _ in
            guard let editView = UIStoryboard(name: "CreateOrEditTaskStoryboard", bundle: nil).instantiateViewController(withIdentifier: "InterventionTypeAndDomainViewController") as? InterventionTypeAndDomainViewController  else {
                self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                return
            }
//            DispatchQueue.main.async {
////                UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
//                self.refreshUI()
//            }
            editView.modalPresentationStyle = .overFullScreen
            editView.editTask = task
            editView.actionOnValidate = { task in
                self.displayLoader {_ in
                    completion(task)
                }
            }
            
            DispatchQueue.main.async {
                self.present(UINavigationController(rootViewController: editView), animated: true, completion: nil)
            }
        }
    }
    
    func askForNewNotSynchronizedTask(forTask task: TaskViewModel, withCompletion completion: @escaping (_ createdTask: CreatedTaskViewModel) -> Void) {
        self.hideLoader { _ in
            guard let editView = UIStoryboard(name: "CreateOrEditTaskStoryboard", bundle: nil).instantiateViewController(withIdentifier: "InterventionTypeAndDomainViewController") as? InterventionTypeAndDomainViewController  else {
                self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                return
            }
            editView.modalPresentationStyle = .overFullScreen
            editView.editTask = task
            editView.actionOnDuplicate = { task in
                self.displayLoader {_ in
                    completion(task)
                }
            }
            
            DispatchQueue.main.async {
                self.present(UINavigationController(rootViewController: editView), animated: true, completion: nil)
            }
        }
    }
}
