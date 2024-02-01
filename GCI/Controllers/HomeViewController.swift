//
//  HomeViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 07/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit
import MobileCoreServices
import UserNotifications

class HomeViewController: AbstractViewController {

    @IBOutlet weak var tableViewContent: UITableView!
    @IBOutlet weak var viewShortcutHeader: UIView!
    @IBOutlet weak var viewFloatingButtonMap: UIView!
    @IBOutlet weak var btnFloatingMap: UIButton!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var btnFavoris: CGIShortcutButton!
    @IBOutlet weak var btnUrgent: CGIShortcutButton!
    @IBOutlet weak var btnLate: CGIShortcutButton!
    
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var collectionViewCategories: UICollectionView!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblLastSynch: UILabel!
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var imgFilterActivated: UIImageView!
    
    var categoriesVisible = [TaskCategory]()
    var tasksAllFilter = [TaskViewModel]()
    var tasksToDisplay = [TaskViewModel]()
    var selectedCategory: TaskCategory?
    var selectedTask: TaskViewModel?
    var isFirstLaunch: Bool = true
    var selectedCategoryCell = UICollectionViewCell()
    var currentOrientation = UIDeviceOrientation.portrait
    var createAndEditManager = CreateAndEditTaskManager()
    
    private var actionManager = TaskActionnableManager()
    private let homeManager = HomeManager()
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.actionManager.delegate = self
        
        self.setInterface()
        self.setText()
        self.setInterfaceForiPad()
        self.setTextForiPad()
        configureTableView()
        
        self.tableViewContent.dataSource = self
        self.tableViewContent.delegate = self
        
        self.displayLoader { _ in
            self.refreshData {
                self.hideLoader { _ in
                    self.askForNotificationPermission()
                    self.checkNotificationReceived()
                }
            }
        }
        
        configureCollectionView()
        
        self.collectionViewCategories.dataSource = self
        self.collectionViewCategories.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        if !isFirstLaunch && (Constant.haveToRefresh || Constant.haveToRefreshFilterDashboard) {
            Constant.haveToRefresh = false
            Constant.haveToRefreshFilterDashboard = false
            self.displayLoader { _ in
                DispatchQueue.global().async {
                    self.refreshFilter()
                    self.loadTask {
                        UIView.performWithoutAnimation {
                            self.tableViewContent.reloadData ()
                        }
                    }
                }
            }
        } else if !isFirstLaunch && DeviceType.isIpad {
            self.tableViewContent.reloadData ()
        } else {
            isFirstLaunch = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        currentOrientation = UIDeviceOrientation.portrait
        self.hideLoader()
    }

    func checkNotificationReceived() {
        if let taskID = UserDefaultManager.shared.notificationPushEventTaskId {
            homeManager.getTask(byId: taskID) { (task, error) in
                if let task = task {
                    UserDefaultManager.shared.removePushNotification()
                    if self.loaderIsPlaying {
                        self.hideLoader { _ in
                            self.lauchDetailTaskView(withTask: task)
                        }
                    } else {
                        self.lauchDetailTaskView(withTask: task)
                    }
                } else {
                    if let error = error {
                        switch error {
                        case .noNetwork, .offlineNotAuthorized:
                            self.showBanner(withTitle: "error_reachability".localized, withColor: .redPink)
                        default:
                            self.displayAlert(withTitle: "error_general".localized, andMessage: "error_network".localized)
                        }
                        UserDefaultManager.shared.removePushNotification()
                    }
                }
                if self.loaderIsPlaying {
                    self.hideLoader()
                }
            }
        }
    }
    
    private func askForNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                
                DispatchQueue.main.async {
                    // Register for push
                    UIApplication.shared.registerForRemoteNotifications()
                }
                self.licenceManager.mapConfiguration { (result, error) in
                
                if !ArcgisMapOfflineHelper.haveOfflineMap || ArcgisMapOfflineHelper.isOutdatedMap {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["map_offline"])
                    // Show notification for map
                    let content = UNMutableNotificationContent()
                    content.body = "\("notification_map_not_to_date_title".localized) \n\("notification_map_not_to_date_content".localized)"
                    content.sound = UNNotificationSound.default
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
                    let request = UNNotificationRequest(identifier: "map_offline", content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                }
                }
            }
        }
    }
    
    func scheduleNotification() {
        
        let content = UNMutableNotificationContent()
        content.title = "".localized
        content.body = "".localized
        content.sound = UNNotificationSound.default
    }

    override func refreshUI() {
        super.refreshUI()
    }
    
    func setInterface() {
        self.view.backgroundColor = UIColor.lightPeriwinkle
        self.viewBackground.backgroundColor = UIColor.clear
        self.viewShortcutHeader.backgroundColor = UIColor.lightPeriwinkle
        
        self.viewFloatingButtonMap.setRounded()
        self.viewFloatingButtonMap.addShadow(radius: 16)
    }
    
    func setText() {
        self.btnLate.setTitle("dashboard_filter_late".localized, for: .normal)
        self.btnUrgent.setTitle("dashboard_filter_urgent".localized, for: .normal)
        self.btnFavoris.setTitle("dashboard_filter_favorite".localized, for: .normal)
    }
    
    func refreshFilter() {
        DispatchQueue.main.async {
            self.btnLate.isSelected = UserDataFilter.unique.lateOnly
            self.btnUrgent.isSelected = UserDataFilter.unique.urgentOnly
            self.btnFavoris.isSelected = UserDataFilter.unique.favoritesOnly
            
            self.tableViewContent.reloadData()
        }
    }
    
    func getTaskCategories(completion: @escaping () -> Void) {
        if User.currentUser() != nil {
            homeManager.getAllTaskCategories { (categories) in
                self.categoriesVisible = categories
                completion()
            }
        }
    }
    
    func loadTask(completion: @escaping () -> Void) {
        homeManager.getDisplayTasksWithNoFilter { (taskList, isCached, errorOpt) in
            if let error = errorOpt {
                self.hideLoader { _ in
                    switch error {
                    case .noNetwork:
                        self.showBanner(withTitle: "error_reachability".localized, withColor: .redPink)
                    default:
                        self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                    }
                    completion()
                }
            } else if let taskList = taskList {
                self.tasksAllFilter = taskList
                self.filterTaskToDisplay()
                DispatchQueue.main.async {
                    UIView.performWithoutAnimation {
                        self.tableViewContent.reloadData({
                            if !isCached {
                                self.hideLoader { _ in completion() }
                            }
                        })
                    }
                }
            } else {
                self.hideLoader { _ in
                    self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                    completion()
                }
            }
        }
    }
    
    func filterTaskToDisplay() {
        self.tasksToDisplay = self.tasksAllFilter.applyGCIDashboardFilters()
        self.imgFilterActivated.isHidden = !UserDataFilter.unique.isFilterActivated
        if let user = User.currentUser() {
            if let category = self.selectedCategory {
                self.tasksToDisplay = self.tasksToDisplay.filter({$0.category(forUser: user) == category })
            }
        }
    }
    
    @objc func pullToRefreshData(_ sender: Any) {
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
                    break
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
                
                self.getTaskCategories {
                    self.loadTask {
                        if self.tableViewContent.visibleCells.count > 0 {
                            self.getLocation()
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func getLocation() {
        LocationHelper.shared.refresh {
                if self.tableViewContent.numberOfSections > 1 {
                    DispatchQueue.main.async {
                        UIView.performWithoutAnimation {
                            self.tableViewContent.reloadSections(IndexSet(integer: 1), with: .none)
                        }
                    }
                }
        }
    }
}

extension HomeViewController {
    @IBAction func btnShortcutTouched(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            UserDataFilter.unique.urgentOnly = !UserDataFilter.unique.urgentOnly
        case 1:
            UserDataFilter.unique.lateOnly = !UserDataFilter.unique.lateOnly
        case 2:
            UserDataFilter.unique.favoritesOnly = !UserDataFilter.unique.favoritesOnly
        default:
            break
        }
        
        self.filterTaskToDisplay()
        if UIDevice.current.userInterfaceIdiom == .pad && (currentOrientation == UIDeviceOrientation.landscapeLeft || currentOrientation == UIDeviceOrientation.landscapeRight) {
            self.tableViewContent.reloadData()
        } else {
            self.tableViewContent.reloadSections(IndexSet(integer: 1), with: .automatic)
        }
        
    }
    
    @IBAction func btnMapTouched(_ sender: Any) {
        guard let mapViewController = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as? MapViewController  else {
            self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
            return
        }
        mapViewController.selectedCategory = self.selectedCategory
        mapViewController.didSelectTask = { task in
            if let task = task {
                self.lauchDetailTaskView(withTask: task)
            } else {
                self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
            }
        }
        mapViewController.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(mapViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnFilterTouched(_ sender: Any) {
        guard let filterViewController = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalFilterViewController") as? ModalFilterViewController  else {
            self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
            return
        }
        
        filterViewController.initFilter(withStatusFilters: false)
        filterViewController.didValidate = {
            self.displayLoader { _ in
                self.loadTask {
                    UIView.performWithoutAnimation {
                        self.hideLoader { _ in
                            Constant.haveToRefreshFilterListTask = true
                            self.tableViewContent.reloadData()
                        }
                    }
                }
            }
        }
        filterViewController.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(filterViewController, animated: true, completion: nil)
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func configureTableView() {
        self.tableViewContent.backgroundColor = UIColor.clear
        self.tableViewContent.tableFooterView = UIView(frame: CGRect.zero)
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 1000))
        footerView.backgroundColor = UIColor.lightPeriwinkle
        self.tableViewContent.tableFooterView?.addSubview(footerView)
        
        tableViewContent.register(UINib(nibName: "HomeHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "homeHeaderCell")
        tableViewContent.register(UINib(nibName: "HomeTaskTableViewCell", bundle: nil), forCellReuseIdentifier: "homeTaskCell")
        
        tableViewContent.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        refreshControl.tintColor = .white
        tableViewContent.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(pullToRefreshData(_:)), for: .valueChanged)
        
        setupTopColored(inScrollView: tableViewContent, withColor: configuration?.mainColor ?? .lightPeriwinkle)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if UIDevice.current.userInterfaceIdiom == .pad && (currentOrientation == UIDeviceOrientation.landscapeLeft || currentOrientation == UIDeviceOrientation.landscapeRight) {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UIDevice.current.userInterfaceIdiom == .pad && (currentOrientation == UIDeviceOrientation.landscapeLeft || currentOrientation == UIDeviceOrientation.landscapeRight) {
            return tasksToDisplay.count
        } else {
            switch section {
            case 0:
                return 1
            case 1:
                return tasksToDisplay.count
            default:
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && !(UIDevice.current.userInterfaceIdiom == .pad &&  (currentOrientation == UIDeviceOrientation.landscapeLeft || currentOrientation == UIDeviceOrientation.landscapeRight)) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "homeHeaderCell") as! HomeHeaderTableViewCell
            cell.setCell(withTaskCategories: categoriesVisible, forTaskList: tasksAllFilter, isFilterActive: UserDataFilter.unique.isFilterActivated, categorySelected: self.selectedCategory)
            
            cell.onSelectCategory = { [unowned self] category in
                self.selectedCategory = category
                self.filterTaskToDisplay()
                DispatchQueue.main.async {
                    UIView.performWithoutAnimation {
                        self.tableViewContent.reloadData()
                    }
                }
            }
            
            cell.onTouchFilters = { [unowned self] in
                self.btnFilterTouched(self)
            }
            
            cell.clipsToBounds = false
            
            return cell
        } else {
            if tasksToDisplay.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "homeTaskCell") as! HomeTaskTableViewCell
                cell.setCell(withTask: tasksToDisplay[indexPath.row])
                cell.delegate = self
                cell.clipsToBounds = false
                return cell
            } else {
                return UITableViewCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if UIDevice.current.userInterfaceIdiom == .pad && (currentOrientation == UIDeviceOrientation.landscapeLeft || currentOrientation == UIDeviceOrientation.landscapeRight) {
            viewShortcutHeader.frame = CGRect(x: 0, y: 0, width: self.tableViewContent.width, height: 118)
            return viewShortcutHeader
        } else {
            switch section {
            case 1:
                viewShortcutHeader.frame = CGRect(x: 0, y: 0, width: self.tableViewContent.frame.width, height: 60)
                return viewShortcutHeader
            default:
                return nil
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad && (currentOrientation == UIDeviceOrientation.landscapeLeft || currentOrientation == UIDeviceOrientation.landscapeRight) { //ipad landscape
            let task = tasksToDisplay[indexPath.row]
            var size: CGFloat = 130

            if let name = task.interventionType?.name {
                size += name.heightInsideLabel(withFont: UIFont.gciFontBold(16), andWidth: self.tableViewContent.width - 340)
            } else if let name = task.interventionTypeComment {
                size += name.heightInsideLabel(withFont: UIFont.gciFontBold(16), andWidth: self.tableViewContent.width - 340)
            }

            size = (task.dueDate != nil) ? size : size - 15

            if let location = task.location, !location.address.isEmpty {
                size += location.address.heightInsideLabel(withFont: UIFont.gciFontBold(13), andWidth: self.view.width - 100)
            }
            return size
        } else {
            switch indexPath.section {
            case 0:
                let itemSize = UICollectionView.itemSize(totalWidth: self.tableViewContent.frame.width, itemsPerRow: 3, collectionInsets: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10), horizontalSpaceBetweenItem: 6)

                if categoriesVisible.count == 0 {
                  return 100
                } else if categoriesVisible.count > 3 {
                  return itemSize.height * 2 + 130
                } else {
                  return itemSize.height + 130
                }
            case 1:
                let task = tasksToDisplay[indexPath.row]
                var size: CGFloat = 150
                if let name = task.interventionType?.name {
                    size += name.heightInsideLabel(withFont: UIFont.gciFontBold(16), andWidth: self.tableViewContent.width - 100.0 - (DeviceType.isIpad ? 180.0 : 0))
                } else if let name = task.interventionTypeComment {
                    size += name.heightInsideLabel(withFont: UIFont.gciFontBold(16), andWidth: self.tableViewContent.width - 100.0 - (DeviceType.isIpad ? 180.0 : 0))
                }

                size = (task.dueDate != nil) ? size : size - 15

                if let location = task.location, !location.address.isEmpty {
                    //ajoute une distance fictive pour la marge
                    size += "A 100km - \(location.address)".heightInsideLabel(withFont: UIFont.gciFontBold(13), andWidth: self.view.width - 100)
                }
                return size
            default:
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad && (currentOrientation == UIDeviceOrientation.landscapeLeft || currentOrientation == UIDeviceOrientation.landscapeRight) {
            return 118
        } else {
            switch section {
            case 1:
                return 60
            default:
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 || (UIDevice.current.userInterfaceIdiom == .pad && (currentOrientation == UIDeviceOrientation.landscapeLeft || currentOrientation == UIDeviceOrientation.landscapeRight)) {
            let selectedTask = tasksToDisplay[indexPath.row]
            self.lauchDetailTaskView(withTask: selectedTask)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.tableViewContent.deselectRow(at: indexPath, animated: true)
            })
        }
    }
    
    func lauchDetailTaskView(withTask task: TaskViewModel) {
        let storyboard = UIStoryboard(name: "DetailTask", bundle: nil)
        if let detailTaskViewController = storyboard.instantiateViewController(withIdentifier: "detailTaskViewController") as? DetailTaskViewController {
            detailTaskViewController.selectedTask = task
            detailTaskViewController.delegate = self
            self.hideLoader { _ in
                self.navigationController?.pushViewController(detailTaskViewController)
            }
        }
    }
}

extension HomeViewController: HomeTaskTableViewCellDelegate {
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

extension HomeViewController: DetailTaskProtocol {
    func displayMessage(message: String) {
        self.showBanner(withTitle: message, withColor: .green)
    }
}
