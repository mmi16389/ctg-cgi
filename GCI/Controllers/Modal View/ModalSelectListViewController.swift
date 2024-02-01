//
//  ModalSelectListViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 03/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

protocol ModalSelectListItemsDataSource: class {
    var displayableTitle: String { get }
    var displayableSubtitle: String? { get }
    var displayableAnnotation: String? { get }
}

class ModalSelectListViewController: AbstractViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableViewContent: UITableView!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var lbltitle: UILabel!
    @IBOutlet weak var btnQuit: UIButton!
    @IBOutlet weak var textField: GCITextfield!
    @IBOutlet weak var btnValidate: GCIButton!
    
    typealias Action = (_ selectedElements: [Int]) -> Void
    private var viewTitle: String = ""
    private var buttonText: String = ""
    private var listOfChoice: [ModalSelectListItemsDataSource] = []
    private var listOfChoiceFiltered: [ModalSelectListItemsDataSource] = []
    private var searchPlaceHolder: String?
    private var isMultiSelection: Bool = false
    private var selectedIndex = [IndexPath]()
    private var isShowIndex = true
    var listOfDisplaybleElement: [String: [ModalSelectListItemsDataSource]]?
    
    var listOfSelectedElement = [ModalSelectListItemsDataSource]()
    var listOfselectedIndex = [Int]()
    var actionOnValidate: Action?
    
    func initModal(withTitle title: String, buttonText: String, listOfChoice: [ModalSelectListItemsDataSource], searchPlaceHolder: String? = nil, isMultiSelection: Bool, selectedIndex: [Int] = [], isShowIndex: Bool = true, actionOnValidate: @escaping Action) {
        self.viewTitle = title
        self.buttonText = buttonText
        self.listOfChoice = listOfChoice
        self.listOfChoiceFiltered = listOfChoice
        self.searchPlaceHolder = searchPlaceHolder
        self.isMultiSelection = isMultiSelection
        self.actionOnValidate = actionOnValidate
        self.isShowIndex = isShowIndex
        
        selectedIndex.forEach { (index) in
            if index != -1, let indexpath = self.indexInDict(index: index) {
                self.selectedIndex.append(indexpath)
            }
        }
    }
    
    func indexInDict(index: Int) -> IndexPath? {
        var sectionIndex = 0
        var indexPath: IndexPath?
        getKeysOrdered().forEach { (key) in
            
            let rowindex = getDisplayableElements()[key]?.firstIndex(where: { (item) -> Bool in
                return item.displayableTitle == listOfChoice[index].displayableTitle
            })
            
            if let index = rowindex {
                indexPath = IndexPath(row: index, section: sectionIndex)
            }
            
            sectionIndex += 1
        }
        
        return indexPath
    }
    
    func indexFromDict(indexPath: IndexPath) -> Int? {
        return self.listOfChoice.firstIndex { (item) -> Bool in
            let key = getKeysOrdered()[indexPath.section]
            return item.displayableTitle == getDisplayableElements()[key]?[indexPath.row].displayableTitle
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableViewContent.dataSource = self
        self.tableViewContent.delegate = self
        setInterface()
        setText()
        self.configureTableView()
    }
    
    func setInterface() {
        self.viewHeader.backgroundColor = configuration?.mainColor ?? UIColor.cerulean
        
        if let searchPlaceHolder = searchPlaceHolder {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: self.textField.frame.height))
            button.backgroundColor = .clear
            button.setImage(UIImage(named: "ico_magnifying_glass"), for: .normal)
            let container = UIView(frame: button.frame)
            container.backgroundColor = .clear
            container.addSubview(button)
            self.textField.rightView = container
            self.textField.rightViewMode = .always
            self.searchPlaceHolder = searchPlaceHolder
            self.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        } else {
            self.textField.removeFromSuperview()
        }
    }
    
    func setText() {
        self.lbltitle.textColor = UIColor.white
        self.lbltitle.font = UIFont.gciFontBold(17)
        
        self.lbltitle.text = viewTitle
        
        self.textField.placeholder = searchPlaceHolder
        
        self.btnValidate.setTitle(buttonText, for: .normal)
    }
    
    @IBAction func btnQuitTouched(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnValidateTouched(_ sender: Any) {
        if let indexList = self.tableViewContent.indexPathsForSelectedRows {
            for indexPath in indexList {
                if let index = self.indexFromDict(indexPath: indexPath) {
                    listOfselectedIndex.append(index)
                }
            }
        }
        
        self.actionOnValidate?(listOfselectedIndex)
        self.dismiss(animated: true)
    }
    
    func getDisplayableElements() -> [String: [ModalSelectListItemsDataSource]] {
        if let listOfElement = self.listOfDisplaybleElement {
            return listOfElement
        } else {
            if !isShowIndex {
                listOfDisplaybleElement = [:]
                listOfDisplaybleElement!["0"] = self.listOfChoiceFiltered
            } else {
                let listOfKey = listOfChoiceFiltered.map {
                    String($0.displayableTitle[$0.displayableTitle.startIndex]).capitalizedFirstLetter
                }
                
                listOfDisplaybleElement = [:]
                listOfKey.forEach { (key) in
                    listOfDisplaybleElement![key] = listOfChoiceFiltered.filter {
                        String($0.displayableTitle[$0.displayableTitle.startIndex]).capitalizedFirstLetter == key
                        }.sorted(by: {
                            let value = $0.displayableTitle.caseInsensitiveCompare($1.displayableTitle)
                            guard value != .orderedSame else {
                                return false
                            }
                            return value == .orderedAscending
                        })
                }
            }
        
            return listOfDisplaybleElement!
        }
    }
    
    func getKeysOrdered() -> [String] {
        return getDisplayableElements().keys.sorted { (lhs, rhs) -> Bool in
            let value = lhs.caseInsensitiveCompare(rhs)
            guard value != .orderedSame else {
                return false
            }
            return value == .orderedAscending
        }
    }
    
    func configureTableView() {
        tableViewContent.register(UINib(nibName: "SelectChoiceTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectChoiceCell")
        
        if isMultiSelection {
            self.tableViewContent.allowsMultipleSelection = true
        } else {
            self.tableViewContent.allowsMultipleSelection = false
        }
        
        self.tableViewContent.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        
        self.tableViewContent.sectionIndexColor = UIColor.cerulean
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let choice = getDisplayableElements()[getKeysOrdered()[indexPath.section]]?[indexPath.row]
        var paddingWith: CGFloat = 90
        if let annotation = choice?.displayableAnnotation, !annotation.isEmpty {
            paddingWith += annotation.width(withConstrainedHeight: 21, font: UIFont.gciFontRegular(14))
        }
        
        var totalheight: CGFloat = 30
        if let title = choice?.displayableTitle {
            totalheight += title.height(withConstrainedWidth: self.tableViewContent.width - paddingWith, font: UIFont.gciFontRegular(17))
        }
        
        if let subtitle = choice?.displayableSubtitle, !subtitle.isEmpty {
            totalheight += subtitle.height(withConstrainedWidth: self.tableViewContent.width - paddingWith, font: UIFont.gciFontRegular(14))
        }
        
        return totalheight
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return getDisplayableElements().keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getDisplayableElements()[getKeysOrdered()[section]]?.count ?? 0
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if isShowIndex {
            return getKeysOrdered()
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectChoiceCell") as! SelectChoiceTableViewCell
        
        if let element = getDisplayableElements()[getKeysOrdered()[indexPath.section]]?[indexPath.row] {
            cell.initCell(withTitle: element.displayableTitle, subtitle: element.displayableSubtitle ?? "", annotation: element.displayableAnnotation ?? "")
        }

        if selectedIndex.contains(indexPath) {
            self.tableViewContent.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if self.tableViewContent.indexPathsForSelectedRows?.contains(indexPath) ?? false {
            self.tableViewContent.deselectRow(at: indexPath, animated: true)
            return nil
        }
        return indexPath
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        for index in self.tableViewContent.indexPathsForSelectedRows ?? [] {
            self.tableViewContent.deselectRow(at: index, animated: true)
        }
        selectedIndex = []
        
        if let searchText = self.textField.text, !searchText.isEmpty {
            listOfChoiceFiltered = listOfChoice.filter { item in
                return item.displayableTitle.lowercased().contains(searchText.lowercased())
            }
        } else {
            listOfChoiceFiltered = listOfChoice
        }
        listOfDisplaybleElement = nil
        
        UIView.performWithoutAnimation {
            self.tableViewContent.reloadData()
        }
    }
}
