//
//  DetailTaskViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 16/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit
import ArcGIS

protocol DetailTaskProtocol {
    func displayMessage(message: String)
}

class DetailTaskViewController: AbstractViewController {

    @IBOutlet weak var tableViewContent: UITableView!
    @IBOutlet var headerViewDetail: UIView!
    @IBOutlet weak var lblTypeTitle: UILabel!
    @IBOutlet weak var lblTypeValue: UILabel!
    @IBOutlet weak var viewUrgent: UIView!
    @IBOutlet weak var lblUrgent: UILabel!
    @IBOutlet weak var lblDomainTitle: UILabel!
    @IBOutlet weak var lblDomainValue: UILabel!
    @IBOutlet weak var lblServiceTitle: UILabel!
    @IBOutlet weak var lblServiceValue: UILabel!
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var stackViewDomainService: UIStackView!
    @IBOutlet weak var viewInterventionType: UIView!
    @IBOutlet weak var viewInterventionDomain: UIView!
    @IBOutlet weak var viewInterventionService: UIView!
    
    @IBOutlet weak var btnFirstAction: GCIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var btnMoreAction: UIButton!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint! {
        didSet {
            heightConstraint.constant = maxHeight
        }
    }
    @IBOutlet weak var BtnActionTrailingConstraint: NSLayoutConstraint!
    
    var createAndEditManager = CreateAndEditTaskManager()
    private var maxHeight: CGFloat = 240
    private let minHeight: CGFloat = 159
    private let refreshControl = UIRefreshControl()
    let homeManager = HomeManager()
    var allDisplayableCell = [Int: [DataCell]]()
    var displayCell = [Int: [DataCell]]()
    var nextCellIsCollapsable = false
    var selectedTask: TaskViewModel?
    var sectionIndex: Int = 0
    var actionManager = TaskActionnableManager()
    var detailManager = DetailTaskManager()
    var favbutton: UIButton!
    var forceReloadImage: Bool = false
    var hasToQuitAfter: Bool = false
    var delegate: DetailTaskProtocol? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Constant.haveToRefresh = false
        
        self.navigationController?.isNavigationBarHidden = false
        self.actionManager.delegate = self
        
        self.setText()
        self.setInterface()
        self.setFromTask()
        
        self.configureTableView()
        self.tableViewContent.delegate = self
        self.tableViewContent.dataSource = self
        
        self.defineCellToDisplay()
        self.displayCell = allDisplayableCell
        self.tableViewContent.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = true
        self.pullToRefreshData(self)
    }
    
    override func refreshUI() {
        super.refreshUI()
    }
    
    func setInterface() {
        self.view.backgroundColor = UIColor.white
        self.headerViewDetail.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        
        self.viewUrgent.backgroundColor = UIColor.redPink
        self.viewUrgent.setRounded()
        
        self.viewInterventionService.layer.cornerRadius = 4
        self.viewInterventionDomain.layer.cornerRadius = 4
        self.viewInterventionType.layer.cornerRadius = 4
        
        viewInterventionDomain.addShadow()
        viewInterventionService.addShadow()
        viewInterventionType.addShadow()
        self.bottomView.backgroundColor = UIColor.white
        self.bottomView.addBottomGradient()
        
        self.defineNavBar()
        
        if (selectedTask?.location) == nil || selectedTask?.location?.address.isEmpty ?? true {
            maxHeight = minHeight
            heightConstraint.constant = maxHeight
            self.view.layoutIfNeeded()
            mapView.isHidden = true
        } else {
            self.setMap()
            self.mapView.isUserInteractionEnabled = false
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.touchMap(_:)))
            self.headerViewDetail.addGestureRecognizer(tap)
        }
    }
    
    func defineNavBar() {
        if let selectedTask = selectedTask {
            self.title = selectedTask.status.localizedText
            
            let rightView = UIView(frame: CGRect(x: self.view.bounds.width - 200, y: 0, width: 200, height: 44))
            rightView.backgroundColor = .clear
            
            favbutton = UIButton(type: .custom)
            favbutton.setImage(selectedTask.isFavorite ? UIImage(named: "ico_favorites_white_full") : UIImage(named: "ico_favorite"), for: .normal)
            favbutton.setTitle("", for: .normal)
            favbutton.addTarget(self, action: #selector(self.favButtonTouched(_:)), for: .touchUpInside)
            favbutton.frame = CGRect(x: rightView.width - 44, y: 0, width: 44, height: 44)
            rightView.addSubview(favbutton)
            
            let titleLabel = UILabel()
            titleLabel.text = "tasks_id".localized(arguments: String(selectedTask.id))
            titleLabel.font = UIFont.gciFontBold(16)
            titleLabel.textColor = .white
            titleLabel.sizeToFit()
            titleLabel.frame = CGRect(x: rightView.width - 50 - titleLabel.width, y: 0, width: titleLabel.width, height: 44)
            rightView.addSubview(titleLabel)
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightView)
            
            self.navigationController?.navigationBar.barStyle = .black
        }
    }
    
    func setText() {
        self.lblTypeTitle.font = UIFont.gciFontBold(16)
        self.lblDomainTitle.font = UIFont.gciFontBold(16)
        self.lblServiceTitle.font = UIFont.gciFontBold(16)
        self.lblTypeValue.font = UIFont.gciFontRegular(15)
        self.lblDomainValue.font = UIFont.gciFontRegular(15)
        self.lblServiceValue.font = UIFont.gciFontRegular(15)
        self.lblUrgent.font = UIFont.gciFontRegular(12)
        
        self.lblTypeTitle.textColor = UIColor.cerulean
        self.lblDomainTitle.textColor = UIColor.cerulean
        self.lblServiceTitle.textColor = UIColor.cerulean
        self.lblTypeValue.textColor = UIColor.charcoalGrey
        self.lblDomainValue.textColor = UIColor.charcoalGrey
        self.lblServiceValue.textColor = UIColor.charcoalGrey
        self.lblUrgent.textColor = UIColor.redPink
        
        self.lblUrgent.text = "dashboard_filter_urgent".localized
        self.lblTypeTitle.text = "task_intervention_type".localized
        self.lblDomainTitle.text = "task_domain".localized
        self.lblServiceTitle.text = "task_service".localized
    }
    
    func setFromTask() {
        if let selectedTask = selectedTask, let user = User.currentUser() {
            if let type = selectedTask.interventionType?.name, !type.isEmpty {
                self.lblTypeValue.text = type
            } else if let type = selectedTask.interventionTypeComment {
                self.lblTypeValue.text = type
            } else {
                self.lblTypeValue.text = "-"
            }
            
            if let domain = selectedTask.domain?.title, !domain.isEmpty {
                self.lblDomainValue.text = domain
            } else {
                self.lblDomainValue.text = "-"
            }
            
            if let service = selectedTask.service?.name, !service.isEmpty {
               self.lblServiceValue.text = service
            } else {
                self.lblServiceValue.text = "-"
            }
            
            if selectedTask.isUrgent {
                self.lblUrgent.isHidden = false
                self.viewUrgent.isHidden = false
            } else {
                self.lblUrgent.isHidden = true
                self.viewUrgent.isHidden = true
            }
            
            if let firstAction = selectedTask.taskActions(forUser: user).first {
                self.btnFirstAction.setTitle(firstAction.title, for: .normal)
                if selectedTask.taskActions(forUser: user).count == 1 {
                    self.btnMoreAction.isHidden = true
                    BtnActionTrailingConstraint.constant = 25
                } else {
                    self.btnMoreAction.isHidden = false
                    BtnActionTrailingConstraint.constant = 110
                }
                self.view.layoutIfNeeded()
            } else {
                self.bottomView.isHidden = true
            }
        }
    }
    
    func setMap() {
        _ = ArcgisHelper.initMap(withMapView: self.mapView)
        if let selectedTask = self.selectedTask {
            ArcgisHelper.addMarker(withMapView: self.mapView, forTask: selectedTask, isZoomActive: true)
        }
    }
    
    func refreshData() {
        self.title = self.selectedTask?.status.localizedText
        self.setFromTask()
        self.setMap()
        self.defineCellToDisplay()
        self.displayCell = allDisplayableCell
        self.tableViewContent.reloadData()
    }
    
    @objc func pullToRefreshData(_ sender: Any) {
        DispatchQueue.main.async {
            if let selectedTask = self.selectedTask {
                self.detailManager.refreshTask(task: selectedTask, completionHandler: { (task, error) in
                    if let task = task {
                        self.selectedTask = task
                        self.refreshData()
                        self.refreshControl.endRefreshing()
                    } else {
                        self.refreshControl.endRefreshing()
                        if let error = error {
                            switch error {
                            case .error:
                                self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                            case .denied:
                                self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                            case .noNetwork:
                                self.showBanner(withTitle: "error_banner_internet".localized, withColor: .redPink)
                            case .offlineNotAuthorized:
                                self.showBanner(withTitle: "error_not_in_offline".localized, withColor: .redPink)
                            case .canceled:
                                self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                            case .notRightUsername:
                                self.showBanner(withTitle: "error_licence_code".localized, withColor: .redPink)
                            default:
                                self.displayAlert(withTitle: "error_general".localized, andMessage: "error_network".localized)
                            }
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func BtnMoreActionTouched(_ sender: Any) {
        if let selectedTask = selectedTask, let user = User.currentUser() {
            if let storyboard = self.storyboard {
                let viewController = storyboard.instantiateViewController(withIdentifier: "taskActionsViewController")
                if let viewController = viewController as? TaskActionsViewController {
                    viewController.delegate = self
                    viewController.modalPresentationStyle = .overFullScreen
                    self.present(viewController, animated: false) {
                        viewController.taskActions = selectedTask.taskActions(forUser: user)
                    }
                }
            }
        }
        
    }
}

extension DetailTaskViewController: UITableViewDelegate, UITableViewDataSource {
    
    func configureTableView() {
        self.tableViewContent.tableFooterView = UIView(frame: CGRect.zero)
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 1000))
        footerView.backgroundColor = UIColor.white
        self.tableViewContent.tableFooterView?.addSubview(footerView)
        setupTopColored(inScrollView: tableViewContent, withColor: configuration?.mainColor ?? .lightPeriwinkle)
        
        tableViewContent.register(UINib(nibName: "DetailTaskLinkedTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTaskLinkedCell")
        tableViewContent.register(UINib(nibName: "DetailTaskTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTaskTitleCell")
        tableViewContent.register(UINib(nibName: "SpaceTableViewCell", bundle: nil), forCellReuseIdentifier: "SpaceCell")
        tableViewContent.register(UINib(nibName: "DetailTaskTextTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTaskTextCell")
        tableViewContent.register(UINib(nibName: "DetailTaskAttachmentTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTaskAttachmentCell")
        tableViewContent.register(UINib(nibName: "BreadCrumbVerticalTableViewCell", bundle: nil), forCellReuseIdentifier: "BreadCrumbVerticalCell")
        
        tableViewContent.contentInset = UIEdgeInsets(top: maxHeight, left: 0, bottom: 0, right: 0)
        
        refreshControl.tintColor = .cerulean
        tableViewContent.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(pullToRefreshData(_:)), for: .valueChanged)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return displayCell.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayCell[section]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let arrayOfcell = displayCell[indexPath.section] {
            switch arrayOfcell[indexPath.row].typeCell {
            case .taskLinked:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTaskLinkedCell") as! DetailTaskLinkedTableViewCell
                cell.initCell(withPreviousTask: arrayOfcell[indexPath.row].previousTask, withNextTask: arrayOfcell[indexPath.row].nextTask)
                cell.delegate = self
                return cell
            case .taskTitle:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTaskTitleCell") as! DetailTaskTitleTableViewCell
                cell.initCell(withTitle: arrayOfcell[indexPath.row].title, andIcon: arrayOfcell[indexPath.row].icon, isCollapsable: arrayOfcell[indexPath.row].isCollapsable, isCollapsed: arrayOfcell[indexPath.row].isCollapsed)
                return cell
            case .taskText:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTaskTextCell") as! DetailTaskTextTableViewCell
                cell.initCell(withMessage: arrayOfcell[indexPath.row].messageAttribute, AndIsLate: arrayOfcell[indexPath.row].isLate, hasActionOnTouch: (arrayOfcell[indexPath.row].actionOnTouch != nil) ? true : false)
                return cell
            case .space:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SpaceCell") as! SpaceTableViewCell
                cell.initCell(backgroundColor: arrayOfcell[indexPath.row].backgroundColor)
                return cell
            case .attachementTask:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTaskAttachmentCell") as! DetailTaskAttachmentTableViewCell
                cell.initCell(attachement: arrayOfcell[indexPath.row].attachement, forceReloadImage: forceReloadImage)
                forceReloadImage = false
                return cell
            case .verticalBreadcrumb:
                let cell = tableView.dequeueReusableCell(withIdentifier: "BreadCrumbVerticalCell") as! BreadCrumbVerticalTableViewCell
                if let history = arrayOfcell[indexPath.row].history {
                    
                    cell.define(withHistory: history, historyNumber: indexPath.row - 2, isLastHistory: indexPath.row - 2 == selectedTask?.history.count ? true : false)
                } else {
                    cell.define(withStep: arrayOfcell[indexPath.row].step, stepNumber: indexPath.row - 2, isLastStep: indexPath.row - 2 == selectedTask?.displayableSteps.count ? true : false)
                }
                cell.delegate = self
                return cell
            default:
                return UITableViewCell()
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let arrayOfcell = displayCell[indexPath.section] {
            switch arrayOfcell[indexPath.row].typeCell {
            case .taskLinked:
                return 120
            case .space:
                return 20
            case .taskTitle:
                if let dataCell = displayCell[indexPath.section]?[indexPath.row], dataCell.isCollapsable, dataCell.isCollapsed {
                    return 80
                } else {
                    return 40
                }
            case .attachementTask:
                return 85
            case .taskText:
                return (arrayOfcell[indexPath.row].messageAttribute?.height(withConstrainedWidth: self.tableViewContent.width - 90) ?? -10) + 10
            case .verticalBreadcrumb:
                var totalHeight: CGFloat = 25
                
                let timeable: TimeableViewModel?
                if let history = arrayOfcell[indexPath.row].history {
                    timeable = history
                } else {
                    timeable = arrayOfcell[indexPath.row].step
                }
                
                if let timeable = timeable {
                    //title
                    totalHeight += timeable.title.height(withConstrainedWidth: self.tableViewContent.width - 74, font: UIFont.gciFontBold(16))
                    
                    //created date
                    let date = "steps_short_descriptin".localized(arguments: timeable.userFullName, timeable.date.toDateString(style: .short), timeable.date.toTimeString(style: .medium))
                    totalHeight += date.height(withConstrainedWidth: self.tableViewContent.width - 74, font: UIFont.gciFontBold(16))
                }
                
                if let comment = timeable?.description, !comment.isEmpty {
                    totalHeight += comment.height(withConstrainedWidth: self.tableViewContent.width - 74, font: UIFont.gciFontRegular(16))
                }
                if arrayOfcell[indexPath.row].step?.displayableAttachment != nil {
                    totalHeight += 51
                }
                return totalHeight
            default:
                return 0
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = self.tableViewContent.cellForRow(at: indexPath)
        if let _ = cell as? DetailTaskTitleTableViewCell {
            if let dataCell = displayCell[indexPath.section]?[indexPath.row], dataCell.isCollapsable {
                if dataCell.isCollapsed {
                    allDisplayableCell[indexPath.section]![indexPath.row].isCollapsed = false
                    displayCell[indexPath.section]?.removeAll()
                    displayCell[indexPath.section]? = allDisplayableCell[indexPath.section]!
                    
                    var listOfIndexToAnimate = [IndexPath]()
                    for indexRow in 2 ..< displayCell[indexPath.section]!.count {
                        listOfIndexToAnimate.append(IndexPath(row: indexRow, section: indexPath.section))
                    }
                    if let titleCell = tableView.cellForRow(at: IndexPath(item: 1, section: indexPath.section)) as? DetailTaskTitleTableViewCell {
                        titleCell.setColapsed(isCollapsed: false)
                    }
                    tableView.beginUpdates()
                    tableView.insertRows(at: listOfIndexToAnimate, with: .fade)
                    tableView.endUpdates()
                    
                } else {
                    
                    var listOfIndexToAnimate = [IndexPath]()
                    for indexRow in 2 ..< displayCell[indexPath.section]!.count {
                        listOfIndexToAnimate.append(IndexPath(row: indexRow, section: indexPath.section))
                    }
                    
                    allDisplayableCell[indexPath.section]![indexPath.row].isCollapsed = true
                    displayCell[indexPath.section]?.removeAll()
                    displayCell[indexPath.section]?.append(allDisplayableCell[indexPath.section]![0])//spacing
                    displayCell[indexPath.section]?.append(allDisplayableCell[indexPath.section]![1])//title
                    if let titleCell = tableView.cellForRow(at: IndexPath(item: 1, section: indexPath.section)) as? DetailTaskTitleTableViewCell {
                        titleCell.setColapsed(isCollapsed: true)
                    }
                    tableView.beginUpdates()
                    tableView.deleteRows(at: listOfIndexToAnimate, with: .fade)
                    tableView.endUpdates()
                }
                
            }
        } else if let arrayOfcell = displayCell[indexPath.section] {
            if indexPath.row > 0 {
                let dataCell = arrayOfcell[indexPath.row]
                dataCell.actionOnTouch?(self.tableViewContent.cellForRow(at: indexPath)!)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.tableViewContent.deselectRow(at: indexPath, animated: true)
            })
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            let constant = max(abs(scrollView.contentOffset.y), minHeight)
            heightConstraint.constant = constant > maxHeight ? maxHeight : constant
        } else {
            heightConstraint.constant = minHeight
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(translationX: 0, y: 20)
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
