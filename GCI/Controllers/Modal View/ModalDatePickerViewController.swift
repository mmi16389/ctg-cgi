//
//  ModalDatePickerViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 25/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class ModalDatePickerViewController: UIViewController {

    @IBOutlet weak var btnValidate: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var lblSelectedDate: UILabel!
    @IBOutlet weak var viewToolbar: UIView!
    @IBOutlet weak var viewBottom: UIView!
    
    typealias Action = (_ date: Date) -> Void
    typealias ActionCancel = () -> Void
    private var actionOnValidate: Action?
    var actionOnCancel: ActionCancel?
    private var isHourDisplay: Bool = true
    private var minDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.datePicker.maximumDate = Date()
        self.datePicker.setDate(Date(), animated: false)
        
        self.setText()
        self.setinterface()
    }
    
    func setinterface() {
        self.viewBackground.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.datePicker.textColor = UIColor.charcoalGrey
        self.datePicker.backgroundColor = UIColor.white
        self.viewBottom.backgroundColor = UIColor.white
        self.viewToolbar.backgroundColor = UIColor.white
        if isHourDisplay {
           self.datePicker.datePickerMode = .dateAndTime
        } else {
           self.datePicker.datePickerMode = .date
        }
        
        if let minDate = minDate {
            self.datePicker.minimumDate = minDate
        }
    }
    
    func setText() {
        self.btnValidate.titleLabel?.font = UIFont.gciFontMedium(15)
        self.btnCancel.titleLabel?.font = UIFont.gciFontMedium(15)
        self.lblSelectedDate.font = UIFont.gciFontRegular(18)
        
        self.btnValidate.setTitleColor(UIColor.cerulean, for: .normal)
        self.btnCancel.setTitleColor(UIColor.cerulean, for: .normal)
        self.lblSelectedDate.textColor = UIColor.charcoalGrey
        
        self.btnValidate.setTitle("general_valdiate".localized, for: .normal)
        self.btnCancel.setTitle("general_cancel".localized, for: .normal)
        if isHourDisplay {
            self.lblSelectedDate.text = "\(datePicker.date.toDateString(style: .full)) \(datePicker.date.toTimeString(style: .short))"
        } else {
            self.lblSelectedDate.text = "\(datePicker.date.toDateString(style: .full))"
        }
    }

    func initModal(isHourDisplay: Bool = true, minDate: Date? = nil, actionOnValidate: @escaping Action) {
        self.isHourDisplay = isHourDisplay
        self.actionOnValidate = actionOnValidate
        self.minDate = minDate
    }

    @IBAction func btnNextTouched(_ sender: Any) {
        self.actionOnValidate?(self.datePicker.date)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goBackTouched(_ sender: Any) {
        self.actionOnCancel?()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func datePickedValueChanged(_ sender: Any) {
        if isHourDisplay {
            self.lblSelectedDate.text = "\(datePicker.date.toDateString(style: .full)) \(datePicker.date.toTimeString(style: .short))"
        } else {
            self.lblSelectedDate.text = "\(datePicker.date.toDateString(style: .full))"
        }
    }
}
