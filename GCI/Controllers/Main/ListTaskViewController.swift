//
//  ListDIViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 07/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ListTaskViewController: AbstractViewController {

    @IBOutlet var viewShortcut: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var btnFavoris: CGIShortcutButton!
    @IBOutlet weak var btnUrgent: CGIShortcutButton!
    @IBOutlet weak var btnLate: CGIShortcutButton!
    @IBOutlet weak var btnPublic: CGIShortcutButton!
    
    private var actionManager = TaskActionnableManager()
    private var tasksToDisplay = [TaskViewModel]()
    private let homeManager = HomeManager()
    private let refreshControl = UIRefreshControl()
    private var isFirstLaunch: Bool = true
    private var tasksAllFilter = [TaskViewModel]()
    var createAndEditManager = CreateAndEditTaskManager()
    var selectedTask: TaskViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.actionManager.delegate = self
        self.setInterface()
        self.setText()
        configureTableView()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        
        if Constant.haveToRefresh || Constant.haveToRefreshFilterListTask {
            self.reloadData()
        }
    }
    
    func reloadData() {
        Constant.haveToRefresh = false
        Constant.haveToRefreshFilterListTask = false
        self.displayLoader { _ in
            self.refreshFilter()
            self.loadTask {
                UIView.performWithoutAnimation {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func setInterface() {
        self.view.backgroundColor = UIColor.lightPeriwinkle
        self.viewShortcut.backgroundColor = UIColor.lightPeriwinkle
    }
    
    func setText() {
        self.btnLate.setTitle("dashboard_filter_late".localized, for: .normal)
        self.btnUrgent.setTitle("dashboard_filter_urgent".localized, for: .normal)
        self.btnFavoris.setTitle("dashboard_filter_favorite".localized, for: .normal)
        self.btnPublic.setTitle("dashboard_filter_public".localized, for: .normal)
        
        self.refreshDateLastSynch()
    }
    
    func refreshDateLastSynch() {
        self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
    }
    
    func refreshFilter() {
        self.btnLate.isSelected = UserDataFilter.unique.lateOnly
        self.btnUrgent.isSelected = UserDataFilter.unique.urgentOnly
        self.btnFavoris.isSelected = UserDataFilter.unique.favoritesOnly
        self.btnPublic.isSelected = UserDataFilter.unique.publicOnly
    }
    
    func loadTask(completion: @escaping () -> Void) {
        homeManager.getAllTask { (taskList, isCached, errorOpt) in
            if let error = errorOpt {
                self.hideLoader { _ in
                    switch error {
                    case .noNetwork:
                        self.showBanner(withTitle: "error_reachability".localized, withColor: .redPink)
                    default:
                        self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                    }
                }
            } else if let taskList = taskList {
                self.tasksAllFilter = taskList
                self.filterTaskToDisplay()
                DispatchQueue.main.async {
                    UIView.performWithoutAnimation {
                        self.tableView.reloadData({
                            if !isCached {
                                self.hideLoader()
                            }
                        })
                    }
                }
            } else {
                self.hideLoader { _ in
                    self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                }
            }
            completion()
        }
    }
    
    func filterTaskToDisplay() {
        self.tasksToDisplay = self.tasksAllFilter.applyGCIGlobalFilters()
        if let user = User.currentUser() {
            self.tasksToDisplay = self.tasksToDisplay.filter({$0.category(forUser: user) == TaskCategory.global })
        }
    }
    
    @objc private func pullToRefreshData(_ sender: Any) {
        refreshData {
            self.refreshDateLastSynch()
        }
    }
    
    func refreshData(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.homeManager.lauchLightSync { (synchInfo) in
                self.refreshControl.endRefreshing()
                switch synchInfo {
                    
                case .success:
                    completion()
                case .errorUpload(let errorMessage):
                    self.hideLoader { _ in
                        self.showBanner(withTitle: errorMessage, withColor: .redPink)
                    }
                case .errorDownload:
                    self.hideLoader { _ in
                        self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                    }
                case .noInternet:
                    self.hideLoader { _ in
                        self.showBanner(withTitle: "error_reachability".localized, withColor: .redPink)
                    }
                }
            }
        }
    }
    
    @IBAction func btnFilterTouched(_ sender: Any) {
        guard let filterViewController = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalFilterViewController") as? ModalFilterViewController  else {
            self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
            return
        }
        filterViewController.modalPresentationStyle = .fullScreen
        filterViewController.initFilter()
        filterViewController.didValidate = {
            self.displayLoader { _ in
                self.loadTask {
                    UIView.performWithoutAnimation {
                        self.hideLoader { _ in
                            Constant.haveToRefreshFilterDashboard = true
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.present(filterViewController, animated: true, completion: nil)
        }
    }
}

extension ListTaskViewController {
    @IBAction func btnShortcutTouched(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            UserDataFilter.unique.urgentOnly = !UserDataFilter.unique.urgentOnly
        case 1:
            UserDataFilter.unique.lateOnly = !UserDataFilter.unique.lateOnly
        case 2:
            UserDataFilter.unique.favoritesOnly = !UserDataFilter.unique.favoritesOnly
        case 3:
            UserDataFilter.unique.publicOnly = !UserDataFilter.unique.publicOnly
        default:
            break
        }
        
        self.filterTaskToDisplay()
        self.tableView.reloadData()
    }
}

extension ListTaskViewController: UITableViewDelegate, UITableViewDataSource {
    func configureTableView() {
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 1000))
        footerView.backgroundColor = UIColor.lightPeriwinkle
        self.tableView.tableFooterView?.addSubview(footerView)
     
        tableView.register(UINib(nibName: "HomeTaskTableViewCell", bundle: nil), forCellReuseIdentifier: "homeTaskCell")
        tableView.register(UINib(nibName: "HomeHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "homeHeaderCell")
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        refreshControl.tintColor = .white
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(pullToRefreshData(_:)), for: .valueChanged)
        
        setupTopColored(inScrollView: tableView, withColor: configuration?.mainColor ?? .lightPeriwinkle)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return tasksToDisplay.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "homeHeaderCell") as! HomeHeaderTableViewCell
            cell.setCell(withTaskCategories: [], forTaskList: [], isFilterActive: UserDataFilter.unique.isFilterPublicActivated, withTitle: "task_global_listing".localized)
            cell.clipsToBounds = false
            cell.onTouchFilters = { [unowned self] in
                self.btnFilterTouched(self)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "homeTaskCell") as! HomeTaskTableViewCell
            cell.setCell(withTask: tasksToDisplay[indexPath.row])
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0)) } else {
            viewShortcut.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 60)
            return viewShortcut
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { return 100 } else {
            let task = tasksToDisplay[indexPath.row]
            var size: CGFloat = 140
            if let name = task.interventionType?.name {
                size += name.heightInsideLabel(withFont: UIFont.gciFontBold(16), andWidth: self.view.width - 160)
            } else if let name = task.interventionTypeComment {
                size += name.heightInsideLabel(withFont: UIFont.gciFontBold(16), andWidth: self.view.width - 160)
            }
            
            size = (task.dueDate != nil) ? size : size - 15
            
            if let location = task.location, !location.address.isEmpty {
                //ajoute une distance fictive pour la marge
                size += "A 100km - \(location.address)".heightInsideLabel(withFont: UIFont.gciFontBold(13), andWidth: self.view.width - 160)
            }
            return size
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 0 } else { return 60 }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.tableView.deselectRow(at: indexPath, animated: true)
            })
            let selectedTask = tasksToDisplay[indexPath.row]
            self.lauchDetailTaskView(withTask: selectedTask)
        }
    }
    
    func lauchDetailTaskView(withTask task: TaskViewModel) {
        let storyboard = UIStoryboard(name: "DetailTask", bundle: nil)
        if let detailTaskViewController = storyboard.instantiateViewController(withIdentifier: "detailTaskViewController") as? DetailTaskViewController {
            detailTaskViewController.selectedTask = task
            
            self.navigationController?.pushViewController(detailTaskViewController)
        }
    }
}

extension ListTaskViewController: HomeTaskTableViewCellDelegate {
    func didSelectAction(ForCurrentTask task: TaskViewModel, andAction action: TaskAction) {
        self.displayLoader { _ in
            self.selectedTask = task
            self.actionManager.launch(action: action, forTask: task)
        }
    }
    
    func didSelectFavorite(forCurrentTask task: TaskViewModel, isFavorite: Bool, selectedCell: HomeTaskTableViewCell) {
        homeManager.setFavorite(forTask: task, isFavorite: isFavorite) { (success, error) in
            if !success {
                selectedCell.forceSetFavorite(isFavorite: !isFavorite)
                self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
            }
        }
    }
}

extension ListTaskViewController: TaskActionnableDelegate {
    func askForEditStepInfo(withCompletion completion: @escaping (ViewableStep, String, String, Date, URL?, AttachmentViewModel?) -> Void) {
        //never
    }
    
    func askForStartOrEndStep(withCompletion completion: @escaping (Date) -> Void) {
        //never
    }
    
    func askForAddStepInfo(withCompletion completion: @escaping (String, String, Date, URL?) -> Void) {
        //never
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
        
        self.hideLoader { _ in
            
            switch result {
            case .value(_):
                self.pullToRefreshData(self)
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
        
        self.hideLoader { _ in
            if let selectView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalSelectListViewController") as? ModalSelectListViewController {
                selectView.modalPresentationStyle = .fullScreen
                selectView.initModal(withTitle: "assign_page_title".localized,
                                     buttonText: "task_action_assign".localized,
                                     listOfChoice: userList,
                                     searchPlaceHolder: "assign_page_search_hint".localized,
                                     isMultiSelection: false) { (selectedIndexes) in
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
        if let selectedTask = selectedTask {
            createAndEditManager.getAvailableServices(forUpdatedTask: selectedTask) { (services, error) in
                if let services = services {
                    completion(services)
                } else {
                    completion(nil)
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
                    explanationView.modalPresentationStyle = .fullScreen
                    explanationView.serviceList = TotalServices
                    explanationView.pageTitleText = "reject_and_transfer_title".localized
                    explanationView.pageDescriptionText = "reject_and_transfer_description".localized
                    explanationView.pageValidationText = "task_action_reject".localized
                    explanationView.prefilledValues = rejectMessages
                    explanationView.type = .rejectAndTransfer
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
                    selectView.modalPresentationStyle = .fullScreen
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
            explanationView.modalPresentationStyle = .fullScreen
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
        //never
    }
    
    func askForNewNotSynchronizedTask(forTask task: TaskViewModel, withCompletion completion: @escaping (_ createdTask: CreatedTaskViewModel) -> Void) {
        //never
    }
}
