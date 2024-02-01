//
//  ModalPatrimonySelectionViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 11/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class ModalPatrimonySelectionViewController: AbstractViewController {

    @IBOutlet weak var tableViewContent: UITableView!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var lbltitle: UILabel!
    @IBOutlet weak var lbldescription: UILabel!
    @IBOutlet weak var btnQuit: UIButton!
    @IBOutlet weak var btnValidate: GCIButton!
    
    var listOfPatrimony: [TaskPatrimonyViewModel] = []
    
    typealias Action = (_ selectPatrimony: TaskPatrimonyViewModel, _ patrimonyComment: String) -> Void
    var actionOnValidate: Action?
    var selectedPatrimony: TaskPatrimonyViewModel?
    var patrimonyComment: String = ""
    private var displayCell = [DataCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableViewContent.dataSource = self
        self.tableViewContent.delegate = self
        setInterface()
        setText()
        self.configureTableView()
        self.setTableViewCell()
        
        if isNextAvailable() {
            self.btnValidate.isEnabled = true
        } else {
            self.btnValidate.isEnabled = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setTableViewCell()
        self.tableViewContent.reloadData()
        
        if isNextAvailable() {
            self.btnValidate.isEnabled = true
        } else {
            self.btnValidate.isEnabled = false
        }
    }

    func setInterface() {
        self.viewHeader.backgroundColor = configuration?.mainColor ?? UIColor.cerulean
    }
    
    func setText() {
        self.lbltitle.textColor = UIColor.white
        self.lbltitle.font = UIFont.gciFontBold(17)
        self.lbltitle.text = "creation_page_patrimony_title".localized
        
        self.lbldescription.textColor = UIColor.white
        self.lbldescription.font = UIFont.gciFontBold(17)
        self.lbldescription.text = "creation_page_patrimony_explanation".localized
        
        self.btnValidate.setTitle("general_valdiate".localized, for: .normal)
    }
    
    @IBAction func btnQuitTouched(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func isNextAvailable() -> Bool {
        if selectedPatrimony != nil {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func btnValidateTouched(_ sender: Any) {
        if let patrimony = self.selectedPatrimony {
            self.dismiss(animated: true) {
                self.actionOnValidate?(patrimony, self.patrimonyComment)
            }
        }
    }
    
    func presentPatrimonyModalView() {
        if listOfPatrimony.count > 0 {
            
            var hasSelectedIndex = [Int]()
                if let selectedPatrimony = selectedPatrimony, let index = listOfPatrimony.firstIndex(of: selectedPatrimony) {
                    
                    hasSelectedIndex.append(index)
                }
            
            self.launchModal(withTitle: "creation_page_select_patrimony".localized,
                             buttonText: "general_valdiate".localized,
                             listOfChoice: listOfPatrimony,
                             searchPlaceHolder: "creation_search_hint_patrimony".localized,
                             selectedIndex: hasSelectedIndex,
                             isMultiSelection: false,
                             actionOnValidate: { selectedIndex in
                                if let index = selectedIndex.first {
                                    self.selectedPatrimony = self.listOfPatrimony[index]
                                } else {
                                    self.selectedPatrimony = nil
                                }
            })
        }
    }
    
    func launchModal(withTitle title: String, buttonText: String, listOfChoice: [ModalSelectListItemsDataSource], searchPlaceHolder: String, selectedIndex: [Int], isMultiSelection: Bool, actionOnValidate: @escaping ([Int]) -> Void) {
        if let selectView = UIStoryboard(name: "ModalsStoryboard", bundle: nil).instantiateViewController(withIdentifier: "ModalSelectListViewController") as? ModalSelectListViewController {
            selectView.modalPresentationStyle = .fullScreen
            selectView.initModal(withTitle: title,
                                 buttonText: buttonText,
                                 listOfChoice: listOfChoice,
                                 searchPlaceHolder: searchPlaceHolder,
                                 isMultiSelection: isMultiSelection,
                                 selectedIndex: selectedIndex,
                                 isShowIndex: false,
                                 actionOnValidate: actionOnValidate)
            DispatchQueue.main.async {
                self.present(selectView, animated: true, completion: nil)
            }
        }
    }
}

extension ModalPatrimonySelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func configureTableView() {
       tableViewContent.register(UINib(nibName: "DetailTaskTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTaskTitleCell")
        tableViewContent.register(UINib(nibName: "TextfieldTableViewCell", bundle: nil), forCellReuseIdentifier: "TextfieldCell")
        tableViewContent.register(UINib(nibName: "TextviewTableViewCell", bundle: nil), forCellReuseIdentifier: "TextviewCell")
    }
    
    func setTableViewCell() {
        self.displayCell.removeAll()
        displayCell.append(DataCell(typeCell: .taskTitle, title: "creation_page_field_patrimony_title".localized))
        
        displayCell.append(DataCell(typeCell: .textfield, icon: UIImage(named: "ico_open_list"), placeHolder: "creation_page_select_patrimony".localized, prefilledText: selectedPatrimony?.key ?? "", actionOnTouch: { _ in
            self.presentPatrimonyModalView ()
        }))
        
        displayCell.append(DataCell(typeCell: .taskTitle, title: "creation_page_field_commentary_title".localized))
        
        displayCell.append(DataCell(typeCell: .textview, placeHolder: "creation_page_field_commentary_hint".localized, prefilledText: patrimonyComment, isTextFieldEditable: true, charLimitation: 500))
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
            cell.initCell(withPlaceHolder: dataCell.placeHolder, andPrefilledText: dataCell.prefilledText, icon: dataCell.icon, isEditable: dataCell.isTextFieldEditable, parentDelegate: self, limitation: dataCell.charLimitation ?? 0)
            return cell
        case.textfield:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextfieldCell") as! TextfieldTableViewCell
            cell.initCell(withPlaceHolder: dataCell.placeHolder, andPrefilledText: dataCell.prefilledText, icon: dataCell.icon, isEditable: dataCell.isTextFieldEditable)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch displayCell[indexPath.row].typeCell {
        case .taskTitle:
            return 40
        case .textview:
            return 200
        case .textfield:
            return 85
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataCell = displayCell[indexPath.row]
        dataCell.actionOnTouch?(self.tableViewContent.cellForRow(at: indexPath)!)
    }
}

extension ModalPatrimonySelectionViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if let text = textView.text, !text.isEmpty {
            self.patrimonyComment = text
        }
    }
}
