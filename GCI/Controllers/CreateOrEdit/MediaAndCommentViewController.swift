//
//  MediaAndCommentViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 05/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class MediaAndCommentViewController: AbstractCreateOrEditViewController {

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
        self.lblTitle.text = "creation_page_media_title".localized
        
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

extension MediaAndCommentViewController: UITableViewDelegate, UITableViewDataSource {
    func configureTableView() {
        tableViewContent.register(UINib(nibName: "DetailTaskTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTaskTitleCell")
        tableViewContent.register(UINib(nibName: "TextviewTableViewCell", bundle: nil), forCellReuseIdentifier: "TextviewCell")
        tableViewContent.register(UINib(nibName: "SpaceTableViewCell", bundle: nil), forCellReuseIdentifier: "SpaceCell")
        tableViewContent.register(UINib(nibName: "PickerAttachementTableViewCell", bundle: nil), forCellReuseIdentifier: "PickerAttachementCell")
    }
    
    func setTableViewCell() {
        displayCell.removeAll()
        
        displayCell.append(DataCell(typeCell: .taskTitle, title: "creation_page_field_commentary_title".localized))

        displayCell.append(DataCell(typeCell: .textview, placeHolder: "creation_page_field_commentary_title".localized, prefilledText: taskWizzard.comment, isTextFieldEditable: true, charLimitation: 500))
        
        displayCell.append(DataCell(typeCell: .picker))
        
        displayCell.append(DataCell(typeCell: .space))
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
        case .picker:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PickerAttachementCell") as! PickerAttachementTableViewCell
            if let attachment = taskWizzard.attachment {
                cell.initCell(withParentController: self, andAttachment: attachment, isFromCamera: taskWizzard.attachementIsFromCamera)
            } else {
                cell.initCell(withParentController: self, andAttachment: taskWizzard.createdAttchment, isFromCamera: taskWizzard.attachementIsFromCamera)
            }
            cell.delegate = self
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
        case .picker:
            var with = self.tableViewContent.width / 2 - 45
            if with > (DeviceType.isIpad ? 320 : 260) {
                with = DeviceType.isIpad ? 320 : 260
            }
            return with
        case .space:
            return 25
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataCell = displayCell[indexPath.row]
        dataCell.actionOnTouch?(self.tableViewContent.cellForRow(at: indexPath)!)
    }
}

extension MediaAndCommentViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if let text = textView.text, !text.isEmpty {
            taskWizzard.comment = text
            setTableViewCell()
            
            if isNextAvailable() {
                self.btnNext.isEnabled = true
            } else {
                self.btnNext.isEnabled = false
            }
        }
    }
}

extension MediaAndCommentViewController: PickerAttachementDelegate {
    func pickAnAttachement(path: URL, fromCamera: Bool) {
        self.taskWizzard.createdAttchment = self.taskWizzard.generateCreatedAttachement(filePath: path)
        self.taskWizzard.attachementIsFromCamera = fromCamera
    }
    
    func deleteAnAttachement() {
        self.taskWizzard.createdAttchment = nil
        self.taskWizzard.attachment = nil
    }
}
