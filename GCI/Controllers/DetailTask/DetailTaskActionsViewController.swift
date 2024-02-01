//
//  DetailTaskActionsViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 21/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

extension DetailTaskViewController: TaskActionsViewControllerDelegate {
    func taskActionTouched(taskAction: TaskAction?) {
        guard let task = self.selectedTask, let action = taskAction else {
            self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
            return
        }
        self.trigger(WithTaskAction: action, forTask: task)
    }
    
    @IBAction func favButtonTouched(_ sender: UIButton) {
        Constant.haveToRefresh = true
        if let task = selectedTask {
            homeManager.setFavorite(forTask: task, isFavorite: !task.isFavorite) { (success, error) in
                if success {
                    task.isFavorite = !task.isFavorite
                } else {
                    self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                }
                
                if task.isFavorite {
                    task.isFavorite = true
                    self.favbutton.setImage(UIImage(named: "ico_favorites_white_full"), for: .normal)
                } else {
                    task.isFavorite = false
                    self.favbutton.setImage(UIImage(named: "ico_favorite"), for: .normal)
                }
            }
            
        }
    }
    
    @objc func touchMap(_ sender: UITapGestureRecognizer? = nil) {
        guard let mapViewController = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as? MapViewController  else {
            self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
            return
        }
        mapViewController.modalPresentationStyle = .overFullScreen
        mapViewController.selectedTask = self.selectedTask
        DispatchQueue.main.async {
            self.present(mapViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func mainActionButtonTouched(_ sender: UIButton) {
        guard let user = User.currentUser(), let task = self.selectedTask else {
            self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
            return
        }
        let actionList = task.taskActions(forUser: user)
        
        guard let firstAction = actionList.first else {
            self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
            return
        }
        
        self.trigger(WithTaskAction: firstAction, forTask: task)
    }
    
    func trigger(WithTaskAction taskAction: TaskAction, forTask task: TaskViewModel) {
        self.displayLoader { (_) in
            self.actionManager.launch(action: taskAction, forTask: task)
        }
    }
}

extension DetailTaskViewController: TaskActionnableDelegate {
    
    func getMoreService(completion: @escaping ([ServiceViewModel]?) -> Void) {
        createAndEditManager.getAvailableServices(forUpdatedTask: self.selectedTask!) { (services, error) in
            if let services = services {
                completion(services)
            } else {
                completion(nil)
            }
        }
    }
    
    func askForEditStepInfo(withCompletion completion: @escaping (ViewableStep, String, String, Date, URL?, AttachmentViewModel?) -> Void) {
        self.hideLoader { _ in
            if let user = User.currentUser(),
                let listOfChoice = self.selectedTask?.displayableAndEditableSteps(forUser: user),
                let selectView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalSelectListViewController") as? ModalSelectListViewController {
                selectView.modalPresentationStyle = .overFullScreen
                selectView.initModal(withTitle: "task_action_step_edit".localized,
                                     buttonText: "task_action_edit".localized,
                                     listOfChoice: listOfChoice,
                                     isMultiSelection: false,
                                     isShowIndex: false) { (selectedIndexes) in
                                        guard let index = selectedIndexes.first else {
                                            return
                                        }
                                        
                                        if let selectView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalStepViewController") as? ModalStepViewController {
                                            selectView.modalPresentationStyle = .overFullScreen
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
            if let selectView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalDatePickerViewController") as? ModalDatePickerViewController {
                
                var startDate: Date?
                self.selectedTask?.steps.forEach({ (step) in
                    if step.action == StepViewModel.Action.start {
                        startDate = step.date.adding(Calendar.Component.minute, value: 1)
                    }
                })
                selectView.modalPresentationStyle = .overFullScreen
                selectView.initModal(isHourDisplay: true, minDate: startDate, actionOnValidate: { (date) in
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
            if let selectView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalStepViewController") as? ModalStepViewController {
                selectView.modalPresentationStyle = .overFullScreen
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
        
        Constant.haveToRefresh = true
        
        self.hideLoader { _ in
            
            switch result {
            case .value(let task):
                if self.hasToQuitAfter {
                    self.navigationController?.popViewController({
                        self.delegate?.displayMessage(message: message ?? "")
                    })
                    self.dismiss(animated: true, completion: {
                        
                    })
                } else {
                    self.selectedTask = task
                    self.refreshData()
                    self.pullToRefreshData(self)
                    if let message = message {
                        self.showBanner(withTitle: message, withColor: .green)
                    }
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
            explanationView.modalPresentationStyle = .overFullScreen
            explanationView.pageTitleText = title
            explanationView.pageDescriptionText = description
            explanationView.pageValidationText = validationText
            explanationView.prefilledValues = prefilledValues
            explanationView.actionOnValidate = { (title, description, _) in
                self.displayLoader {_ in
                    self.hasToQuitAfter = hasToQuitAfter
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
            editView.modalPresentationStyle = .overFullScreen
            editView.editTask = task
            editView.actionOnValidate = { task in
                self.displayLoader {_ in
                    self.forceReloadImage = true
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

extension DetailTaskViewController: BreadCrumbVerticalTableViewCellDelegate {
    func attachmentTouched(attachment: ViewableAttachment) {
        if attachment.isPicture {
            self.fullscreenImage(withImage: attachment.icon)
        } else {
            self.showPDF(attachement: attachment)
        }
    }
}

extension DetailTaskViewController: DetailTaskLinkedTableViewCellDelegate {
    func selectNextTask(nextTasks: [TaskViewModel]?) {
        if let taskList = nextTasks {
            self.showSelectedModal(withTasklist: taskList, title: "task_linked_task_next".localized) { (nextSelectedTask) in
                let storyboard = UIStoryboard(name: "DetailTask", bundle: nil)
                if let detailTaskViewController = storyboard.instantiateViewController(withIdentifier: "detailTaskViewController") as? DetailTaskViewController {
                    detailTaskViewController.selectedTask = nextSelectedTask
                    
                    self.navigationController?.pushViewController(detailTaskViewController)
                }
            }
        }
    }
    
    func selectPreviousTask(previousTask: [TaskViewModel]?) {
        if let taskList = previousTask {
            self.showSelectedModal(withTasklist: taskList, title: "task_linked_task_previous".localized) { (previousSelectedTask) in
                let storyboard = UIStoryboard(name: "DetailTask", bundle: nil)
                if let detailTaskViewController = storyboard.instantiateViewController(withIdentifier: "detailTaskViewController") as? DetailTaskViewController {
                    detailTaskViewController.selectedTask = previousSelectedTask
                    
                    self.navigationController?.pushViewController(detailTaskViewController)
                }
            }
        }
    }
    
    func showSelectedModal(withTasklist taskList: [TaskViewModel], title: String, completion: @escaping (_ selectedtask : TaskViewModel) -> Void) {
        guard let currentTask = self.selectedTask, let selectView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "LinkTaskSelectedModalViewController") as? LinkTaskSelectedModalViewController else {
            return
        }
        selectView.modalPresentationStyle = .fullScreen
        selectView.initModal(withTitle: title, currentTask: currentTask, listOfChoice: taskList) { task in
            completion(task)
        }
        
        DispatchQueue.main.async {
            self.present(selectView, animated: true, completion: nil)
        }
    }
}
