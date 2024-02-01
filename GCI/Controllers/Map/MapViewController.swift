//
//  MapViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 12/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit
import ArcGIS
import MapKit

class MapViewController: AbstractViewController {

    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var btnQuit: UIButton!
    @IBOutlet weak var viewBtnInfo: UIView!
    @IBOutlet weak var btnInfo: UIButton!
    @IBOutlet weak var viewBtnFilter: UIView!
    @IBOutlet weak var collectionViewTask: UICollectionView!
    @IBOutlet weak var imgFilterActive: UIImageView!
    
    typealias SelectedTaskAction = (_ task: TaskViewModel?) -> Void
    private var displayableTaskCell = [TaskViewModel]()
    private var actionOnViewPointChanged = [ViewPointChangedActions]()
    var selectedTask: TaskViewModel?
    private var listOfTaskMarkerDisplayable = [TaskViewModel]()
    var selectedCategory: TaskCategory?
    private let tasksMarkerGraphicsOverlay = AGSGraphicsOverlay()
    private var arcgisMapLockListener: ArcgisMapLockListener?
    private let mapManager = MapManager()
    private let homeManager = HomeManager()
    private var actionManager = TaskActionnableManager()
    var didSelectTask: SelectedTaskAction?
    private var lastMapScale: Double = -1.0
    private var refreshCluster: DispatchWorkItem?
    var createAndEditManager = CreateAndEditTaskManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Constant.haveToRefresh = false
        self.setInterface()
        self.setMap()
        self.configureCollectionView()
        
        self.actionManager.delegate = self
        self.collectionViewTask.delegate = self
        self.collectionViewTask.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshData()
    }
    
    func refreshData() {
        if let task = selectedTask {
            homeManager.getTask(byId: task.id) { (task, error) in
                if let task = task {
                    self.displayableTaskCell = [task]
                    self.imgFilterActive.isHidden = !UserDataFilter.unique.isFilterMapActivated
                    self.displayableTaskCell = self.displayableTaskCell.applyGCIMapFilters()
                    self.collectionViewTask.reloadData()
                    self.listOfTaskMarkerDisplayable = self.displayableTaskCell
                    self.refreshMarkerOnMap()
                } else {
                    if let error = error {
                        switch error {
                        case .error:
                            self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                        case .denied:
                            self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                        case .noNetwork:
                            self.showBanner(withTitle: "error_banner_internet".localized, withColor: .redPink)
                        case .offlineNotAuthorized:
                            self.showBanner(withTitle: "error_not_in_offline".localized, withColor: .redPink)
                        case .canceled:
                            self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                        case .notRightUsername:
                            self.showBanner(withTitle: "error_licence_code".localized, withColor: .redPink)
                        default:
                            self.displayAlert(withTitle: "error_general".localized, andMessage: "error_network".localized)
                        }
                    } else {
                        self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                    }
                }
            }
        } else {
            self.getAllDisplayableTask()
        }
    }
    
    func getAllDisplayableTask() {
        homeManager.getAllTask { (taskList, isCached, errorOpt) in
            if let error = errorOpt {
                    switch error {
                    case .noNetwork:
                        self.showBanner(withTitle: "error_reachability".localized, withColor: .redPink)
                    default:
                        self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                    }
            } else if let taskList = taskList {
                self.listOfTaskMarkerDisplayable = []
                self.listOfTaskMarkerDisplayable = taskList.applyGCIMapFilters()
                self.imgFilterActive.isHidden = !UserDataFilter.unique.isFilterMapActivated
                
                if let user = User.currentUser() {
                    if let category = self.selectedCategory {
                        self.listOfTaskMarkerDisplayable = self.listOfTaskMarkerDisplayable.filter({$0.category(forUser: user) == category })
                    }
                }
                
                self.refreshMarkerOnMap()
            } else {
                self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
            }
        }
    }

    func setInterface() {
        self.viewBtnInfo.addShadow()
        self.viewBtnInfo.layer.cornerRadius = self.viewBtnInfo.height/2
        
        self.viewBtnFilter.addShadow()
        self.viewBtnFilter.layer.cornerRadius = self.viewBtnFilter.height/2
    }
    
    func setMap() {
        if let actionLocker = ArcgisHelper.initMap(withMapView: self.mapView) {
            actionOnViewPointChanged.append(actionLocker)
        } else {
            self.showBanner(withTitle: "notification_map_not_to_date_title".localized, withColor: .redPink)
        }
        
        self.mapView.touchDelegate = self
        
        self.mapView.viewpointChangedHandler = {
            for action in self.actionOnViewPointChanged {
                action.action?()
            }
            
            if self.selectedTask == nil {
                if let refreshCluster = self.refreshCluster {
                    refreshCluster.cancel()
                }
                self.refreshCluster = DispatchWorkItem {
                    if self.mapView.mapScale != self.lastMapScale {
                        self.lastMapScale = self.mapView.mapScale
                        self.refreshMarkerOnMap()
                    }
                }
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.2, execute: self.refreshCluster!)
            }
        }
    }
    
    func refreshMarkerOnMap() {
        DispatchQueue.main.async {
            self.tasksMarkerGraphicsOverlay.graphics.removeAllObjects()
            
            let clusterHelper = ArcgisClusterHelper(mapview: self.mapView)
            let listOfCluster = clusterHelper.defineCluster(fromListOfTask: self.listOfTaskMarkerDisplayable)
            
            for clusterData in listOfCluster {
                guard let firstTask = clusterData.taskList.first else {
                    continue
                }
                
                if clusterData.taskList.count > 1 {
                    let clusterMarker = clusterData.taskList.filter { $0.isUrgent }.count > 0 ? UIImage(named: "ico_location_map_details_di_full")! : UIImage(named: "ico_location_map_blue_details_di_full")!
                    ArcgisHelper.addClusterMarker(withMapView: self.mapView, onGraphicOverlay: self.tasksMarkerGraphicsOverlay, atLocation: clusterData.center, listOfTasks: clusterData.taskList, withMarkerIcon: clusterMarker, isSelected: self.displayableTaskCell.contains(firstTask) ? true: false)
                } else {
                    ArcgisHelper.addMarker(withMapView: self.mapView, forTask: firstTask, isZoomActive: self.selectedTask != nil ? true : false, onGraphicOverlay: self.tasksMarkerGraphicsOverlay, withMarkerIcon: firstTask.isUrgent ? UIImage(named: "ico_location_map_details_DI")! : UIImage(named: "ico_location_map_blue_details_DI")!, isSelected: self.displayableTaskCell.contains(firstTask) ? true: false)
                }
            }
            
            self.refreshSelectedCell()
        }
    }
    
    func refreshSelectedCell() {
        
        var refreshCell = [TaskViewModel]()
        for task in displayableTaskCell {
            if let index = listOfTaskMarkerDisplayable.firstIndex(of: task) {
                refreshCell.append(listOfTaskMarkerDisplayable[index])
            }
        }
        self.displayableTaskCell = refreshCell
        DispatchQueue.main.async {
            self.collectionViewTask.reloadData()
        }
    }
}

extension MapViewController {
    @IBAction func btnFilterTouched(_ sender: Any) {
        guard let filterViewController = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalFilterViewController") as? ModalFilterViewController  else {
            self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
            return
        }
        
        filterViewController.initFilter(withVisibilityFilters: false)
        filterViewController.didValidate = {
            self.refreshData()
        }
        filterViewController.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(filterViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnInfoTouched(_ sender: Any) {
        self.displayAlert(withTitle: "", andMessage: "map_warning".localized)
    }
    
    @IBAction func btnQuitTouched(_ sender: Any) {
        self.dismiss(animated: true) {
            //
        }
    }
}

extension MapViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func configureCollectionView() {
        self.collectionViewTask.backgroundColor = UIColor.clear
        self.collectionViewTask.register(UINib(nibName: "TaskOnMapCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TaskOnMapCell")
        
        self.collectionViewTask.contentInset = UIEdgeInsets(top: 5, left: 10, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.displayableTaskCell.count == 1 {
            return CGSize(width: self.collectionViewTask.width - 20, height: self.collectionViewTask.height - 10)
        } else {
            return CGSize(width: self.collectionViewTask.width - 60, height: self.collectionViewTask.height - 10)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if displayableTaskCell.count > 0 {
            self.collectionViewTask.isHidden = false
        } else {
            self.collectionViewTask.isHidden = true
        }
        return displayableTaskCell.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currentTask = displayableTaskCell[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskOnMapCell", for: indexPath) as! TaskOnMapCollectionViewCell
        cell.defineCell(WithTask: currentTask)
        cell.delegate = self
        cell.addShadow()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedTask != nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            let task = displayableTaskCell[indexPath.row]
            self.didSelectTask?(task)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension MapViewController: TaskOnMapTableViewCellDelegate {
    func actionTouched(action: TaskAction?, forTask task: TaskViewModel?) {
        guard let task = task, let action = action else {
            self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
            return
        }
        
        self.displayLoader { _ in
            self.actionManager.launch(action: action, forTask: task)
        }
    }
    
    func navigate(toTask task: TaskViewModel?) {
        if let task = task, let location = task.location, !location.address.isEmpty {
            self.launchNavigationGps(toGpsCoordinate: location.point.toCLLocationCoordinate2D(), address: location.address)
        } else {
            self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
        }
    }
    
    func launchNavigationGps(toGpsCoordinate coordinates: CLLocationCoordinate2D, address: String) {
        
        self.displayAlert(withTitle: "", andMessage: "action_confirmation_launch_gps".localized, andValidButtonText: "general_yes".localized, orCancelText: "general_cancel".localized, andNerverAskCode: DialogCode.gps) { (accept) in
            if accept {
                let regionDistance: CLLocationDistance = 1000
                let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
                let option = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
                let placemark = MKPlacemark(coordinate: coordinates)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = address
                mapItem.openInMaps(launchOptions: option)
            }
        }
    }
}

extension MapViewController: AGSGeoViewTouchDelegate {
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        mapManager.getListOfTaskArroundPoint(withScreenPoint: screenPoint, onMapView: self.mapView, inTaskOverlay: self.tasksMarkerGraphicsOverlay) { (listOfTask) in
            if let listOfTask = listOfTask {
                self.displayableTaskCell = listOfTask
                self.refreshMarkerOnMap()
                self.collectionViewTask.reloadData()
            }
        }
    }
}

extension MapViewController: TaskActionnableDelegate {
    func askForEditStepInfo(withCompletion completion: @escaping (ViewableStep, String, String, Date, URL?, AttachmentViewModel?) -> Void) {
        self.hideLoader { _ in
            if let user = User.currentUser(),
                let listOfChoice = self.selectedTask?.displayableAndEditableSteps(forUser: user),
                let selectView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalSelectListViewController") as? ModalSelectListViewController {
                selectView.initModal(withTitle: "task_action_step_edit".localized,
                                     buttonText: "task_action_edit".localized,
                                     listOfChoice: listOfChoice,
                                     isMultiSelection: false,
                                     isShowIndex: false) { (selectedIndexes) in
                                        guard let index = selectedIndexes.first else {
                                            return
                                        }
                                        
                                        if let selectView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalStepViewController") as? ModalStepViewController {
                                            
                                            selectView.initModal(editStep: listOfChoice[index], actionOnValidate: { (title, comment, date, url, oldAttachment) in
                                                self.displayLoader { (_) in
                                                    completion(listOfChoice[index], title, comment, date, url, oldAttachment)
                                                }
                                            })
                                            selectView.modalPresentationStyle = .fullScreen
                                            DispatchQueue.main.async {
                                                self.present(selectView, animated: true, completion: nil)
                                            }
                                        }
                }
                selectView.modalPresentationStyle = .fullScreen
                DispatchQueue.main.async {
                    self.present(selectView, animated: true, completion: nil)
                }
            }
        }
    }
    
    func askForStartOrEndStep(withCompletion completion: @escaping (Date) -> Void) {
        self.hideLoader { _ in
            if let selectView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalDatePickerViewController") as? ModalDatePickerViewController {
                
                selectView.initModal(actionOnValidate: { (date) in
                    self.displayLoader { (_) in
                        completion(date)
                    }
                })
                selectView.modalPresentationStyle = .fullScreen
                DispatchQueue.main.async {
                    self.present(selectView, animated: true, completion: nil)
                }
            }
        }
    }
    
    func askForAddStepInfo(withCompletion completion: @escaping (String, String, Date, URL?) -> Void) {
        self.hideLoader { _ in
            if let selectView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalStepViewController") as? ModalStepViewController {
                
                selectView.initModal(actionOnValidate: { (title, comment, date, url, oldURL) in
                    self.displayLoader { (_) in
                        completion(title, comment, date, url)
                    }
                })
                selectView.modalPresentationStyle = .fullScreen
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
            case .value:
                self.refreshData()
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
                var selectedIndex = -1
                if let assignUser = self.selectedTask?.assigned, let index = userList.firstIndex(of: assignUser) {
                    selectedIndex = index
                }
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
                selectView.modalPresentationStyle = .fullScreen
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
                    explanationView.actionOnValidate = { (title, description, service) in
                        self.displayLoader {_ in
                            completion(title, description, service)
                        }
                    }
                    explanationView.modalPresentationStyle = .fullScreen
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
                    selectView.modalPresentationStyle = .fullScreen
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
            
            explanationView.pageTitleText = title
            explanationView.pageDescriptionText = description
            explanationView.pageValidationText = validationText
            explanationView.prefilledValues = prefilledValues
            explanationView.actionOnValidate = { (title, description, _) in
                self.displayLoader {_ in
                    completion(title, description)
                }
            }
            explanationView.modalPresentationStyle = .fullScreen
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
            
            editView.editTask = task
            editView.actionOnValidate = { task in
                self.displayLoader {_ in
                    completion(task)
                }
            }
            editView.modalPresentationStyle = .fullScreen
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
            editView.modalPresentationStyle = .fullScreen
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
