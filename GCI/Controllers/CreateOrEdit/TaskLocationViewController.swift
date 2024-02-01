//
//  TaskLocationViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 05/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit
import ArcGIS

class TaskLocationViewController: AbstractCreateOrEditViewController {

    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblStep: UILabel!
    @IBOutlet weak var btnNext: GCIButton!
    @IBOutlet weak var viewBreadcrumb: GCIBreadCrumb!
    @IBOutlet weak var constraintWidthBreadcrumb: NSLayoutConstraint!
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var lblLocalisationInfos: UILabel!
    @IBOutlet weak var btnAddComment: UIButton!
    @IBOutlet weak var textFieldAddress: GCITextfield!
    @IBOutlet weak var viewBackgroundTitle: UIView!
    @IBOutlet weak var tableviewAddressSuggestions: UITableView!
    @IBOutlet weak var constraintTableviewAddressSuggestionsHeight: NSLayoutConstraint!
    
    private var createAndEditManager = CreateAndEditTaskManager()
    private let markerGraphicsOverlay = AGSGraphicsOverlay()
    private var agsFeatureTable: AGSServiceFeatureTable?
    private var patrimonyList: [TaskPatrimonyViewModel]?
    private var isViewAppear = false
    private var zoneLayerOverlay = AGSGraphicsOverlay()
    private var actionOnViewPointChanged = [ViewPointChangedActions]()
    private var isReturnfromPatrimony = false
    private var suggestedAddresses: [AGSGeocodeResult]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setText()
        self.setInterface()
        self.setTableView()
        self.tableviewAddressSuggestions.reloadData()
        self.btnNext.isEnabled = false
        actionOnViewPointChanged = []
        self.setMap()
        
        self.textFieldAddress.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.refreshData()
        
        if let address = self.taskWizzard.getLocation()?.address, !isReturnfromPatrimony {
            self.isViewAppear = true
            self.textFieldAddress.text = address
            
            self.getPoint(fromAddress: address)
        }
        
        self.textFieldDidEndEditing(self.textFieldAddress)
    }
    
    func refreshData() {
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
    
    func setMap() {
        if let actionLocker = ArcgisHelper.initMap(withMapView: self.mapView) {
            actionOnViewPointChanged.append(actionLocker)
        }
        
        if let zoneList = taskWizzard.getDomain()?.zoneList, AppDynamicConfiguration.current()?.mapShouldDisplayZones ?? false {
            let actionZoneVisibility = ArcgisHelper.addLayerZone(withMapView: self.mapView, zoneViewModelList: zoneList, onGraphicOverlay: zoneLayerOverlay)
            actionOnViewPointChanged.append(actionZoneVisibility)
        }
        
        if !taskWizzard.isNewTask || 
            taskWizzard.getDomain()?.defaultService?.permissions.contains(.createtask) == true {
            if taskWizzard.getDomain()?.usePatrimony ?? false, let domainID = taskWizzard.getDomain()?.idPatrimony {
                ArcgisHelper.addLayerPatrimony(withMapView: self.mapView, domainID: domainID) { table in
                    self.agsFeatureTable = table
                }
            }
        }
        
        self.mapView.touchDelegate = self
        
        self.mapView.viewpointChangedHandler = {
            for action in self.actionOnViewPointChanged {
                action.action?()
            }
        }
    }
    
    @objc func mapExtentChanged(_ notification: Notification) {
    // Check if your map scale is equal to zoom level 5
    // Do something...
    }
    
    func setInterface() {
        self.viewHeader.backgroundColor = configuration?.mainColor ?? UIColor.cerulean
        self.viewBreadcrumb.backgroundColor = UIColor.clear
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.viewBackgroundTitle.backgroundColor = UIColor.clear
            let mask = CAGradientLayer()
            mask.startPoint = CGPoint(x: 0.0, y: 0.0)
            mask.endPoint = CGPoint(x: 0.0, y: 1.0)
            mask.colors = [UIColor.white.cgColor, UIColor.white.withAlphaComponent(0.5).cgColor, UIColor.white.withAlphaComponent(0).cgColor]
            mask.locations = [NSNumber(value: 0.0), NSNumber(value: 0.5), NSNumber(value: 1.0)]
            mask.frame = CGRect(x: 0, y: 0, width: self.viewBackgroundTitle.width, height: self.viewBackgroundTitle.height)
           self.viewBackgroundTitle.layer.insertSublayer(mask, at: 0)
        }
    }
    
    func setText() {
        self.lblTitle.font = UIFont.gciFontBold(17)
        self.lblTitle.textColor = UIColor.white
        self.lblTitle.text = "creation_page_location_title".localized
        
        self.lblStep.font = UIFont.gciFontBold(17)
        self.lblStep.textColor = UIColor.white
        self.lblStep.text = "creation_page_step_title".localized(arguments: String(self.wizzardIndex+1))
        
        self.lblLocalisationInfos.font = UIFont.gciFontBold(17)
        self.lblLocalisationInfos.textColor = UIColor.cerulean
        self.lblLocalisationInfos.text = "creation_page_field_location_title".localized
        
        self.btnAddComment.titleLabel?.font = UIFont.gciFontMedium(13)
        self.btnAddComment.setTitleColor(UIColor.cerulean, for: .normal)
        self.btnAddComment.setTitle("creation_page_field_commentary_title".localized, for: .normal)
        
        self.textFieldAddress.placeholder = "creation_page_location_search_hint".localized
        
        self.btnNext.setTitle("general_skip".localized, for: .normal)
    }
    
    func isNextAvailable() -> Bool {
        if taskWizzard.getLocation() != nil {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func addCommentaryTouched(_ sender: Any) {
        guard let commentaryView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalCommentaryViewController") as? ModalCommentaryViewController  else {
            self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
            return
        }
        
        commentaryView.define(withTitle: "creation_page_selection_commentary_title".localized, andLblDescription: "creation_page_field_commentary_title".localized, andTextViewPlaceholder: "creation_page_field_commentary_title".localized, AndExistingCommentary: taskWizzard.locationComment, andValidationButtonLabel: "general_valdiate".localized, charLimitation: 500) { (commentary) in
            self.taskWizzard.locationComment = commentary
            if commentary.isEmpty {
                self.btnAddComment.setTitle("creation_page_field_commentary_title".localized, for: .normal)
            } else {
                self.btnAddComment.setTitle("1 \("task_commentary".localized)", for: .normal)
            }
            self.refreshData()
        }
        commentaryView.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(commentaryView, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnNextTouched(_ sender: Any) {
        if self.taskWizzard.getDomain()?.usePatrimony ?? false {
            if let patrimonyList = patrimonyList, patrimonyList.count > 0 {
                guard let patrimonyView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalPatrimonySelectionViewController") as? ModalPatrimonySelectionViewController  else {
                    self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                    return
                }
                
                self.setAddressForPatrimony {
                    
                    patrimonyView.listOfPatrimony = patrimonyList.sorted(by: { $0.distance ?? 0 < $1.distance ?? 0})
                    patrimonyView.actionOnValidate = { (selectPatrimony, patrimonyComment) in
                        self.taskWizzard.setTaskPatrimony(withTaskPatrimony: selectPatrimony, andComment: patrimonyComment)
                        DispatchQueue.main.async {
                            self.navigateToControllers(index: self.wizzardIndex+1)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.isReturnfromPatrimony = true
                        patrimonyView.modalPresentationStyle = .fullScreen
                        self.present(patrimonyView, animated: true, completion: nil)
                    }
                }
            } else {
                self.showBanner(withTitle: "error_patrimony_not_selected".localized, withColor: .redPink)
            }
        } else {
            self.navigateToControllers(index: self.wizzardIndex+1)
        }
    }
    
    func setAddressForPatrimony(completion: () -> Void) {
        if let patrimonyList = patrimonyList {
            for patrimony in patrimonyList {
                if let point = patrimony.feature?.geometry?.extent.center {
                    createAndEditManager.getAddressFromPoint(point: point) { (address, error) in
                        patrimony.address = address ?? ""
                    }
                }
            }
            completion()
        }
    }
    
    @IBAction func goBackTouched(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension TaskLocationViewController: UITextFieldDelegate {
    
    func addPointOnMap(point: AGSPoint) {
        self.markerGraphicsOverlay.graphics.removeAllObjects()
        ArcgisHelper.addMarker(withMapView: self.mapView, onGraphicOverlay: self.markerGraphicsOverlay, atLocation: point, isZoomActive: true)
    }
    
    func getPoint(fromAddress address: String) {
        createAndEditManager.getPointFromAddress(address: address) { (addresses, error) in
            if let error = error {
                self.hideLoader { _ in
                    switch error {
                    case .noAddressFound:
                        self.showBanner(withTitle: "creation_page_location_address_not_found".localized, withColor: .redPink)
                    default:
                        self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                    }
                }
            } else {
                self.hideLoader { _ in
                    if let addresses = addresses {
                        if addresses.count == 1, let address = addresses.first, let point = address.displayLocation {
                            self.setLocation(withAddress: address.getAddressToSave(), andPoint: point)
                        } else {
                            self.suggestedAddresses = addresses
                            self.tableviewAddressSuggestions.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func setLocation(withAddress address: String, andPoint point: AGSPoint) {
        if let srid = point.spatialReference?.wkid {
            if let domain = self.taskWizzard.pointInZone(withPoint: point) {
                DispatchQueue.main.async {
                    self.addPointOnMap(point: point)
                    self.taskWizzard.setLocation(withLocation: TaskLocationViewModel(srid: srid, point: point, address: address, comment: self.taskWizzard.locationComment), andZone: domain)
                    self.textFieldAddress.text = address
                    
                    self.addPointOnMap(point: point)
                    
                    self.getPatrimony(point: point) {
                        self.hideLoader { _ in
                            self.refreshData()
                        }
                    }
                    self.suggestedAddresses = nil
                    self.tableviewAddressSuggestions.reloadData()
                }
            } else {
                self.hideLoader { _ in
                    self.showBanner(withTitle: "creation_page_location_search_error".localized, withColor: .redPink)
                }
            }
        } else {
            self.hideLoader { _ in
                self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
            }
        }
    }
    
    func getPatrimony(point: AGSPoint, withCompletion completion: @escaping () -> Void) {
        if self.taskWizzard.getDomain()?.usePatrimony ?? false, let domainID = self.taskWizzard.getDomain()?.idPatrimony, let table = self.agsFeatureTable {
            self.createAndEditManager.getPatrimonyListAroundPoint(withPoint: point, inTable: table, domainID: domainID, completion: { (patrimonyList) in
                self.patrimonyList = patrimonyList
                completion()
            })
        } else {
            completion()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            if !isViewAppear && !self.isReturnfromPatrimony {
                self.getPoint(fromAddress: text)
            } else {
                self.isReturnfromPatrimony = false
                self.isViewAppear = false
            }
        }
    }
}

extension TaskLocationViewController: AGSGeoViewTouchDelegate {
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        self.displayLoader()
        
        createAndEditManager.getAddressFromPoint(point: self.mapView.screen(toLocation: screenPoint)) { (address, error) in
            if let address = address, !address.isEmpty {
                self.setLocation(withAddress: address, andPoint: mapPoint)
            } else if let error = error {
                self.hideLoader { _ in
                    switch error {
                    case .noNetwork:
                        self.showBanner(withTitle: "error_reachability".localized, withColor: .redPink)
                    default:
                        self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                    }
                }
            } else {
                self.hideLoader { _ in
                    self.showBanner(withTitle: "creation_page_location_search_error".localized, withColor: .redPink)
                }
            }
        }
    }
}

extension TaskLocationViewController: UITableViewDelegate, UITableViewDataSource {
    func setTableView() {
        self.tableviewAddressSuggestions.delegate = self
        self.tableviewAddressSuggestions.dataSource = self
        self.tableviewAddressSuggestions.layer.cornerRadius = 5
        
        self.tableviewAddressSuggestions.register(UINib(nibName: "SuggestedItemTableViewCell", bundle: nil), forCellReuseIdentifier: "SuggestedItemTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let addresses = suggestedAddresses {
            self.view.layoutIfNeeded()
            self.tableviewAddressSuggestions.isHidden = false
            return addresses.count
        } else {
            self.tableviewAddressSuggestions.isHidden = true
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestedItemTableViewCell") as! SuggestedItemTableViewCell
        cell.setText(withText: (suggestedAddresses?[safe: indexPath.row]?.getAddressToSave()) ?? "", withFont: UIFont.gciFontRegular(15), withAlignment: .left)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let agsAddress = self.suggestedAddresses?[safe: indexPath.row], let point = agsAddress.displayLocation {
            self.setLocation(withAddress: agsAddress.getAddressToSave(), andPoint: point)
        }
    }
}
