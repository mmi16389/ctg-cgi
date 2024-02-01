//
//  InterventionTypeAndDomainViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 03/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class InterventionTypeAndDomainViewController: AbstractCreateOrEditViewController {
    
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblStep: UILabel!
    @IBOutlet weak var btnNext: GCIButton!
    @IBOutlet weak var btnQuit: UIButton!
    @IBOutlet weak var tableViewContent: UITableView!
    @IBOutlet weak var viewBreadcrumb: GCIBreadCrumb!
    @IBOutlet weak var constraintWidthBreadcrumb: NSLayoutConstraint!
    typealias Action = (_ task: TaskViewModel) -> Void
    typealias ActionDuplicate = (_ task: CreatedTaskViewModel) -> Void
    var actionOnValidate: Action?
    var actionOnDuplicate: ActionDuplicate?
    var editTask: TaskViewModel?
    private var displayCell = [DataCell]()
    private var createAndEditManager = CreateAndEditTaskManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self
        
        self.tableViewContent.delegate = self
        self.tableViewContent.dataSource = self
        
        if let editTask = editTask {
            taskWizzard = TaskWizzard(originalTask: editTask, interventionType: editTask.interventionType, location: editTask.location, isUrgent: editTask.isUrgent, comment: editTask.comment, interventionComment: editTask.interventionTypeComment ?? "", domain: editTask.domain, createdAttchment: editTask.createdAttachment, attachment: editTask.attachment, taskPatrimony: editTask.patrimony, patrimonyComment: editTask.patrimonyComment ?? "", zone: editTask.zone, service: editTask.service, linkedServices: editTask.otherServices, isDuplicateTask: self.actionOnDuplicate != nil ? true: false)
            taskWizzard.actionOnValidate = self.actionOnValidate
            taskWizzard.actionOnDuplicate = self.actionOnDuplicate
            btnQuit.isHidden = false
        } else {
            btnQuit.isHidden = true
        }
        
        self.setText()
        self.setInterface()
        self.configureTableView()
        
        self.btnNext.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Constant.haveToRefresh = false
        self.resetScreen()
    }
    
    func createArrayOfControllers() {
        var currentWizzardIndex = 0
        arrayOfController.removeAll()
        
        self.wizzardIndex = currentWizzardIndex
        currentWizzardIndex += 1
        arrayOfController.append(self)
        
        if taskWizzard.shouldDisplayMap, let taskLocationVC = self.storyboard?.instantiateViewController(withIdentifier: "TaskLocationViewController") as? TaskLocationViewController {
            taskLocationVC.wizzardIndex = currentWizzardIndex
            currentWizzardIndex += 1
            arrayOfController.append(taskLocationVC)
        }
        
        if let serviceTypeVC = self.storyboard?.instantiateViewController(withIdentifier: "ServiceTypeViewController") as? ServiceTypeViewController {
            serviceTypeVC.wizzardIndex = currentWizzardIndex
            currentWizzardIndex += 1
            arrayOfController.append(serviceTypeVC)
        }
        if let mediaCommentVC = self.storyboard?.instantiateViewController(withIdentifier: "MediaAndCommentViewController") as? MediaAndCommentViewController {
            mediaCommentVC.wizzardIndex = currentWizzardIndex
            currentWizzardIndex += 1
            arrayOfController.append(mediaCommentVC)
        }
        if let resumeVC = self.storyboard?.instantiateViewController(withIdentifier: "ResumeEditOrCreationViewController") as? ResumeEditOrCreationViewController {
            resumeVC.wizzardIndex = currentWizzardIndex
            currentWizzardIndex += 1
            arrayOfController.append(resumeVC)
        }
    }
    
    func setInterface() {
        self.viewHeader.backgroundColor = configuration?.mainColor ?? UIColor.cerulean
        self.viewBreadcrumb.backgroundColor = UIColor.clear
    }
    
    func setText() {
        self.lblTitle.font = UIFont.gciFontBold(17)
        self.lblTitle.textColor = UIColor.white
        self.lblTitle.text = "creation_page_intervention_title".localized
        
        self.lblStep.font = UIFont.gciFontBold(17)
        self.lblStep.textColor = UIColor.white
        self.lblStep.text = "creation_page_step_title".localized(arguments: String(self.wizzardIndex+1))
        
        self.btnNext.setTitle("general_skip".localized, for: .normal)
    }
    
    func isNextAvailable() -> Bool {
        if (taskWizzard.interventionType != nil || !taskWizzard.interventionComment.isEmpty) && taskWizzard.getDomain() != nil {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func btnNextTouched(_ sender: Any) {
        self.navigateToControllers(index: self.wizzardIndex+1)
    }
    
    @IBAction func btnQuitTouched(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension InterventionTypeAndDomainViewController {
    
    func launchModal(withTitle title: String, buttonText: String, listOfChoice: [ModalSelectListItemsDataSource], searchPlaceHolder: String, selectedIndex: [Int], isMultiSelection: Bool, actionOnValidate: @escaping ([Int]) -> Void) {
        if let selectView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalSelectListViewController") as? ModalSelectListViewController {
            selectView.modalPresentationStyle = .fullScreen
            selectView.initModal(withTitle: title,
                                 buttonText: buttonText,
                                 listOfChoice: listOfChoice,
                                 searchPlaceHolder: searchPlaceHolder,
                                 isMultiSelection: isMultiSelection,
                                 selectedIndex: selectedIndex,
                                 actionOnValidate: actionOnValidate)
            DispatchQueue.main.async {
                self.present(selectView, animated: true, completion: nil)
            }
        }
    }
    
    func presentDomainModalView() {
        self.createAndEditManager.getAllDomain(forNewTask: editTask == nil, completionHandler: { (domainList, error) in
            if let domainList = domainList {
                
                var hasSelectedIndex = [Int]()
                if let currentDomain = self.taskWizzard.getDomain() {
                    if let index = domainList.firstIndex(of: currentDomain) {
                        hasSelectedIndex.append(index)
                    }
                }
                
                self.launchModal(withTitle: "creation_page_selection_domain_title".localized,
                                 buttonText: "general_valdiate".localized,
                                 listOfChoice: domainList, 
                                 searchPlaceHolder: "creation_search_hint_domain".localized,
                                 selectedIndex: hasSelectedIndex,
                                 isMultiSelection: false,
                                 actionOnValidate: { selectedIndex in
                                    if let index = selectedIndex.first {
                                        self.taskWizzard.setDomain(domain: domainList[index])
                                    } else {
                                        self.taskWizzard.setDomain(domain: nil)
                                    }
                })
            } else {
                if let error = error {
                    self.manageError(error: error)
                }
            }
        })
    }
    
    func presentInterventionTypeModalView() {
        self.createAndEditManager.getAllInterventionType(forNewTask: editTask == nil, completionHandler: { (interventionsTypeList, error) in
            if let interventionTypeList = interventionsTypeList {
                
                var hasSelectedIndex = [Int]()
                if let currentIntervention = self.taskWizzard.interventionType {
                    if let index = interventionTypeList.firstIndex(of: currentIntervention) {
                        hasSelectedIndex.append(index)
                    }
                }
                
                self.launchModal(withTitle: "creation_page_selection_intervention_title".localized,
                                 buttonText: "general_valdiate".localized,
                                 listOfChoice: interventionTypeList,
                                 searchPlaceHolder: "creation_search_hint_intervention_type".localized,
                                 selectedIndex: hasSelectedIndex,
                                 isMultiSelection: false,
                                 actionOnValidate: { selectedIndex in
                                    if let index = selectedIndex.first {
                                        self.taskWizzard.interventionType = interventionTypeList[index]
                                    } else {
                                        self.taskWizzard.interventionType = nil
                                    }
                })
            } else {
                if let error = error {
                    self.manageError(error: error)
                }
            }
        })
    }
    
    func manageError(error: ViewModelError) {
        switch error {
        case .error:
            self.displayAlert(withTitle: "error_general".localized, andMessage: "error_network".localized)
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

extension InterventionTypeAndDomainViewController: UITableViewDelegate, UITableViewDataSource {
    func configureTableView() {
        tableViewContent.register(UINib(nibName: "DetailTaskTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTaskTitleCell")
        tableViewContent.register(UINib(nibName: "TextfieldTableViewCell", bundle: nil), forCellReuseIdentifier: "TextfieldCell")
        tableViewContent.register(UINib(nibName: "DetailTaskTextTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTaskTextCell")
        tableViewContent.register(UINib(nibName: "SpaceTableViewCell", bundle: nil), forCellReuseIdentifier: "SpaceCell")
    }
    
    func setTableViewCell() {
        self.displayCell.removeAll()
        
        displayCell.append(DataCell(typeCell: .taskTitle, title: "creation_page_field_intervention_title".localized))
        
        if let interventionName = taskWizzard.interventionType?.name {
            displayCell.append(DataCell(typeCell: .textfield, icon: UIImage(named: "ico_open_list"), placeHolder: "creation_page_field_selection_hint".localized, prefilledText: interventionName, actionOnTouch: { _ in
                self.presentInterventionTypeModalView()
            }))
            
            displayCell.append(DataCell(typeCell: .textfield, placeHolder: "creation_page_field_intervention_hint".localized, isTextFieldEditable: false))
            
        } else {
            displayCell.append(DataCell(typeCell: .textfield, icon: UIImage(named: "ico_open_list"), placeHolder: "creation_page_field_selection_hint".localized, actionOnTouch: { _ in
                self.presentInterventionTypeModalView()
            }))
            
            displayCell.append(DataCell(typeCell: .textfield, placeHolder: "creation_page_field_intervention_hint".localized, prefilledText: taskWizzard.interventionComment, isTextFieldEditable: true, charLimitation: 100))
        }
        
        displayCell.append(DataCell(typeCell: .taskTitle, title: "creation_page_field_domain_title".localized))
        
        if let domain = taskWizzard.getDomain(), let _ = taskWizzard.interventionType {
            displayCell.append(DataCell(typeCell: .textfield, placeHolder: "creation_page_selection_domain_title".localized, prefilledText: domain.title))
        } else if let domain = taskWizzard.getDomain() {
            displayCell.append(DataCell(typeCell: .textfield, icon: UIImage(named: "ico_open_list"), placeHolder: "creation_page_selection_domain_title".localized, prefilledText: domain.title, actionOnTouch: { _ in
                self.presentDomainModalView()
            }))
        } else {
            displayCell.append(DataCell(typeCell: .textfield, icon: UIImage(named: "ico_open_list"), placeHolder: "creation_page_selection_domain_title".localized, actionOnTouch: { _ in
                self.presentDomainModalView()
            }))
        }
        
        displayCell.append(DataCell(typeCell: .space, backgroundColor: UIColor.white))
        displayCell.append(DataCell(typeCell: .taskText,
                                    messageAttribute: NSAttributedString.asterixTextCenter(message: "creation_page_step_mandatory_explanation".localized, font: UIFont.gciFontRegular(14), color: UIColor.veryLightPink)))
        displayCell.append(DataCell(typeCell: .space, backgroundColor: UIColor.white))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayCell.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataCell = displayCell[indexPath.row]
        
        switch dataCell.typeCell {
        case .taskTitle:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTaskTitleCell") as! DetailTaskTitleTableViewCell
            cell.initCell(withTitle: dataCell.title, andIcon: dataCell.icon, isCollapsable: dataCell.isCollapsable, isCollapsed: dataCell.isCollapsed)
            return cell
        case .textfield:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextfieldCell") as! TextfieldTableViewCell
            cell.initCell(withPlaceHolder: dataCell.placeHolder, andPrefilledText: dataCell.prefilledText, icon: dataCell.icon, isEditable: dataCell.isTextFieldEditable, parentDelegate: self, limitation: dataCell.charLimitation ?? 0)
            return cell
        case .taskText:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTaskTextCell") as! DetailTaskTextTableViewCell
            cell.initCell(withMessage: dataCell.messageAttribute, AndIsLate: false, hasActionOnTouch: false)
            return cell
        case .space:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpaceCell") as! SpaceTableViewCell
            cell.initCell(backgroundColor: dataCell.backgroundColor)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch displayCell[indexPath.row].typeCell {
        case .space:
            return 30
        case .taskTitle:
            return 40
        case .taskText:
            return (displayCell[indexPath.row].messageAttribute?.height(withConstrainedWidth: self.tableViewContent.width - 90) ?? -10) + 10
        case .textfield:
            return 85
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.btnNext.becomeFirstResponder()
        let dataCell = displayCell[indexPath.row]
        dataCell.actionOnTouch?(self.tableViewContent.cellForRow(at: indexPath)!)
    }
}

extension InterventionTypeAndDomainViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            taskWizzard.interventionComment = text
            setTableViewCell()
            
            if isNextAvailable() {
                self.btnNext.isEnabled = true
            } else {
                self.btnNext.isEnabled = false
            }
        }
    }
}

extension InterventionTypeAndDomainViewController: UITabBarControllerDelegate {
    func resetScreen() {
        self.displayCell = [DataCell]()
        
        self.setTableViewCell()
        self.tableViewContent.reloadData()
        
        if isNextAvailable() {
            self.btnNext.isEnabled = true
        } else {
            self.btnNext.isEnabled = false
        }
        
        self.createArrayOfControllers()
        self.checkViewControllersAccessibility()
        self.viewBreadcrumb.define(withNumbersElements: taskWizzard.getNumberOfActiveButton(), andSelectedIndex: self.wizzardIndex, andArrayOfControllers: arrayOfController, actionOnTouch: { index in
            self.navigateToControllers(index: index)
        })
        self.constraintWidthBreadcrumb.constant = self.viewBreadcrumb.totalWidth
        self.view.layoutIfNeeded()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if self.taskWizzard.interventionType != nil || !self.taskWizzard.interventionComment.isEmpty || self.taskWizzard.getDomain() != nil {
            self.displayAlert(withTitle: "", andMessage: "action_confirmation_quit_wizard".localized, andValidButtonText: "general_ok".localized, orCancelText: "general_cancel".localized) { (accept) in
                if accept {
                    self.navigationController?.popToViewController(self.arrayOfController[0], animated: false)
                    self.arrayOfController[0].taskWizzard.createdAttchment = nil
                    self.arrayOfController[0].taskWizzard = TaskWizzard()
                    if let index = tabBarController.viewControllers?.firstIndex(of: viewController) {
                        if index != tabBarController.selectedIndex {
                            self.tabBarController?.selectedIndex = index
                        } else {
                            self.resetScreen()
                        }
                    }
                }
            }
            return false
        } else {
            return true
        }
    }
}
