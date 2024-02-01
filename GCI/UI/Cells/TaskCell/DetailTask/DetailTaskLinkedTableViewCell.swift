//
//  DetailTaskLinkedTableViewCell.swift
//  GCI
//
//  Created by Anthony Chollet on 17/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

protocol DetailTaskLinkedTableViewCellDelegate: class {
    func selectNextTask(nextTasks: [TaskViewModel]?)
    func selectPreviousTask(previousTask: [TaskViewModel]?)
}

class DetailTaskLinkedTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnPreviousTask: GCIButton!
    @IBOutlet weak var btnNextTask: GCIButton!
    
    weak var delegate: DetailTaskLinkedTableViewCellDelegate?
    
    var previousTask: [TaskViewModel]?
    var nextTask: [TaskViewModel]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setText()
        
        if let previousTask = previousTask, previousTask.count == 0 {
            self.btnPreviousTask.isEnabled = false
        }
        if let nextTask = nextTask, nextTask.count == 0 {
            self.btnNextTask.isEnabled = false
        }
        setInterface()
    }
    
    override func didMoveToSuperview() {
    }
    
    func setInterface() {
       self.btnNextTask.backgroundColor = UIColor.tangerine
        self.btnPreviousTask.backgroundColor = UIColor.tangerine
    }
    
    func setText() {
        self.lblTitle.font = UIFont.gciFontBold(16)
        self.lblTitle.textColor = UIColor.cerulean
        self.lblTitle.text = "task_linked_task".localized
        
        self.btnPreviousTask.titleLabel?.font = UIFont.gciFontBold(16)
        self.btnNextTask.titleLabel?.font = UIFont.gciFontBold(16)
        
        self.btnPreviousTask.setTitleColor(.white, for: .normal)
        self.btnNextTask.setTitleColor(.white, for: .normal)
        
        self.btnPreviousTask.setTitle("task_linked_task_previous".localized, for: .normal)
        self.btnNextTask.setTitle("task_linked_task_next".localized, for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initCell(withPreviousTask previousTasks: [TaskViewModel]? = nil, withNextTask nextTasks: [TaskViewModel]? = nil) {
        self.nextTask = nextTasks
        self.previousTask = previousTasks
        
        if self.previousTask?.count == 0 {
            self.btnPreviousTask.isEnabled = false
        } else {
            self.btnPreviousTask.isEnabled = true
        }
        
        if self.nextTask?.count == 0 {
            self.btnNextTask.isEnabled = false
        } else {
            self.btnNextTask.isEnabled = true
        }
    }
    
    @IBAction func btnNextTaskTouched(_ sender: Any) {
        self.delegate?.selectNextTask(nextTasks: self.nextTask)
    }
    
    @IBAction func btnPreviousTaskTouched(_ sender: Any) {
        self.delegate?.selectPreviousTask(previousTask: self.previousTask)
    }
}
