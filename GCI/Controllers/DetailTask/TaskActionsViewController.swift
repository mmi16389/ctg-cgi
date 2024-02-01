//
//  TaskActionsViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 23/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit
import Reachability

protocol TaskActionsViewControllerDelegate: class {
    func taskActionTouched(taskAction: TaskAction?)
}

class TaskActionsViewController: AbstractViewController {

    @IBOutlet weak var tableViewAction: UITableView!
    @IBOutlet weak var btnExit: UIButton!
    @IBOutlet weak var viewExit: UIView!
    @IBOutlet weak var constraintBottomExitView: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightTableView: NSLayoutConstraint!
    
    var taskActions: [TaskAction] = [TaskAction]()
    private let cellHeight: CGFloat = 60
    weak var delegate: TaskActionsViewControllerDelegate?
    private var isInternetReach = false
    let reachability = try? Reachability()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setInterface()
        self.configureTableView()
        
        self.tableViewAction.delegate = self
        self.tableViewAction.dataSource = self
        
        let recognizer = UITapGestureRecognizer(target: self,
                                                action: #selector(touchBackground(recognizer:)))
        self.view.addGestureRecognizer(recognizer)
        
        self.startMonitoringConnection()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.constraintBottomExitView.constant = 0
        self.view.layoutIfNeeded()
        self.startAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        reachability?.stopNotifier()
    }
    
    func startMonitoringConnection() {
        reachability?.whenReachable = { reachability in
            //reach
            self.isInternetReach = true
            self.tableViewAction.reloadData()
        }
        reachability?.whenUnreachable = { _ in
            //not reach
            self.isInternetReach = false
            self.tableViewAction.reloadData()
        }
        
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func setInterface() {
        self.view.backgroundColor = UIColor.cerulean
        self.viewExit.setRounded()
        
        self.viewExit.alpha = 0
        self.constraintBottomExitView.constant = 0
        self.view.layoutIfNeeded()
    }
    
    @IBAction func btnExitTouched(_ sender: Any) {
        UIView .animate(withDuration: 0.2, animations: {
            self.constraintBottomExitView.constant = 0
            self.btnExit.rotate(toAngle: -90, ofType: .degrees)
            self.tableViewAction.alpha = 0
            self.view.layoutIfNeeded()
        }) { (_) in
            self.dismiss(animated: true)
        }
    }
    
    @objc func reachabilityChanged(notification: Notification) {
        if let networkReachability = notification.object as? Reachability {
            switch networkReachability.connection {
            case .unavailable, .none:
                isInternetReach = false
            case .wifi, .cellular:
                isInternetReach = true
            }
            
            UIView.performWithoutAnimation {
                self.tableViewAction.reloadData()
            }
        }
    }
}

extension TaskActionsViewController {
    func startAnimation() {

        self.viewExit.rotate(toAngle: 90, ofType: .degrees, animated: true, duration: 0.3, completion: nil)
        UIView.animate(withDuration: 0.2, animations: {
            self.viewExit.alpha = 1
            self.constraintBottomExitView.constant = 25
            self.view.layoutIfNeeded()
        }) { (_) in
            self.constraintHeightTableView.constant = CGFloat(self.taskActions.count - 1) * self.cellHeight
            self.view.layoutIfNeeded()
            self.tableViewAction.reloadData()
        }
    }
}

extension TaskActionsViewController: UITableViewDelegate, UITableViewDataSource {
    func configureTableView() {
        self.tableViewAction.backgroundColor = .clear
        
        tableViewAction.register(UINib(nibName: "TaskActionTableViewCell", bundle: nil), forCellReuseIdentifier: "TaskActionCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskActions.count - 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskActionCell") as! TaskActionTableViewCell
        let task = taskActions.reversed()[indexPath.row]
        cell.initCell(withTask: taskActions.reversed()[indexPath.row])
        cell.delegate = self
        if let executor = task.executor {
            if !executor.offlineEnabled && !isInternetReach {
                cell.disableCell()
            } else {
                cell.enableCell()
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(translationX: 0, y: cellHeight / 2)
        cell.alpha = 0
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0.2 / Double(indexPath.row + 1),
            options: [.curveEaseInOut],
            animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.alpha = 1
        })
    }
}

extension TaskActionsViewController: TaskActionTableViewCellDelegate {
    func taskActionTouched(taskAction: TaskAction?, cell: TaskActionTableViewCell) {
        self.dismiss(animated: true) {
            self.delegate?.taskActionTouched(taskAction: taskAction)
        }
    }
    
    @objc func touchBackground(recognizer: UITapGestureRecognizer) {
        self.btnExitTouched(self.btnExit as Any)
    }
}
