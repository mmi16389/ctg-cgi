//
//  ResumeEditOrCreationViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 05/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class ResumeEditOrCreationViewController: AbstractCreateOrEditViewController {

    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblStep: UILabel!
    @IBOutlet weak var btnNext: GCIButton!
    @IBOutlet weak var tableViewContent: UITableView!
    @IBOutlet weak var viewBreadcrumb: GCIBreadCrumb!
    @IBOutlet weak var constraintWidthBreadcrumb: NSLayoutConstraint!
    
    private var displayCell = [DataCell]()
    private var createAndEditManager = CreateAndEditTaskManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableViewContent.delegate = self
        self.tableViewContent.dataSource = self
        
        self.setText()
        self.setInterface()
        self.configureTableView()
        
        self.btnNext.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.displayCell = [DataCell]()
        
        self.setTableViewCell()
        self.tableViewContent.reloadData()
        
        if isNextAvailable() {
            self.btnNext.isEnabled = true
        } else {
            self.btnNext.isEnabled = false
        }
        
        self.checkViewControllersAccessibility()
        self.viewBreadcrumb.define(withNumbersElements: taskWizzard.getNumberOfActiveButton(), andSelectedIndex: self.wizzardIndex, andArrayOfControllers: arrayOfController, actionOnTouch: { index in
            self.navigateToControllers(index: index)
        })
        self.constraintWidthBreadcrumb.constant = self.viewBreadcrumb.totalWidth
        self.view.layoutIfNeeded()
    }
    
    func setInterface() {
        self.viewHeader.backgroundColor = configuration?.mainColor ?? UIColor.cerulean
        self.viewBreadcrumb.backgroundColor = UIColor.clear
    }
    
    func setText() {
        self.lblTitle.font = UIFont.gciFontBold(17)
        self.lblTitle.textColor = UIColor.white
        self.lblTitle.text = "creation_page_resume_title".localized
        
        self.lblStep.font = UIFont.gciFontBold(17)
        self.lblStep.textColor = UIColor.white
        self.lblStep.text = "creation_page_step_title".localized(arguments: String(self.wizzardIndex+1))
        
        self.btnNext.setTitle("general_valdiate".localized, for: .normal)
    }
    
    func isNextAvailable() -> Bool {
        if taskWizzard.service != nil {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func btnValidateTouched(_ sender: Any) {
        Constant.haveToRefresh = true
        if let _ = taskWizzard.originalTask {
            if taskWizzard.actionOnValidate != nil {
                editTask()
            } else if taskWizzard.actionOnDuplicate != nil {
                createDuplicateTask()
            }
        } else {
            createTask()
        }
    }
    
    func createDuplicateTask() {
        if let createTask = self.taskWizzard.createForUpload() {
            self.displayLoader { _ in
                self.createAndEditManager.createTaskWithoutSynch(withCreatedTask: createTask, completionHandler: { (success, error) in
                    if success {
                        self.hideLoader { _ in
                            self.taskWizzard.actionOnDuplicate?(createTask)
                            self.dismiss(animated: true, completion: nil)
                        }
                    } else {
                        if let error = error {
                            self.hideLoader { _ in
                                switch error {
                                case .error:
                                    self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                                case .denied:
                                    self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                                case .noNetwork:
                                    self.showBanner(withTitle: "error_not_in_offline".localized, withColor: .redPink)
                                case .offlineNotAuthorized:
                                    self.showBanner(withTitle: "error_not_in_offline".localized, withColor: .redPink)
                                case .canceled:
                                    self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                                case .notRightUsername:
                                    self.showBanner(withTitle: "error_licence_code".localized, withColor: .redPink)
                                default:
                                    self.displayAlert(withTitle: "error_general".localized, andMessage: "error_network".localized)
                                }
                            }
                        } else {
                            self.hideLoader { _ in
                                self.displayAlert(withTitle: "error_general".localized, andMessage: "error_adding_task".localized)
                            }
                        }
                    }
                })
            }
        }
    }
        
    func editTask() {
        if let editTask = self.taskWizzard.edit() {
            self.displayLoader { _ in
                self.createAndEditManager.updateTask(withUpdatedTask: editTask, completionHandler: { (success, error) in
                    if success {
                        self.hideLoader { _ in
                            self.taskWizzard.actionOnValidate?(editTask)
                            self.dismiss(animated: true, completion: nil)
                        }
                    } else {
                        if let error = error {
                            self.hideLoader { _ in
                                switch error {
                                case .error:
                                    self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                                case .denied:
                                    self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                                case .noNetwork:
                                    self.showBanner(withTitle: "error_not_in_offline".localized, withColor: .redPink)
                                case .offlineNotAuthorized:
                                    self.showBanner(withTitle: "error_not_in_offline".localized, withColor: .redPink)
                                case .canceled:
                                    self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                                case .notRightUsername:
                                    self.showBanner(withTitle: "error_licence_code".localized, withColor: .redPink)
                                default:
                                    self.displayAlert(withTitle: "error_general".localized, andMessage: "error_network".localized)
                                }
                            }
                        } else {
                            self.hideLoader { _ in
                                self.displayAlert(withTitle: "error_general".localized, andMessage: "error_adding_task".localized)
                            }
                        }
                    }
                })
            }
        } else {
            self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
        }
    }
    
    func createTask() {
        if let createdTask = self.taskWizzard.createForUpload() {
            self.displayLoader()
            self.createAndEditManager.createTask(withCreatedTask: createdTask) { (success, error) in
                if success {
                    self.hideLoader { _ in
                        self.exitWizzardWithSuccess()
                    }
                } else {
                    if let error = error {
                        self.hideLoader { _ in
                            switch error {
                            case .error:
                                self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                            case .denied:
                                self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                            case .noNetwork:
                                self.showBanner(withTitle: "error_not_in_offline".localized, withColor: .redPink)
                            case .offlineNotAuthorized:
                                self.showBanner(withTitle: "error_not_in_offline".localized, withColor: .redPink)
                            case .canceled:
                                self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                            case .notRightUsername:
                                self.showBanner(withTitle: "error_licence_code".localized, withColor: .redPink)
                            default:
                                self.displayAlert(withTitle: "error_general".localized, andMessage: "error_network".localized)
                            }
                        }
                    } else {
                        self.hideLoader { _ in
                            self.displayAlert(withTitle: "error_general".localized, andMessage: "error_adding_task".localized)
                        }
                    }
                }
            }
        } else {
            self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
        }
    }
    
    @IBAction func goBackTouched(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension ResumeEditOrCreationViewController: UITableViewDelegate, UITableViewDataSource {
    func configureTableView() {
        tableViewContent.register(UINib(nibName: "DetailTaskTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTaskTitleCell")
        tableViewContent.register(UINib(nibName: "TextviewTableViewCell", bundle: nil), forCellReuseIdentifier: "TextviewCell")
        tableViewContent.register(UINib(nibName: "DetailTaskTextTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTaskTextCell")
        tableViewContent.register(UINib(nibName: "SpaceTableViewCell", bundle: nil), forCellReuseIdentifier: "SpaceCell")
        tableViewContent.register(UINib(nibName: "DetailTaskAttachmentTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTaskAttachmentCell")
    }
    
    func setTableViewCell() {
        if taskWizzard.isUrgent {
            self.displayCell.append(DataCell(typeCell: .taskTitle, title: "creation_page_field_urgent_title".localized, rightIcon: UIImage(named: "ico_check_resume_di")))
        }
        
        if taskWizzard.interventionType != nil || !taskWizzard.interventionComment.isEmpty {
            self.displayCell.append(DataCell(typeCell: .taskTitle, title: "task_intervention_type".localized))
            
            if let intervention = taskWizzard.interventionType {
                self.displayCell.append(DataCell(typeCell: .taskText, messageAttribute: NSAttributedString.addSimpleCell(message: intervention.name, font: UIFont.gciFontRegular(16))))
            }
            
            if !self.taskWizzard.interventionComment.isEmpty {
                self.displayCell.append(DataCell(typeCell: .taskText, messageAttribute: NSAttributedString.addSimpleCell(message: self.taskWizzard.interventionComment, font: UIFont.gciFontRegular(16))))
            }
        }
        
        if let domain = taskWizzard.getDomain() {
            self.displayCell.append(DataCell(typeCell: .taskTitle, title: "task_domain".localized))
            
            self.displayCell.append(DataCell(typeCell: .taskText, messageAttribute: NSAttributedString.addSimpleCell(message: domain.title, font: UIFont.gciFontRegular(16))))
        }
        
        if let localisation = taskWizzard.getLocation() {
            self.displayCell.append(DataCell(typeCell: .taskTitle, title: "creation_page_field_location_title".localized))
            
            self.displayCell.append(DataCell(typeCell: .taskText, messageAttribute: NSAttributedString.addSimpleCell(message: localisation.address, font: UIFont.gciFontRegular(16))))
            
            if !localisation.comment.isEmpty {
                self.displayCell.append(DataCell(typeCell: .taskText, messageAttribute: NSAttributedString.commentMessage(withMessage: localisation.comment, font: UIFont.gciFontRegular(16))))
            }
        }
        
        if let patrimony = taskWizzard.getTaskPatrimony() {
            self.displayCell.append(DataCell(typeCell: .taskTitle, title: "task_patrimony".localized))
            
            self.displayCell.append(DataCell(typeCell: .taskText, messageAttribute: NSAttributedString.addSimpleCell(message: patrimony.key, font: UIFont.gciFontRegular(16))))
            self.displayCell.append(DataCell(typeCell: .taskText, messageAttribute: NSAttributedString.addSimpleCell(message: patrimony.address, font: UIFont.gciFontRegular(16))))
            
            if !taskWizzard.getPatrimonyCommment().isEmpty {
                self.displayCell.append(DataCell(typeCell: .taskText, messageAttribute: NSAttributedString.commentMessage(withMessage: taskWizzard.getPatrimonyCommment(), font: UIFont.gciFontRegular(16))))
            }
        }
        
        if let service = taskWizzard.service {
            self.displayCell.append(DataCell(typeCell: .taskTitle, title: "task_service".localized))
            
            self.displayCell.append(DataCell(typeCell: .taskText, messageAttribute: NSAttributedString.addSimpleCell(message: service.name, font: UIFont.gciFontRegular(16))))
        }
        
        if taskWizzard.linkedServices.count > 0 {
            self.displayCell.append(DataCell(typeCell: .taskTitle, title: "task_other_services".localized))
            
            var text = ""
            for service in taskWizzard.linkedServices {
                if !text.isEmpty {
                    text = "\(text)  - "
                }
                text = "\(text)\(service.name)"
            }
            
            self.displayCell.append(DataCell(typeCell: .taskText, messageAttribute: NSAttributedString.addSimpleCell(message: text, font: UIFont.gciFontRegular(16))))
        }
        
        if !taskWizzard.comment.isEmpty {
            self.displayCell.append(DataCell(typeCell: .taskTitle, title: "task_commentary".localized))
            
            self.displayCell.append(DataCell(typeCell: .taskText, messageAttribute: NSAttributedString.addSimpleCell(message: taskWizzard.comment, font: UIFont.gciFontRegular(16))))
        }
        
        if let attachment = taskWizzard.createdAttchment {
            self.displayCell.append(DataCell(typeCell: .taskTitle, title: "tast_attachement".localized))
            
            self.displayCell.append(DataCell(typeCell: .attachementTask, attachement: attachment, actionOnTouch: { (cell) in
                if let cell = cell as? DetailTaskAttachmentTableViewCell {
                    if cell.attachement.isPicture {
                        self.fullscreenImage(inCell: cell)
                    }
                }
            }))
        } else if let attachment = taskWizzard.attachment {
            self.displayCell.append(DataCell(typeCell: .taskTitle, title: "tast_attachement".localized))
            
            self.displayCell.append(DataCell(typeCell: .attachementTask, attachement: attachment, actionOnTouch: { (cell) in
                if let cell = cell as? DetailTaskAttachmentTableViewCell {
                    if cell.attachement.isPicture {
                        self.fullscreenImage(inCell: cell)
                    }
                }
            }))
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayCell.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataCell = displayCell[indexPath.row]
        
        switch dataCell.typeCell {
        case .taskTitle:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTaskTitleCell") as! DetailTaskTitleTableViewCell
            cell.initCell(withTitle: dataCell.title, andIcon: dataCell.icon, isCollapsable: dataCell.isCollapsable, isCollapsed: dataCell.isCollapsed, imageRight: dataCell.rightIcon)
            return cell
        case.textview:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextviewCell") as! TextviewTableViewCell
            cell.initCell(withPlaceHolder: dataCell.placeHolder, andPrefilledText: dataCell.prefilledText, icon: dataCell.icon, isEditable: dataCell.isTextFieldEditable)
            return cell
        case.taskText:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTaskTextCell") as! DetailTaskTextTableViewCell
            cell.initCell(withMessage: dataCell.messageAttribute, AndIsLate: false, hasActionOnTouch: false, marginLeft: 24)
            return cell
        case.space:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpaceCell") as! SpaceTableViewCell
            cell.initCell(backgroundColor: dataCell.backgroundColor)
            return cell
        case.attachementTask:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTaskAttachmentCell") as! DetailTaskAttachmentTableViewCell
            cell.initCell(attachement: dataCell.attachement, isTitlePadding: false, forceReloadImage: true)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch displayCell[indexPath.row].typeCell {
        case .space:
            return 40
        case .taskTitle:
            return 50
        case .attachementTask:
            return 85
        case .taskText:
            return (displayCell[indexPath.row].messageAttribute?.height(withConstrainedWidth: self.tableViewContent.width - 90) ?? -10) + 10
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataCell = displayCell[indexPath.row]
        dataCell.actionOnTouch?(self.tableViewContent.cellForRow(at: indexPath)!)
    }
}

extension ResumeEditOrCreationViewController {
    func fullscreenImage(inCell cell: UITableViewCell) {
        if let cell = cell as? DetailTaskAttachmentTableViewCell {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "ModalsStoryboard", bundle: nil)
                if let imageViewController = storyboard.instantiateViewController(withIdentifier: "modalImageViewController") as? ModalImageViewController {
                    imageViewController.image = cell.imgPhoto.image
                    imageViewController.modalPresentationStyle = .fullScreen
                    self.present(imageViewController, animated: true, completion: nil)
                }
            }
        }
    }
}
