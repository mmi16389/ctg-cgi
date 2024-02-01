//
//  TextfieldTableViewCell.swift
//  GCI
//
//  Created by Anthony Chollet on 03/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

protocol TextfieldTableViewCellDelegate: class {
    func dateSelected(date: Date)
}

class TextfieldTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: GCITextfield!
    @IBOutlet weak var imgIconFromList: UIImageView!
    
    private let datePicker = UIDatePicker()
    weak var delegate: TextfieldTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func initCell(withPlaceHolder placeHolder: String, andPrefilledText text: String, icon: UIImage?, isEditable: Bool, parentDelegate: UITextFieldDelegate? = nil, limitation: Int = 0) {
        self.textField.placeholder = placeHolder
        self.textField.text = text
        self.textField.delegate = parentDelegate
        self.layoutIfNeeded()
        if let icon = icon {
            setRightViewIcon(icon: icon)
        } else {
            self.textField.rightView = nil
        }
        
        if isEditable {
            self.textField.isEnabled = true
        } else {
            self.textField.isEnabled = false
        }
        textField.defineLimitation(limitation: limitation)
        
        self.layoutIfNeeded()
    }
    
    func initCellDatePicker(withDefaultDate defaultDate: Date, maximumDate: Date, parentDelegate: TextfieldTableViewCellDelegate? = nil) {
        self.textField.rightView = nil
        self.textField.isEnabled = true
        self.textField.textAlignment = .center
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.maximumDate = maximumDate
        datePicker.setDate(defaultDate, animated: false)
        self.textField.text = "general_date_with_time".localized(arguments: datePicker.date.toDateString(style: .full), datePicker.date.toTimeString(style: .short)).capitalizingFirstLetter()
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "general_valdiate".localized, style: .plain, target: self, action: #selector(donedatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "general_cancel".localized, style: .plain, target: self, action: #selector(cancelDatePicker))
        doneButton.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.gciFontBold(16)
            ], for: .normal)
        cancelButton.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.gciFontRegular(16)
            ], for: .normal)
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        self.textField.inputAccessoryView = toolbar
        self.textField.inputView = datePicker
        self.delegate = parentDelegate
        
        self.layoutIfNeeded()
    }
    
    @objc func donedatePicker() {
        self.textField.text = "general_date_with_time".localized(arguments: datePicker.date.toDateString(style: .full), datePicker.date.toTimeString(style: .short)).capitalizingFirstLetter()
        self.delegate?.dateSelected(date: datePicker.date)
        self.endEditing(true)
    }
    
    @objc func cancelDatePicker() {
        self.endEditing(true)
    }
    
    func setRightViewIcon(icon: UIImage) {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.textField.frame.height, height: self.textField.frame.height))
        button.backgroundColor = .clear
        button.setImage(icon, for: .normal)
        let container = UIView(frame: button.frame)
        container.backgroundColor = .clear
        container.addSubview(button)
        self.textField.rightView = container
        self.textField.rightViewMode = .always
    }
}
