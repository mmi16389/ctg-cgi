//
//  TaskOnMapCollectionViewCell.swift
//  GCI
//
//  Created by Anthony Chollet on 12/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit
import ArcGIS

protocol TaskOnMapTableViewCellDelegate: class {
    func navigate(toTask: TaskViewModel?)
    func actionTouched(action: TaskAction?, forTask task:TaskViewModel?)
}

class TaskOnMapCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var viewTaskID: UIView!
    @IBOutlet weak var lblTaskID: UILabel!
    @IBOutlet weak var lblTaskState: UILabel!
    @IBOutlet weak var lblTaskUrgent: UILabel!
    @IBOutlet weak var lblTaskTitle: UILabel!
    @IBOutlet weak var viewIsUrgent: UIView!
    @IBOutlet weak var lblCreationDate: UILabel!
    @IBOutlet weak var lblDueDate: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var imgIconDate: UIImageView!
    @IBOutlet weak var imgIconLocalisation: UIImageView!
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var btnNavigation: UIButton!
    
    weak var delegate: TaskOnMapTableViewCellDelegate?
    var currentTask: TaskViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setInterface()
        self.setText()
    }
    
    override var isSelected: Bool {
        didSet {
            self.backgroundColor = isSelected ? UIColor.lightPeriwinkle : UIColor.white
        }
    }
    
    func setInterface() {
        self.viewTaskID.backgroundColor = UIColor.tangerine
        self.viewTaskID.roundCorners([UIRectCorner.bottomRight, UIRectCorner.topRight], radius: 5)
        self.viewIsUrgent.layer.cornerRadius = 3
        self.viewIsUrgent.backgroundColor = UIColor.redPink
        self.addShadow()
        self.layer.cornerRadius = 5
        
        self.btnAction.layer.cornerRadius = 4
        self.btnAction.layer.borderWidth = 1
        self.btnAction.layer.borderColor = UIColor.cerulean.cgColor
    }
    
    func setText() {
        self.lblTaskID.font = UIFont.gciFontBold(15)
        self.lblTaskState.font = UIFont.gciFontBold(13)
        self.lblTaskUrgent.font = UIFont.gciFontMedium(13)
        self.lblTaskTitle.font = UIFont.gciFontBold(17)
        self.lblCreationDate.font = UIFont.gciFontRegular(13)
        self.lblDueDate.font = UIFont.gciFontRegular(13)
        self.lblAddress.font = UIFont.gciFontRegular(14)
        self.btnAction.titleLabel?.font = UIFont.gciFontMedium(14)
        
        self.lblTaskID.textColor = UIColor.white
        self.lblTaskState.textColor = UIColor.tangerine
        self.lblTaskUrgent.textColor = UIColor.redPink
        self.lblTaskTitle.textColor = UIColor.charcoalGrey
        self.lblCreationDate.textColor = UIColor.charcoalGrey
        self.lblDueDate.textColor = UIColor.charcoalGrey
        self.lblAddress.textColor = UIColor.charcoalGrey
        self.btnAction.setTitleColor(UIColor.cerulean, for: .normal)
    }
    
    func defineCell(WithTask task: TaskViewModel) {
        self.currentTask = task

        self.lblTaskTitle.text = task.interventionType?.name ?? task.interventionTypeComment
        self.lblTaskID.text = "tasks_id".localized(arguments: String(task.id))
        
        if task.isUrgent {
            self.lblTaskUrgent.text = "tasks_state_urgent".localized
            self.lblTaskUrgent.isHidden = false
            self.viewIsUrgent.isHidden = false
        } else {
            self.lblTaskUrgent.text = ""
            self.lblTaskUrgent.isHidden = true
            self.viewIsUrgent.isHidden = true
        }
        
        if let dueDate = task.dueDate {
            self.lblDueDate.text = "\("tasks_end_at".localized) \("general_date_with_time".localized(arguments: dueDate.toDateString(style: .short), dueDate.toTimeString(style: .medium)))"
            self.lblDueDate.isHidden = false
        } else {
            self.lblDueDate.text = ""
            self.lblDueDate.isHidden = true
        }
        
        self.lblCreationDate.text = "tasks_created_at".localized(arguments: task.creationDate.toDateString(style: .short), task.creationDate.toTimeString(style: .medium))
        
        lblTaskState.text = task.status.localizedText
        
        if let location = task.location {
            var textAddress: String = ""
            var distance = 0.0
            if let position = LocationHelper.shared.currentLocation {
                distance = location.distanceInMeters(fromPoint: AGSPoint(clLocationCoordinate2D: position.coordinate)) ?? 0.0
                distance /= 1000
                if distance < 1 {
                    distance = 1
                }
                textAddress = "\("tasks_distance".localized(arguments: String(Int(distance)))) -"
            }
            textAddress = "\(textAddress)\(location.address)"
            self.lblAddress.text = textAddress
            self.lblAddress.isHidden = false
            self.imgIconLocalisation.isHidden = false
        } else {
            self.lblAddress.isHidden = true
            self.imgIconLocalisation.isHidden = true
        }
        
        if let user = User.currentUser(), let firstAction = task.taskActions(forUser: user).first {
            self.btnAction.setTitle(firstAction.title, for: .normal)
            self.btnAction.isHidden = false
        } else {
            self.btnAction.isHidden = true
        }
    }
    @IBAction func btnNavigationTouched(_ sender: Any) {
        if let task = self.currentTask {
            self.delegate?.navigate(toTask: task)
        } else {
            self.delegate?.navigate(toTask: nil)
        }
    }
    
    @IBAction func btnActionTouched(_ sender: Any) {
        if let user = User.currentUser(), let task = self.currentTask, let firstAction = task.taskActions(forUser: user).first {
            self.delegate?.actionTouched(action: firstAction, forTask: self.currentTask)
        } else {
            self.delegate?.actionTouched(action: nil, forTask: nil)
        }
    }
}
