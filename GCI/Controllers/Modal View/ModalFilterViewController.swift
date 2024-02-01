//
//  ModalFilterViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 08/07/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class ModalFilterViewController: AbstractViewController {

    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionViewContent: UICollectionView!
    @IBOutlet weak var btnFilter: GCIButton!
    
    typealias Validate = () -> Void
    var didValidate: Validate?
    
    private var hasStatusFilter = true
    private var hasVisibilityFilter = true
    private var listOfTasks: [TaskViewModel] = []
    private var listOfCategory: [TaskViewModel.Status] = []
    private var listOfServices: [ServiceViewModel] = []
    
    private var selectedVisibility: UserDataFilter.Visibility?
    private var listOfSelectedStatus = [TaskViewModel.Status]()
    private var listOfSelectedServices = [Int]()
    private var selectedStartDate: Date?
    private var selectedEndDate: Date?
    
    private let homeManager = HomeManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setText()
        self.setInterface()
        self.configureCollectionView()
        
        self.collectionViewContent.delegate = self
        self.collectionViewContent.dataSource = self
        
        self.selectedStartDate = UserDataFilter.unique.startDate
        self.selectedEndDate = UserDataFilter.unique.endDate
        self.listOfSelectedStatus = UserDataFilter.unique.statusList
        self.listOfSelectedServices = UserDataFilter.unique.serviceList
        self.selectedVisibility = UserDataFilter.unique.visibility
        self.searchText.text = UserDataFilter.unique.fullText
        
        self.homeManager.getAllTask { (taskList, success, error) in
            if let taskList = taskList {
                self.listOfTasks = taskList
                self.prepareList()
                self.collectionViewContent.reloadData()
            } else {
                self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
            }
        }
    }

    func setInterface() {
        self.viewBackground.backgroundColor = UIColor.cerulean.withAlphaComponent(0.95)
    }
    
    func setText() {
        self.lblTitle.font = UIFont.gciFontBold(16)
        self.lblTitle.textColor = UIColor.white
        
        self.searchText.font = UIFont.gciFontRegular(13)
        self.searchText.textColor = UIColor.white
        self.searchText.placeholder = "filter_by_text_placeholder".localized
        self.searchText.setPlaceHolderTextColor(UIColor.white)
        self.searchText.tintColor = UIColor.white
        
        self.btnFilter.setTitle("filter_validate".localized, for: .normal)
        self.lblTitle.text = "filter_page_title".localized.uppercased()
    }
    
    func initFilter(withStatusFilters hasStatusFilter: Bool = true, withVisibilityFilters hasVisibilityFilter: Bool = true) {
        self.hasStatusFilter = hasStatusFilter
        self.hasVisibilityFilter = hasVisibilityFilter
    }
    
    func prepareList() {
        listOfCategory = []
        listOfServices = []
        
        listOfTasks.forEach({ (task) in
            if hasStatusFilter {
                if !listOfCategory.contains(task.status) {
                    listOfCategory.append(task.status)
                }
            }
            
            if let service = task.service {
                if !listOfServices.contains(service) {
                    listOfServices.append(service)
                }
            }
        })
        
        listOfServices = listOfServices.sorted {
            let value = $0.name.caseInsensitiveCompare($1.name)
            guard value != .orderedSame else {
                return false
            }
            return value == .orderedAscending
        }
    }
    
    @IBAction func btnFilterTouched(_ sender: Any) {
        if let text = self.searchText.text, !text.isEmpty {
            UserDataFilter.unique.fullText = self.searchText.text
        } else {
            UserDataFilter.unique.fullText = nil
        }
        
        UserDataFilter.unique.startDate = self.selectedStartDate
        UserDataFilter.unique.endDate = self.selectedEndDate
        UserDataFilter.unique.statusList = self.listOfSelectedStatus
        UserDataFilter.unique.serviceList = self.listOfSelectedServices
        UserDataFilter.unique.visibility = self.selectedVisibility
        
        self.didValidate?()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnQuit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ModalFilterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func configureCollectionView() {
        self.collectionViewContent.backgroundColor = UIColor.clear
        
        self.collectionViewContent.contentInset = UIEdgeInsets(top: 0, left: 25, bottom: 25, right: 25)
        self.collectionViewContent.register(UINib(nibName: "FilterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FilterCell")
        self.collectionViewContent.register(UINib(nibName: "SectionTitleFilterCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionTitleFilterView")
        
        self.collectionViewContent.allowsMultipleSelection = true
        
        let alignedFlowLayout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .center)
        self.collectionViewContent.collectionViewLayout = alignedFlowLayout

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if (section == 0 && !hasStatusFilter) || (section == 1 && !hasVisibilityFilter) {
            return CGSize(width: self.collectionViewContent.width, height: 0)
        }
        return CGSize(width: self.collectionViewContent.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 35
        let widthMarge: CGFloat = 38
        let font = UIFont.gciFontMedium(13)
        switch indexPath.section {
        case 0:
            return CGSize(width: listOfCategory[indexPath.row].localizedText.width(withConstrainedHeight: height, font: font) + widthMarge, height: height)
        case 1:
            if indexPath.row == 0 {
                return CGSize(width: "filter_by_visibility_on_map".localized.width(withConstrainedHeight: height, font: font) + widthMarge, height: height)
            } else {
                return CGSize(width: "filter_by_visibility_not_on_map".localized.width(withConstrainedHeight: height, font: font) + widthMarge, height: height)
            }
        case 2:
            return CGSize(width: listOfServices[indexPath.row].displayableTitle.width(withConstrainedHeight: height, font: font) + widthMarge, height: height)
        case 3:
            if indexPath.row == 0 {
                if let startDate = self.selectedStartDate, self.selectedEndDate == nil {
                    return CGSize(width: startDate.toDateString(style: .short).width(withConstrainedHeight: height, font: font) + widthMarge, height: height)
                } else {
                    return CGSize(width: "filter_by_date_date".localized.width(withConstrainedHeight: height, font: font) + widthMarge, height: height)
                }
            } else {
                if let startDate = self.selectedStartDate, let endDate = self.selectedEndDate {
                    return CGSize(width: String(format: "%@ - %@", startDate.toDateString(style: .short), endDate.toDateString(style: .short)).width(withConstrainedHeight: height, font: font) + widthMarge, height: height)
                } else {
                    return CGSize(width: "filter_by_date_range".localized.width(withConstrainedHeight: height, font: font) + widthMarge, height: height)
                }
            }
        default:
            return CGSize(width: 0, height: 0)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: //status
            if self.listOfSelectedStatus.contains(listOfCategory[indexPath.row]) {
                self.listOfSelectedStatus.removeAll { (status) -> Bool in
                    status == listOfCategory[indexPath.row]
                }
            }
        case 1: //visibility
            if let selectedRows = self.collectionViewContent.indexPathsForSelectedItems {
                if selectedRows.contains(indexPath) && indexPath.row == 0 {
                    self.selectedVisibility = .onMap
                } else if selectedRows.contains(indexPath) && indexPath.row == 1 {
                    self.selectedVisibility = .notOnMap
                } else {
                    self.selectedVisibility = .none
                }
            } else {
                self.selectedVisibility = .none
            }
        case 2: //Service
            if self.listOfSelectedServices.contains(listOfServices[indexPath.row].id) {
                self.listOfSelectedServices.removeAll { (serviceID) -> Bool in
                    serviceID == listOfServices[indexPath.row].id
                }
            }
            
        case 3:
            if indexPath.row == 0 {
                self.selectedStartDate = nil
            } else {
                self.selectedStartDate = nil
                self.selectedEndDate = nil
            }
            self.collectionViewContent.reloadItems(at: [indexPath])
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: //status
            if !self.listOfSelectedStatus.contains(listOfCategory[indexPath.row]) {
                self.listOfSelectedStatus.append(listOfCategory[indexPath.row])
            }
        case 1: //visibility
            if let selectedRows = self.collectionViewContent.indexPathsForSelectedItems {
                for selectedRow in selectedRows where selectedRow.section == 1 && selectedRow.row != indexPath.row {
                    self.collectionViewContent.deselectItem(at: selectedRow, animated: true)
                }
                
                if selectedRows.contains(indexPath) && indexPath.row == 0 {
                    self.selectedVisibility = .onMap
                } else if selectedRows.contains(indexPath) && indexPath.row == 1 {
                    self.selectedVisibility = .notOnMap
                } else {
                    self.selectedVisibility = .none
                }
            } else {
                self.selectedVisibility = .none
            }
        case 2: //Service
            if !self.listOfSelectedServices.contains(listOfServices[indexPath.row].id) {
                self.listOfSelectedServices.append(listOfServices[indexPath.row].id)
            }
        case 3: //Date
            if let selectedRows = self.collectionViewContent.indexPathsForSelectedItems {
                for selectedRow in selectedRows where selectedRow.section == 3 && selectedRow.row != indexPath.row {
                    self.collectionViewContent.deselectItem(at: selectedRow, animated: true)
                }
            }
            
            if indexPath.row == 0 {
                self.selectADate { (date) in
                    if let date = date {
                        self.selectedStartDate = date
                        self.selectedEndDate = nil
                        self.collectionViewContent.reloadSections(IndexSet(integer: 3))
                    } else {
                        self.collectionViewContent.deselectItem(at: indexPath, animated: false)
                    }
                }
            } else {
                self.selectADate { (dateStart) in
                    if let dateStart = dateStart {
                        self.selectADate(withMinimumdate: dateStart) { (dateEnd) in
                            if let dateEnd = dateEnd {
                                self.selectedStartDate = dateStart
                                self.selectedEndDate = dateEnd
                                self.collectionViewContent.reloadSections(IndexSet(integer: 3))
                            } else {
                                self.collectionViewContent.deselectItem(at: indexPath, animated: false)
                            }
                        }
                    } else {
                        self.collectionViewContent.deselectItem(at: indexPath, animated: false)
                    }
                }
            }
        default:
            break
        }
    }
    
    func selectADate(withMinimumdate minDate: Date? = nil, completion: @escaping (_ date: Date?) -> Void) {
        if let selectView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalDatePickerViewController") as? ModalDatePickerViewController {
            selectView.modalPresentationStyle = .fullScreen
            selectView.initModal(isHourDisplay: false, minDate: minDate) { (date) in
                completion(date)
            }
            selectView.actionOnCancel = {
                completion(nil)
            }
            
            DispatchQueue.main.async {
                self.present(selectView, animated: true, completion: nil)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: //Status
            return listOfCategory.count
        case 1: //Visibility
            if hasVisibilityFilter {
                return 2
            } else {
                return 0
            }
        case 2: //Service
            return listOfServices.count
        case 3: //Date de création
            return 2
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCollectionViewCell
        switch indexPath.section {
        case 0: //Status
            cell.setCell(withTitle: self.listOfCategory[indexPath.row].localizedText)
            cell.isSelected = self.listOfSelectedStatus.contains(listOfCategory[indexPath.row])
        case 1: //Visibility
            if indexPath.row == 0 {
                cell.setCell(withTitle: "filter_by_visibility_on_map".localized)
                cell.isSelected = self.selectedVisibility == .onMap
            } else {
                cell.setCell(withTitle: "filter_by_visibility_not_on_map".localized)
                cell.isSelected = self.selectedVisibility == .notOnMap
            }
        case 2:  //Service
            cell.setCell(withTitle: self.listOfServices[indexPath.row].displayableTitle)
            cell.isSelected = self.listOfSelectedServices.contains(listOfServices[indexPath.row].id)
        case 3: //Date de création
            if indexPath.row == 0 {
                
                cell.setCell(withTitle: self.selectedStartDate != nil && self.selectedEndDate == nil ? self.selectedStartDate?.toDateString(style: .short) ?? "" : "filter_by_date_date".localized)
                cell.isSelected = self.selectedStartDate != nil && self.selectedEndDate == nil
            } else {
                if let startDate = selectedStartDate, let endDate = selectedEndDate {
                    cell.setCell(withTitle: String(format: "%@ - %@", startDate.toDateString(style: .short), endDate.toDateString(style: .short)))
                } else {
                    cell.setCell(withTitle: "filter_by_date_range".localized)
                }
                cell.isSelected = self.selectedStartDate != nil && self.selectedEndDate != nil
            }
        default:
            break
        }
        
        if cell.isSelected {
            self.collectionViewContent.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition(rawValue: 0))
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionTitleFilterView", for: indexPath) as! SectionTitleFilterCollectionReusableView
        
        switch indexPath.section {
        case 0: //Status
            if listOfCategory.count > 0 {
                header.initCell(withTitle: "filter_by_status".localized)
            } else {
                header.initCell(withTitle: "".localized)
            }
        case 1: //Visibility
            header.initCell(withTitle: "filter_by_visibility".localized)
        case 2: //Service
            if listOfServices.count > 0 {
                header.initCell(withTitle: "filter_by_service".localized)
            }
        case 3: //Date de création
            header.initCell(withTitle: "filter_by_date".localized)
        default:
            break
        }
        
        return header
    }
}
