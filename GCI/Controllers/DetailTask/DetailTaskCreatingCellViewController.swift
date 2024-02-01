//
//  DetailTaskCreatingCellViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 22/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit
import ArcGIS
import MessageUI
import MapKit

extension DetailTaskViewController {

    func defineCellToDisplay() {
        allDisplayableCell = [Int: [DataCell]]()
        
        sectionIndex = 0
        allDisplayableCell[sectionIndex] = [DataCell]()
        if selectedTask?.previousTask.count ?? 0 > 0 || selectedTask?.nextTask.count ?? 0 > 0 {
            //Section task previous and next
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskLinked, previousTask: selectedTask?.previousTask, nextTask: selectedTask?.nextTask))
            
            sectionIndex += 1
            allDisplayableCell[sectionIndex] = [DataCell]()
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .space, backgroundColor: UIColor.white))
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .space))
            sectionIndex += 1
            allDisplayableCell[sectionIndex] = [DataCell]()
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .space, backgroundColor: UIColor.white))
            //Section information task
        } else {
            //Section blank
            sectionIndex += 1
            allDisplayableCell[sectionIndex] = [DataCell]()
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .space, backgroundColor: UIColor.white))
            //Section information task
        }
        
        //Section information task
        nextCellIsCollapsable = true
        self.addAddressCell()
        self.addPatrimonyCells()
        self.addTaskInformationCell()
        self.addCreatorCell()
        self.addEmitterCell()
        self.addOriginTaskCell()
        self.addCopyServiceCell()
        allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .space, backgroundColor: UIColor.white))
        
        if let steps = selectedTask?.displayableSteps, steps.count > 0 {
            //Section task steps
            sectionIndex += 1
            allDisplayableCell[sectionIndex] = [DataCell]()
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .space))
            nextCellIsCollapsable = true
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskTitle, title: "task_steps".localized, isCollapsable: nextCellIsCollapsable))
            nextCellIsCollapsable = false
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .space, backgroundColor: UIColor.white))
            self.addStepCell()
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .space, backgroundColor: UIColor.white))
        }
        
        if let historyList = selectedTask?.history, historyList.count > 0 {
            //Section task steps
            sectionIndex += 1
            allDisplayableCell[sectionIndex] = [DataCell]()
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .space))
            nextCellIsCollapsable = true
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskTitle, title: "task_history".localized, isCollapsable: nextCellIsCollapsable))
            nextCellIsCollapsable = false
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .space, backgroundColor: UIColor.white))
            self.addHistoryCell()
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .space, backgroundColor: UIColor.white))
        }
        
        sectionIndex += 1
        allDisplayableCell[sectionIndex] = [DataCell]()
        var space = DataCell(typeCell: .space)
        space.backgroundColor = UIColor.white
        allDisplayableCell[sectionIndex]?.append(space)
        
        var secondSpace = DataCell(typeCell: .space)
        secondSpace.backgroundColor = UIColor.white
        allDisplayableCell[sectionIndex]?.append(secondSpace)
    }
    
    func addAddressCell() {
        if let location = selectedTask?.location, !location.address.isEmpty {
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskTitle,
                                        title: "task_location".localized,
                                        icon: UIImage(named: "ico_location_DI_dashboard"),
                                        isCollapsable: nextCellIsCollapsable))
            nextCellIsCollapsable = false
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
            
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskText,
                                        isLate: false,
                                        messageAttribute: NSAttributedString.addUnderlineCell(messageFull: textAddress, underlinePart: location.address, font: UIFont.gciFontRegular(16)),
                                        actionOnTouch: { _ in
                                            self.launchNavigationGps(toGpsCoordinate: location.point.toCLLocationCoordinate2D(), address: location.address)
            }))
            
            if !location.comment.isEmpty {
                allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskText,
                                        isLate: false,
                                        messageAttribute: NSAttributedString.commentMessage(withMessage: location.comment, font: UIFont.gciFontRegular(16))))
            }
        }
    }
    
    func addPatrimonyCells() {
        if let patrimony = selectedTask?.patrimony {
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskTitle, title: "task_patrimony".localized, icon: UIImage(named: "ico_heritage_details_DI"), isCollapsable: nextCellIsCollapsable))
            nextCellIsCollapsable = false
            
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskText, isLate: false, messageAttribute: NSAttributedString.addSimpleCell(message: "tast_patrimony_element_number".localized(arguments: String(patrimony.id)), font: UIFont.gciFontRegular(16))))
            
            if let comment = selectedTask?.patrimonyComment {
                allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskText, isLate: false, messageAttribute: NSAttributedString.commentMessage(withMessage: comment, font: UIFont.gciFontRegular(16))))
            }
        }
    }
    
    func addTaskInformationCell() {
        if let selectedTask = selectedTask {
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskTitle, title: "tast_information_general".localized, icon: UIImage(named: "ico_information_details_DI"), isCollapsable: nextCellIsCollapsable))
            nextCellIsCollapsable = false
            
            if selectedTask.isLate {
                allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskText, isLate: true, messageAttribute: NSAttributedString.addColoredCell(messageFull: "tasks_state_delayed".localized, coloredPart: "tasks_state_delayed".localized, font: UIFont.gciFontRegular(16), fontColor: UIFont.gciFontRegular(16), color: UIColor.redPink)))
            }
            
            if let dueDate = selectedTask.dueDate {
                allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskText, isLate: false, messageAttribute: NSAttributedString.addColoredCell(messageFull: "\("tasks_end_at_long".localized) \("general_date_with_time".localized(arguments: dueDate.toDateString(style: .short), dueDate.toTimeString(style: .medium)))", coloredPart: "tasks_end_at_long".localized, font: UIFont.gciFontRegular(16), fontColor: UIFont.gciFontBold(16), color: UIColor.tangerine)))
            }
            
            if selectedTask.interventionDurationSec > 0 {
                let minute = Int(selectedTask.interventionDurationSec / 60)
                if minute < 60 {
                    allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskText, isLate: false, messageAttribute: NSAttributedString.addColoredCell(messageFull: "\("task_duration".localized) \(String(format: "%dm", minute))", coloredPart: "task_duration".localized, font: UIFont.gciFontRegular(16), fontColor: UIFont.gciFontBold(16), color: UIColor.tangerine)))
                } else {
                    let hour = Int(selectedTask.interventionDurationSec / 3600)
                    let minute = Int(selectedTask.interventionDurationSec) % 3600 / 60
                    if hour < 23 {
                        allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskText, isLate: false, messageAttribute: NSAttributedString.addColoredCell(messageFull: "\("task_duration".localized) \(String(format: "%dh %dm", hour, minute))", coloredPart: "task_duration".localized, font: UIFont.gciFontRegular(16), fontColor: UIFont.gciFontBold(16), color: UIColor.tangerine)))
                    } else {
                        let day = Int(selectedTask.interventionDurationSec / 86400)
                        let hour = Int(selectedTask.interventionDurationSec) % 86400 / 3600
                        let minute = Int(selectedTask.interventionDurationSec) % 3600 / 60
                        allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskText, isLate: false, messageAttribute: NSAttributedString.addColoredCell(messageFull: "\("task_duration".localized) \(String(format: "%dj %dh %dm", day, hour, minute))", coloredPart: "task_duration".localized, font: UIFont.gciFontRegular(16), fontColor: UIFont.gciFontBold(16), color: UIColor.tangerine)))
                    }
                }
            }
            
            if !selectedTask.comment.isEmpty {
                allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskText, isLate: false, messageAttribute: NSAttributedString.commentMessage(withMessage: selectedTask.comment, font: UIFont.gciFontRegular(16))))
            }
            
            if let attachement = selectedTask.displayableAttachment?.synchronizedAttachment {
                allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .attachementTask, attachement: attachement, actionOnTouch: { (cell) in
                    if let cell = cell as? DetailTaskAttachmentTableViewCell {
                        if cell.attachement.isPicture {
                            if let image = cell.imgPhoto.image {
                                self.fullscreenImage(withImage: image)
                            }
                        } else {
                            self.showPDF(attachement: attachement)
                        }
                    }
                    
                }))
            }
        }
    }
    
    func addCreatorCell() {
        if let selectedTask = selectedTask, !selectedTask.creator.fullname.isEmpty {
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskTitle, title: "task_created_by".localized, icon: UIImage(named: "ico_transmitter_creator_details_DI"), isCollapsable: nextCellIsCollapsable))
            nextCellIsCollapsable = false
            
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskText, isLate: false, messageAttribute: NSAttributedString.addSimpleCell(message: "\(selectedTask.creator.fullname) \("tasks_created_at".localized(arguments: selectedTask.creationDate.toDateString(style: .short), selectedTask.creationDate.toTimeString(style: .medium)))", font: UIFont.gciFontRegular(16))))
        }
    }
    
    func addEmitterCell() {
        allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskTitle, title: "task_emitter".localized, icon: UIImage(named: "ico_transmitter_creator_details_DI"), isCollapsable: nextCellIsCollapsable))
        nextCellIsCollapsable = false
        
        if let transmitter = selectedTask?.transmitter {
            
            if !transmitter.fullname.isEmpty {
                allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskText, isLate: false, messageAttribute: NSAttributedString.addSimpleCell(message: transmitter.fullname, font: UIFont.gciFontRegular(16))))
            } else {
                allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskText, isLate: false, messageAttribute: NSAttributedString.addSimpleCell(message: "task_detail_anonymous_transmitter".localized, font: UIFont.gciFontRegular(16))))
            }
            
            if let address = transmitter.address, !address.isEmpty {
                allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskText, isLate: false, messageAttribute: NSAttributedString.addSimpleCell(message: address, font: UIFont.gciFontRegular(16))))
            }
            
            if let email = transmitter.email, !email.isEmpty {
                allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskText, isLate: false, messageAttribute: NSAttributedString.addUnderlineCell(messageFull: email, underlinePart: email, font: UIFont.gciFontRegular(16)), actionOnTouch: { [unowned self] _ in
                    self.sendMail(to: email)
                }))
            }
            
            if let phone = transmitter.phone, !phone.isEmpty {
                allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskText, isLate: false, messageAttribute: NSAttributedString.addSimpleCell(message: phone, font: UIFont.gciFontRegular(16))))
            }
        } else {
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskText, isLate: false, messageAttribute: NSAttributedString.addSimpleCell(message: "task_detail_anonymous_transmitter".localized, font: UIFont.gciFontRegular(16))))
        }
        
        if let comment = selectedTask?.transmitterComment, !comment.isEmpty {
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskText, isLate: false, messageAttribute: NSAttributedString.commentMessage(withMessage: comment, font: UIFont.gciFontRegular(16))))
        }
    }
    
    func addOriginTaskCell() {
        if let origin = selectedTask?.originLabel, !origin.isEmpty {
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskTitle, title: "task_origin".localized, icon: UIImage(named: "ico_origin_details_DI"), isCollapsable: nextCellIsCollapsable))
            nextCellIsCollapsable = false
            
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskText, isLate: false, messageAttribute: NSAttributedString.addSimpleCell(message: origin, font: UIFont.gciFontRegular(16))))
        }
    }
    
    func addCopyServiceCell() {
        if let copyService = selectedTask?.otherServices, copyService.count > 0 {
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskTitle, title: "task_other_services".localized, icon: UIImage(named: "ico_services_details_DI"), isCollapsable: nextCellIsCollapsable))
            nextCellIsCollapsable = false
            
            for service in copyService {
                allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .taskText, isLate: false, messageAttribute: NSAttributedString.addSimpleCell(message: service.name, font: UIFont.gciFontRegular(16))))
            }
        }
    }
    
    func addStepCell() {
        if let steps = selectedTask?.displayableSteps {
            for step in steps {
                allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .verticalBreadcrumb, step: step))
            }
        }
    }
    
    func addHistoryCell() {
        selectedTask?.history.sorted().forEach({ (history) in
            
            allDisplayableCell[sectionIndex]?.append(DataCell(typeCell: .verticalBreadcrumb, history: history))
        })
    }
}

extension DetailTaskViewController: MFMailComposeViewControllerDelegate {
    func sendMail(to email: String) {
        DispatchQueue.main.async {
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients([email])
                
                self.present(mail, animated: true)
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func launchNavigationGps(toGpsCoordinate coordinates: CLLocationCoordinate2D, address: String) {
        
        self.displayAlert(withTitle: "", andMessage: "action_confirmation_launch_gps".localized, andValidButtonText: "general_yes".localized, orCancelText: "general_cancel".localized, andNerverAskCode: DialogCode.gps) { (accept) in
            if accept {
                let regionDistance: CLLocationDistance = 1000
                let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
                let option = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
                let placemark = MKPlacemark(coordinate: coordinates)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = address
                mapItem.openInMaps(launchOptions: option)
            }
        }
    }
    
    func fullscreenImage(withImage image: UIImage) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "ModalsStoryboard", bundle: nil)
            if let imageViewController = storyboard.instantiateViewController(withIdentifier: "modalImageViewController") as? ModalImageViewController {
                imageViewController.image = image
                imageViewController.modalPresentationStyle = .fullScreen
                self.present(imageViewController, animated: true, completion: nil)
            }
        }
    }
    
    func showPDF(attachement: ViewableAttachment) {
        DispatchQueue.main.async {
            self.displayLoader { _ in
                self.detailManager.loadPDFFile(fromAttachement: attachement, completion: { (url, error) in
                    if let url = url {
                        self.hideLoader { _ in
                            let storyboard = UIStoryboard(name: "ModalsStoryboard", bundle: nil)
                            if let pdfViewController = storyboard.instantiateViewController(withIdentifier: "modalPDFViewController") as? ModalPDFViewerViewController {
                                pdfViewController.pdfFileUrl = url
                                pdfViewController.modalPresentationStyle = .fullScreen
                                self.present(pdfViewController, animated: true, completion: nil)
                            }
                        }
                    } else {
                        self.hideLoader { _ in
                            if let error = error {
                                switch error {
                                case .noNetwork, .offlineNotAuthorized:
                                    self.showBanner(withTitle: "error_reachability".localized, withColor: .redPink)
                                case .notRightUsername:
                                    self.showBanner(withTitle: "error_licence_code".localized, withColor: .redPink)
                                default:
                                    self.showBanner(withTitle: "error_general".localized, withColor: .redPink)
                                }
                            }
                        }
                    }
                })
            }
        }
    }
    
    @objc func touchFullscreenImage(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            sender.view?.alpha = 0
        }) { (_) in
            sender.view?.removeFromSuperview()
        }
    }
}
