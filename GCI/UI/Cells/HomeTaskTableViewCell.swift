//
//  HomeDITableViewCell.swift
//  GCI
//
//  Created by Anthony Chollet on 07/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit
import Lottie
import ArcGIS

protocol HomeTaskTableViewCellDelegate: class {
    func didSelectFavorite(forCurrentTask task: TaskViewModel, isFavorite: Bool, selectedCell: HomeTaskTableViewCell)
    func didSelectAction(ForCurrentTask task: TaskViewModel, andAction action: TaskAction)
}

class HomeTaskTableViewCell: UITableViewCell {

    @IBOutlet weak var contentCell: UIView!
    @IBOutlet weak var viewUrgent: UIView!
    @IBOutlet weak var lblDI_ID: UILabel!
    @IBOutlet weak var viewDI_ID: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblUrgent: UILabel!
    @IBOutlet weak var lblLate: UILabel!
    @IBOutlet weak var lblDITitle: UILabel!
    @IBOutlet weak var lblTransmitter: UILabel!
    @IBOutlet weak var lblCreatedDate: UILabel!
    @IBOutlet weak var lblPlanified: UILabel!
    @IBOutlet weak var lblPlanifiedDTM: UILabel!
    @IBOutlet weak var lblLocalisation: UILabel!
    @IBOutlet weak var imgLocalisation: UIImageView!
    @IBOutlet var constraintSpacingDueDate: NSLayoutConstraint!
    @IBOutlet weak var btnFAvorite: UIButton!
    @IBOutlet weak var btnAction: GCIButton!
    @IBOutlet weak var btnWidthConstraint: NSLayoutConstraint!
    
    private let addFavAnimationView = LottieAnimationView()
    var currentTask: TaskViewModel?
    weak var delegate: HomeTaskTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setInterface()
        self.setText()
        
        let favAnimation = LottieAnimation.named("animation_favorites")
        self.addFavAnimationView.animation = favAnimation
        addFavAnimationView.loopMode = .playOnce
        addFavAnimationView.contentMode = .scaleAspectFit
        self.btnFAvorite.addSubview(addFavAnimationView)
        addFavAnimationView.isHidden = true
        self.setAnimationConstraint()
    }
    
    func setInterface() {
        self.backgroundColor = UIColor.lightPeriwinkle
        self.contentView.backgroundColor = UIColor.clear
        self.contentCell.layer.cornerRadius = 5
        self.contentCell.clipsToBounds = false
        self.contentCell.backgroundColor = UIColor.white
        self.viewDI_ID.layer.cornerRadius = 5
        self.viewDI_ID.layer.backgroundColor = UIColor.tangerine.cgColor
        self.viewUrgent.layer.backgroundColor = UIColor.redPink.cgColor
        self.viewUrgent.roundCorners([.topLeft, .bottomLeft], radius: 5)
        self.contentCell.addShadow(ofColor: UIColor.black, radius: 3, offset: CGSize(width: 0, height: 0.5), opacity: 0.2)
    }
    
    func setText() {
        self.lblDI_ID.font = UIFont.gciFontBold(14)
        self.lblStatus.font = UIFont.gciFontBold(12)
        self.lblLate.font = UIFont.gciFontMedium(12)
        self.lblUrgent.font = UIFont.gciFontMedium(12)
        self.lblDITitle.font = UIFont.gciFontBold(16)
        self.lblTransmitter.font = UIFont.gciFontRegular(13)
        self.lblCreatedDate.font = UIFont.gciFontRegular(13)
        self.lblPlanified.font = UIFont.gciFontBold(13)
        self.lblPlanifiedDTM.font = UIFont.gciFontRegular(13)
        self.lblLocalisation.font = UIFont.gciFontRegular(13)
        
        self.lblDI_ID.textColor = UIColor.white
        self.lblStatus.textColor = UIColor.charcoalGrey
        self.lblUrgent.textColor = UIColor.redPink
        self.lblLate.textColor = UIColor.tangerine
        self.lblDITitle.textColor = UIColor.charcoalGrey
        self.lblTransmitter.textColor = UIColor.charcoalGrey
        self.lblCreatedDate.textColor = UIColor.charcoalGrey
        self.lblPlanified.textColor = UIColor.tangerine
        self.lblPlanifiedDTM.textColor = UIColor.charcoalGrey
        self.lblLocalisation.textColor = UIColor.charcoalGrey
        
    }
    
    func setAnimationConstraint() {
        addFavAnimationView.translatesAutoresizingMaskIntoConstraints = false
        
        let leading = NSLayoutConstraint(item: addFavAnimationView,
                                         attribute: .trailing,
                                         relatedBy: .equal,
                                         toItem: addFavAnimationView.superview,
                                         attribute: .trailing,
                                         multiplier: 1,
                                         constant: -6)
        
        let top = NSLayoutConstraint(item: addFavAnimationView,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: addFavAnimationView.superview,
                                     attribute: .top,
                                     multiplier: 1,
                                     constant: 7)
        
        let width = NSLayoutConstraint(item: addFavAnimationView,
                                       attribute: .width,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 1.0,
                                       constant: 30)
        
        let height = NSLayoutConstraint(item: addFavAnimationView,
                                       attribute: .height,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 1.0,
                                       constant: 28)
        
        addFavAnimationView.superview?.addConstraints([leading, top])
        self.addFavAnimationView.addConstraints([width, height])
        self.layoutIfNeeded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            self.contentView.backgroundColor = UIColor.white
        } else {
            self.contentView.backgroundColor = UIColor.clear
        }
    }
    
    func setCell(withTask task: TaskViewModel) {
        currentTask = task
        
        if let currentTask = currentTask {
            self.lblDI_ID.text = "tasks_id".localized(arguments: String(currentTask.id))
            if currentTask.isPublic {
                self.lblStatus.text = "\(currentTask.status.localizedText), \("dashboard_filter_public".localized)"
            } else {
                self.lblStatus.text = "\(currentTask.status.localizedText)"
            }
            
            self.setStatusTask()
            self.setPlannedDate()
            
            self.lblDITitle.text = currentTask.interventionType?.name ?? currentTask.interventionTypeComment
            self.lblCreatedDate.text = "tasks_created_at".localized(arguments: currentTask.creationDate.toDateString(style: .short), currentTask.creationDate.toTimeString(style: .medium))
            
            if let location = currentTask.location, !location.address.isEmpty {
                self.lblLocalisation.text = ""
                self.imgLocalisation.isHidden = false
                var distance = 0.0
                if let position = LocationHelper.shared.currentLocation {
                    distance = location.distanceInMeters(fromPoint: AGSPoint(clLocationCoordinate2D: position.coordinate)) ?? 0.0
                    distance /= 1000
                    if distance < 1 {
                        distance = 1
                    }
                    self.lblLocalisation.text = "\("tasks_distance".localized(arguments: String(Int(distance)))) -"
                }
                
                self.lblLocalisation.text = "\(self.lblLocalisation.text ?? "")\(location.address)"
            } else {
                self.imgLocalisation.isHidden = true
                self.lblLocalisation.text = ""
            }
            if let serviceName = currentTask.service?.name {
                self.lblTransmitter.text = "\(serviceName) | \(currentTask.creator.fullname)"
            } else {
                self.lblTransmitter.text = currentTask.creator.fullname
            }
            
            currentTask.isFavorite ? self.btnFAvorite.setImage(UIImage(named: "ico_favorite_blue_full"), for: .normal) : self.btnFAvorite.setImage(UIImage(named: "ico_favorite_blue"), for: .normal)
            
            btnWidthConstraint.constant = 0
            if DeviceType.isIpad, let user = User.currentUser(), let firstAction = currentTask.taskActions(forUser: user).first {
                self.btnAction.isHidden = false
                self.btnAction.setTitle(firstAction.title, for: .normal)
                btnWidthConstraint.constant = 200
            } else {
                self.btnAction.isHidden = true
            }
            self.layoutIfNeeded()
        }
    }
    
    func setStatusTask() {
        if let currentTask = currentTask {
            self.lblUrgent.text = ""
            self.lblUrgent.textColor = UIColor.redPink
            
            if currentTask.isUrgent {
                self.lblUrgent.text = "| \("dashboard_filter_urgent".localized)"
                self.viewUrgent.backgroundColor = UIColor.redPink
            } else {
                self.lblUrgent.text = ""
                self.viewUrgent.backgroundColor = UIColor.clear
            }
            
            if currentTask.isLate {
                self.lblLate.text = "| \("dashboard_filter_late".localized)"
            } else {
                self.lblLate.text = ""
            }
            
//            if let text = self.lblShortcutFilter.text, text.isEmpty {
//                self.lblShortcutFilter.text = "tasks_state_not_delayed".localized
//                self.lblShortcutFilter.textColor = UIColor.tangerine
//            }
        }
    }
    
    func setPlannedDate() {
        if let currentTask = currentTask {
            if let dueDate = currentTask.dueDate {
                self.lblPlanified.text = "tasks_end_at".localized
                self.lblPlanified.textColor = UIColor.tangerine
                
                self.lblPlanifiedDTM.text = "general_date_with_time".localized(arguments: dueDate.toDateString(style: .short), dueDate.toTimeString(style: .medium))
                self.constraintSpacingDueDate.isActive = true
            } else {
                self.lblPlanified.text = ""
                self.lblPlanifiedDTM.text = ""
                self.constraintSpacingDueDate.isActive = false
            }
        }
    }
    
    @IBAction func btnFavoriteTouched(_ sender: Any) {
        if let currentTask = currentTask {
            if !currentTask.isFavorite {
                DispatchQueue.main.async {
                    self.addFavAnimationView.isHidden = false
                    //self.btnFAvorite.setImage(nil, for: .normal)
                    currentTask.isFavorite = true
                    self.delegate?.didSelectFavorite(forCurrentTask: currentTask, isFavorite: true, selectedCell: self)
                    self.addFavAnimationView.play { _ in
                        self.addFavAnimationView.isHidden = true
                        self.btnFAvorite.setImage(UIImage(named: "ico_favorite_blue_full"), for: .normal)
                    }
                }
            } else {
                currentTask.isFavorite = false
                self.btnFAvorite.setImage(UIImage(named: "ico_favorite_blue"), for: .normal)
                self.delegate?.didSelectFavorite(forCurrentTask: currentTask, isFavorite: false, selectedCell: self)
            }
        }
    }
    
    func forceSetFavorite(isFavorite: Bool) {
        if let currentTask = currentTask {
            if isFavorite {
                currentTask.isFavorite = true
                self.btnFAvorite.setImage(UIImage(named: "ico_favorite_blue_full"), for: .normal)
            } else {
                currentTask.isFavorite = false
                self.btnFAvorite.setImage(UIImage(named: "ico_favorite_blue"), for: .normal)
            }
        }
    }
    
    @IBAction func btnActionTouched(_ sender: Any) {
        guard let currentTask = currentTask, let user = User.currentUser(), let action = currentTask.taskActions(forUser: user).first else {
            return
        }
        
        self.delegate?.didSelectAction(ForCurrentTask: currentTask, andAction: action)
    }
}
