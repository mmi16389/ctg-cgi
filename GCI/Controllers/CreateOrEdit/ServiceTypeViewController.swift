//
//  ServiceTypeViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 05/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class ServiceTypeViewController: AbstractCreateOrEditViewController {

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
        
        if self.taskWizzard.service == nil && self.taskWizzard.getLocation() == nil {
            self.taskWizzard.service = self.taskWizzard.getDomain()?.defaultService
        } else if self.taskWizzard.service == nil && self.taskWizzard.getLocation() != nil {
            self.taskWizzard.service = self.taskWizzard.getZone()?.defaultService
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        self.lblTitle.text = "creation_page_service_title".localized
        
        self.lblStep.font = UIFont.gciFontBold(17)
        self.lblStep.textColor = UIColor.white
        self.lblStep.text = "creation_page_step_title".localized(arguments: String(self.wizzardIndex+1))
        
        self.btnNext.setTitle("general_skip".localized, for: .normal)
    }
    
    func isNextAvailable() -> Bool {
        if taskWizzard.service != nil {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func btnNextTouched(_ sender: Any) {
        self.navigateToControllers(index: self.wizzardIndex+1)
    }
    
    @IBAction func goBackTouched(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ServiceTypeViewController {
    func launchModal(withTitle title: String, buttonText: String, listOfChoice: [ModalSelectListItemsDataSource], searchPlaceHolder: String, selectedIndex: [Int], isMultiSelection: Bool, actionOnValidate: @escaping ([Int]) -> Void) {
        if let selectView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalSelectListViewController") as? ModalSelectListViewController {
            selectView.initModal(withTitle: title,
                                 buttonText: buttonText,
                                 listOfChoice: listOfChoice,
                                 searchPlaceHolder: searchPlaceHolder,
                                 isMultiSelection: isMultiSelection,
                                 selectedIndex: selectedIndex,
                                 actionOnValidate: actionOnValidate)
            selectView.modalPresentationStyle = .fullScreen
            DispatchQueue.main.async {
                self.present(selectView, animated: true, completion: nil)
            }
        }
    }
    
    func presentDefaultServiceModalView() {
        var services: [ServiceViewModel] = []
        
        if let _ = self.taskWizzard.getLocation(), let linkedServices = self.taskWizzard.getZone()?.linkedServices, let defaultService = self.taskWizzard.getZone()?.defaultService {
            services = linkedServices
            if !services.contains(defaultService) {
                services.append(defaultService)
            }
        } else if let linkedServices = self.taskWizzard.getDomain()?.linkedServices, let defaultService = self.taskWizzard.getDomain()?.defaultService {
            services = linkedServices
            if !services.contains(defaultService) {
                services.append(defaultService)
            }
        }
        
        self.getMoreService { (moreServices) in
            moreServices?.forEach({ (service) in
                if !services.contains(service) {
                    services.append(service)
                }
            })
            
            if services.count > 0 {
                var hasSelectedIndex = [Int]()
                if let currentService = self.taskWizzard.service {
                    if let index = services.sorted().firstIndex(of: currentService) {
                        hasSelectedIndex.append(index)
                    }
                }
                
                self.launchModal(withTitle: "creation_page_selection_service_title".localized,
                                 buttonText: "general_valdiate".localized,
                                 listOfChoice: services.sorted(),
                                 searchPlaceHolder: "creation_search_hint_service".localized,
                                 selectedIndex: hasSelectedIndex,
                                 isMultiSelection: false,
                                 actionOnValidate: { selectedIndex in
                                    self.taskWizzard.linkedServices = []
                                    if let index = selectedIndex.first {
                                        self.taskWizzard.service = services.sorted()[index]
                                    } else {
                                        self.taskWizzard.service = nil
                                    }
                })
            }
        }
    }
    
    func getMoreService(completion: @escaping ([ServiceViewModel]?) -> Void) {
        if !taskWizzard.isNewTask, let originalTask = self.taskWizzard.originalTask {
            createAndEditManager.getAvailableServices(forUpdatedTask: originalTask) { (services, error) in
                if let services = services {
                    completion(services)
                } else {
                    completion(nil)
                }
            }
        } else {
            completion(nil)
        }
    }
    
    func presentCopyServiceModalView() {
        self.createAndEditManager.getAllServices(completionHandler: { (serviceList, error) in
            if var serviceList = serviceList {
                if let currentService = self.taskWizzard.service, let index = serviceList.firstIndex(of: currentService) {
                    serviceList.remove(at: index)
                }
                var hasSelectedIndex = [Int]()
                for service in self.taskWizzard.linkedServices {
                    if let index = serviceList.firstIndex(of: service) {
                        hasSelectedIndex.append(index)
                    }
                }
                
                self.launchModal(withTitle: "creation_page_selection_service_title".localized,
                                 buttonText: "general_valdiate".localized,
                                 listOfChoice: serviceList,
                                 searchPlaceHolder: "creation_search_hint_service".localized,
                                 selectedIndex: hasSelectedIndex,
                                 isMultiSelection: true,
                                 actionOnValidate: { selectedIndex in
                                    self.taskWizzard.linkedServices = []
                                    if selectedIndex.count > 0 {
                                        for index in selectedIndex {
                                            self.taskWizzard.linkedServices.append(serviceList[index])
                                        }
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

extension ServiceTypeViewController: UITableViewDelegate, UITableViewDataSource {
    func configureTableView() {
        tableViewContent.register(UINib(nibName: "DetailTaskTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTaskTitleCell")
        tableViewContent.register(UINib(nibName: "TextfieldTableViewCell", bundle: nil), forCellReuseIdentifier: "TextfieldCell")
        tableViewContent.register(UINib(nibName: "TextviewTableViewCell", bundle: nil), forCellReuseIdentifier: "TextviewCell")
        tableViewContent.register(UINib(nibName: "DetailTaskTextTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTaskTextCell")
        tableViewContent.register(UINib(nibName: "SpaceTableViewCell", bundle: nil), forCellReuseIdentifier: "SpaceCell")
        tableViewContent.register(UINib(nibName: "SelectChoiceTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectChoiceCell")
    }
    
    func setTableViewCell() {
        self.displayCell.removeAll()
        
        displayCell.append(DataCell(typeCell: .taskTitle, title: "task_service".localized))
        
        if let serviceName = taskWizzard.service?.name {
            displayCell.append(DataCell(typeCell: .textfield, icon: UIImage(named: "ico_open_list"), placeHolder: "creation_page_selection_service_title".localized, prefilledText: serviceName, actionOnTouch: { _ in
                self.presentDefaultServiceModalView()
            }))
        } else {
            displayCell.append(DataCell(typeCell: .textview, icon: UIImage(named: "ico_open_list"), placeHolder: "creation_page_selection_service_title".localized, actionOnTouch: { _ in
                self.presentDefaultServiceModalView()
            }))
        }
        
        displayCell.append(DataCell(typeCell: .taskTitle, title: "creation_page_field_other_service_title".localized))
        
        if taskWizzard.service == nil {
            displayCell.append(DataCell(typeCell: .textview, icon: UIImage(named: "ico_open_list"), placeHolder: "creation_page_selection_service_title".localized))
        } else {
            if taskWizzard.linkedServices.count > 0 {
                var text = ""
                for service in taskWizzard.linkedServices {
                    if !text.isEmpty {
                        text = "\(text) -"
                    }
                    text = "\(text) \(service.name)"
                }
                displayCell.append(DataCell(typeCell: .textview, icon: UIImage(named: "ico_open_list"), placeHolder: "creation_page_selection_service_title".localized, prefilledText: text, actionOnTouch: { _ in
                    self.presentCopyServiceModalView()
                }))
            } else {
                displayCell.append(DataCell(typeCell: .textview, icon: UIImage(named: "ico_open_list"), placeHolder: "creation_page_selection_service_title".localized, actionOnTouch: { _ in
                    self.presentCopyServiceModalView()
                }))
            }
        }
        
        let urgentInteractionEnabled = (taskWizzard.interventionType != nil) ? taskWizzard.service?.permissions.contains(ServiceViewModel.Permission.validate) : false
        displayCell.append(DataCell(typeCell: .selectItem,
                                    title: "creation_page_field_urgent_title".localized,
                                    isSelected: taskWizzard.isUrgent,
                                    intreactionEnabled: urgentInteractionEnabled,
                                    actionOnTouch: { cell in
                if let cell = cell as? SelectChoiceTableViewCell {
                    if self.taskWizzard.service?.permissions.contains(ServiceViewModel.Permission.validate) ?? false {
                        if self.taskWizzard.isUrgent {
                            self.taskWizzard.isUrgent = false
                            DispatchQueue.main.async {
                                cell.setSelected(false, animated: false)
                            }
                        } else {
                            self.taskWizzard.isUrgent = true
                        }
                    }
                }
            }))
//        }
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
        case.textview:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextviewCell") as! TextviewTableViewCell
            cell.initCell(withPlaceHolder: dataCell.placeHolder, andPrefilledText: dataCell.prefilledText, icon: dataCell.icon, isEditable: dataCell.isTextFieldEditable)
            return cell
        case.textfield:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextfieldCell") as! TextfieldTableViewCell
            cell.initCell(withPlaceHolder: dataCell.placeHolder, andPrefilledText: dataCell.prefilledText, icon: dataCell.icon, isEditable: dataCell.isTextFieldEditable)
            return cell
        case.taskText:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTaskTextCell") as! DetailTaskTextTableViewCell
            cell.initCell(withMessage: dataCell.messageAttribute, AndIsLate: false, hasActionOnTouch: false)
            return cell
        case.space:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SpaceCell") as! SpaceTableViewCell
            cell.initCell(backgroundColor: dataCell.backgroundColor)
            return cell
        case.selectItem:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectChoiceCell") as! SelectChoiceTableViewCell
            cell.initCell(withTitle: dataCell.title, isDisplaySeparator: false, interaction: dataCell.intreactionEnabled ?? false)
            if dataCell.isSelected {
                self.tableViewContent.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
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
            return 40
        case .taskText:
            return (displayCell[indexPath.row].messageAttribute?.height(withConstrainedWidth: self.tableViewContent.width - 90) ?? -10) + 10
        case .textview:
            return displayCell[indexPath.row].prefilledText.height(withConstrainedWidth: self.tableViewContent.width - 90, font: UIFont.gciFontRegular(14)) + 60
        case .textfield:
            return 85
        case .selectItem:
            return 70
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataCell = displayCell[indexPath.row]
        dataCell.actionOnTouch?(self.tableViewContent.cellForRow(at: indexPath)!)
    }
}
