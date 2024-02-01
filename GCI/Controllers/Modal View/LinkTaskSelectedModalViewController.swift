//
//  LinkTaskSelectedModalViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 05/07/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class LinkTaskSelectedModalViewController: AbstractViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableViewContent: UITableView!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var lbltitle: UILabel!
    @IBOutlet weak var btnQuit: UIButton!
    
    typealias Action = (_ selectedTask: TaskViewModel) -> Void
    private var viewTitle: String = ""
    private var listOfChoice: [TaskViewModel] = []
    private var currentTask: TaskViewModel?
    
    var actionOnValidate: Action?
    
    func initModal(withTitle title: String, currentTask: TaskViewModel, listOfChoice: [TaskViewModel], actionOnValidate: @escaping Action) {
        self.viewTitle = title
        self.listOfChoice = listOfChoice
        self.listOfChoice.append(currentTask)
        self.actionOnValidate = actionOnValidate
        self.currentTask = currentTask
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
    }
    
    func setText() {
        self.lbltitle.textColor = UIColor.white
        self.lbltitle.font = UIFont.gciFontBold(17)
        
        self.lbltitle.text = viewTitle
    }
    
    @IBAction func btnQuitTouched(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func configureTableView() {
        tableViewContent.register(UINib(nibName: "SelectChoiceTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectChoiceCell")
        
        self.tableViewContent.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfChoice.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectChoiceCell") as! SelectChoiceTableViewCell
        
        cell.initCell(withTitle: listOfChoice[indexPath.row].title, imageAnnotation: UIImage(named: "ico_di_linked")!, isDirectSelectable: true)
        
        if listOfChoice[indexPath.row] == currentTask {
            self.tableViewContent.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if listOfChoice[indexPath.row] != currentTask {
            self.actionOnValidate?(listOfChoice[indexPath.row])
            self.dismiss(animated: false, completion: nil)
        }
    }
}
