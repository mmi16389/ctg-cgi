//
//  TaskActionTableViewCell.swift
//  GCI
//
//  Created by Anthony Chollet on 23/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

protocol TaskActionTableViewCellDelegate: class {
    func taskActionTouched(taskAction: TaskAction?, cell: TaskActionTableViewCell)
}

class TaskActionTableViewCell: UITableViewCell {
    
    weak var delegate: TaskActionTableViewCellDelegate?

    @IBOutlet weak var lblActionName: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!
    
    var taskAction: TaskAction?
    private var isDisabled: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setInterface()
        
        let recognizer = UITapGestureRecognizer(target: self,
                                                action: #selector(touchIconOrLabel(recognizer:)))
        self.lblActionName.addGestureRecognizer(recognizer)
        
        let recognizer2 = UITapGestureRecognizer(target: self,
                                                action: #selector(touchIconOrLabel(recognizer:)))
        self.imgIcon.addGestureRecognizer(recognizer2)
    }

    func setInterface() {
        self.lblActionName.font = UIFont.gciFontBold(16)
        self.lblActionName.textColor = .white
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.alpha = 0.5
        } else {
            self.alpha = 1
        }
    }
    
    func disableCell() {
        self.imgIcon.alpha = 0.4
        self.lblActionName.alpha = 0.4
        isDisabled = true
    }
    
    func enableCell() {
        self.imgIcon.alpha = 1
        self.lblActionName.alpha = 1
        isDisabled = false
    }
    
    func initCell(withTask task: TaskAction) {
        self.taskAction = task
        self.lblActionName.text = task.title
        self.imgIcon.image = task.icon
    }
    
    @objc func touchIconOrLabel(recognizer: UITapGestureRecognizer) {
        if !isDisabled {
            self.setSelected(true, animated: true)
            delegate?.taskActionTouched(taskAction: self.taskAction, cell: self)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.setSelected(false, animated: true)
            })
        }
    }
}
