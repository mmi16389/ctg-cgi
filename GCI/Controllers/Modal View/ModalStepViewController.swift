//
//  ModalStepViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 24/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class ModalStepViewController: AbstractViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnValidate: GCIButton!
    
    typealias Action = (_ title: String, _ comment: String, _ date: Date, _ attachment: URL?, _ originAttachment: AttachmentViewModel?) -> Void
    private var displayCell = [DataCell]()
    private var titleStep: String = ""
    private var comment: String = ""
    private var date: Date = Date()
    private var attachment: ViewableAttachment?
    private var isFromCamera = false
    private var actionOnValidate: Action?
    private var editViewableStep: ViewableStep?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.setInterface()
        self.setText()
        self.configureTableview()
        self.setDisplayCell()
        
        self.btnValidate.isEnabled = isNextAvailable()
    }

    func setInterface() {
        self.viewHeader.backgroundColor = configuration?.mainColor ?? UIColor.cerulean
    }
    
    func initModal(editStep: ViewableStep? = nil, actionOnValidate: @escaping Action) {
        self.actionOnValidate = actionOnValidate
        
        if let step = editStep {
            self.date = step.date
            self.attachment = step.displayableAttachment
            self.isFromCamera = false
            self.comment = step.description
            self.titleStep = step.title
            self.editViewableStep = step
            
            self.setDisplayCell()
        }
    }
    
    func setText() {
        self.lblTitle.font = UIFont.gciFontBold(17)
        self.lblTitle.textColor = UIColor.white
        if let _ = editViewableStep {
            self.lblTitle.text = "task_action_step_edit".localized
        } else {
            self.lblTitle.text = "task_action_step_custom".localized
        }
        
        self.btnValidate.setTitle("general_valdiate".localized, for: .normal)
    }
    
    func isNextAvailable() -> Bool {
        if !self.titleStep.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func btnNextTouched(_ sender: Any) {
        self.btnValidate.becomeFirstResponder()
        
        if comment == "steps_page_description_hint".localized {
            comment = ""
        }
        
        if let url = attachment?.fileUrl, let editViewableStep = editViewableStep { //si created && edit step
            if url == editViewableStep.displayableAttachment?.fileUrl { //si created == edit
                self.actionOnValidate?(titleStep, comment, date, nil, editViewableStep.displayableAttachment?.synchronizedAttachment)
            } else {
                self.actionOnValidate?(titleStep, comment, date, url, editViewableStep.displayableAttachment?.synchronizedAttachment)
            }
        } else if let _ = editViewableStep {
            self.actionOnValidate?(titleStep, comment, date, nil, nil)
        } else {
            self.actionOnValidate?(titleStep, comment, date, attachment?.fileUrl, nil)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goBackTouched(_ sender: Any) {
        self.deleteAnAttachement()
        self.dismiss(animated: true, completion: nil)
    }
}

extension ModalStepViewController: UITableViewDelegate, UITableViewDataSource {
    
    func configureTableview() {
        tableView.register(UINib(nibName: "DetailTaskTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTaskTitleCell")
        tableView.register(UINib(nibName: "TextviewTableViewCell", bundle: nil), forCellReuseIdentifier: "TextviewCell")
        tableView.register(UINib(nibName: "TextfieldTableViewCell", bundle: nil), forCellReuseIdentifier: "TextfieldCell")
        tableView.register(UINib(nibName: "SpaceTableViewCell", bundle: nil), forCellReuseIdentifier: "SpaceCell")
        tableView.register(UINib(nibName: "PickerAttachementTableViewCell", bundle: nil), forCellReuseIdentifier: "PickerAttachementCell")
    }
    
    func setDisplayCell() {
        displayCell.removeAll()
        displayCell.append(DataCell(typeCell: .taskTitle, title: "steps_page_date".localized))
        
        displayCell.append(DataCell(typeCell: .textfieldDateHourPicker, prefilledText: "general_date_with_time".localized(arguments: self.date.toDateString(style: .full), self.date.toTimeString(style: .short)).capitalizingFirstLetter(), isTextFieldEditable: true))
        displayCell.append(DataCell(typeCell: .taskTitle, title: "steps_page_title".localized))
        displayCell.append(DataCell(typeCell: .textfield, placeHolder: "reject_page_title_hint".localized, prefilledText: self.titleStep, isTextFieldEditable: true, charLimitation: 50))
        displayCell.append(DataCell(typeCell: .textview, placeHolder: "steps_page_description_hint".localized, prefilledText: self.comment, isTextFieldEditable: true, charLimitation: 500))
        
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
        case.textfield:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextfieldCell") as! TextfieldTableViewCell
            cell.initCell(withPlaceHolder: dataCell.placeHolder, andPrefilledText: dataCell.prefilledText, icon: dataCell.icon, isEditable: dataCell.isTextFieldEditable, parentDelegate: self, limitation: dataCell.charLimitation ?? 0)
            return cell
        case .textfieldDateHourPicker:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextfieldCell") as! TextfieldTableViewCell
            cell.initCellDatePicker(withDefaultDate: self.date, maximumDate: Date(), parentDelegate: self)
            return cell
        case .picker:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PickerAttachementCell") as! PickerAttachementTableViewCell
            cell.initCell(withParentController: self, andAttachment: attachment, isFromCamera: isFromCamera)
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
            var with = self.tableView.width / 2 - 45
            if with > (DeviceType.isIpad ? 320 : 260) {
                with = DeviceType.isIpad ? 320 : 260
            }
            return with
        case .space:
            return 25
        case .textfield, .textfieldDateHourPicker:
            return 85
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataCell = displayCell[indexPath.row]
        dataCell.actionOnTouch?(self.tableView.cellForRow(at: indexPath)!)
    }
}

extension ModalStepViewController: UITextFieldDelegate, UITextViewDelegate, TextfieldTableViewCellDelegate {
    func dateSelected(date: Date) {
        self.date = date
        self.btnValidate.isEnabled = isNextAvailable()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.comment = textView.text ?? ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.titleStep = textField.text ?? ""
        self.btnValidate.isEnabled = isNextAvailable()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            
            self.titleStep =  text.replacingCharacters(in: textRange,
                                                       with: string)
        }
        
        self.btnValidate.isEnabled = isNextAvailable()
        return true
    }
}

extension ModalStepViewController: PickerAttachementDelegate {
    func pickAnAttachement(path: URL, fromCamera: Bool) {
        attachment = CreatedAttachmentViewModel(fileName: path.lastPathComponent)
        isFromCamera = fromCamera
    }
    
    func deleteAnAttachement() {
        if let attachmentURL = attachment?.fileUrl {
            let fileStillExist = (try? attachmentURL.checkResourceIsReachable()) ?? false
            if fileStillExist {
                do {
                    try FileManager.default.removeItem(at: attachmentURL)
                } catch let error {
                    print(error)
                }
            }
            attachment = nil
        }
    }
}
