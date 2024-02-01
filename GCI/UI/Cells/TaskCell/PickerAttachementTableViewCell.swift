//
//  PickerAttachementTableViewCell.swift
//  GCI
//
//  Created by Anthony Chollet on 13/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

protocol PickerAttachementDelegate: class {
    func pickAnAttachement(path: URL, fromCamera: Bool)
    func deleteAnAttachement()
}

class PickerAttachementTableViewCell: UITableViewCell {

    @IBOutlet weak var ConstraintItemwidth: NSLayoutConstraint!
    @IBOutlet weak var pickerViewPhotoCamera: PickerViewAttachement!
    @IBOutlet weak var pickerViewDocument: PickerViewAttachement!
    
    weak var delegate: PickerAttachementDelegate?
    private var attachementURL: URL?
    private var imagePicker: UIImagePickerController!
    private var document: URL?
    private var photo: UIImage?
    private var photoFromLibrary: UIImage?
    private var parent: AbstractViewController?
    private var isFromLibrary = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setInterface()
        self.definePicker()
        self.setPickerActions()
    }
    
    func setInterface() {
        self.pickerViewDocument.addShadow(radius: 1, offset: CGSize(width: 0, height: 1))
        self.pickerViewPhotoCamera.addShadow(radius: 1, offset: CGSize(width: 0, height: 1))
        
        self.pickerViewDocument.layer.cornerRadius = 5
        self.pickerViewPhotoCamera.layer.cornerRadius = 5
    }
    
    func initCell(withParentController parentController: AbstractViewController?, andAttachment attachment: ViewableAttachment? = nil, isFromCamera: Bool = false) {
        self.parent = parentController
        
        if let attachment = attachment {
            if attachment.isPicture && isFromCamera {
                self.photo = attachment.icon
            } else if attachment.isPicture {
                self.photoFromLibrary = attachment.icon
            } else {
                self.document = attachment.fileUrl
            }
            self.attachementURL = attachment.fileUrl
        }
        
        self.definePicker()
    }
    
    func definePicker() {
        if document != nil {
            self.pickerViewDocument.define(WithIcon: UIImage(named: "ico_add_file")!, title: "general_add_file".localized, imageOfSelectedContent: UIImage(named: "ico_pdf"))
            self.pickerViewDocument.imgSelectedContent.contentMode = .center
        } else if photoFromLibrary != nil {
            self.pickerViewDocument.define(WithIcon: UIImage(named: "ico_add_file")!, title: "general_add_file".localized, imageOfSelectedContent: photoFromLibrary)
            self.pickerViewDocument.imgSelectedContent.contentMode = .scaleAspectFill
        } else {
            self.pickerViewDocument.define(WithIcon: UIImage(named: "ico_add_file")!, title: "general_add_file".localized)
        }
        
        self.pickerViewPhotoCamera.define(WithIcon: UIImage(named: "ico_add_img")!, title: "general_take_picture".localized, imageOfSelectedContent: photo)
        self.pickerViewPhotoCamera.imgSelectedContent.contentMode = .scaleAspectFill
    }
    
    func setPickerActions() {
        self.pickerViewPhotoCamera.actionpickerOnTouch = {
            if self.document == nil && self.photoFromLibrary == nil {
                self.takePicture()
            }
        }
        
        self.pickerViewPhotoCamera.actionDeleteOnTouch = {
            self.photo = nil
            self.deleteAttachement()
        }
        
        self.pickerViewDocument.actionpickerOnTouch = {
            if self.photo == nil {
                self.openDocumentPicker()
            }
        }
        
        self.pickerViewDocument.actionDeleteOnTouch = {
            self.photoFromLibrary = nil
            self.document = nil
            self.deleteAttachement()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension PickerAttachementTableViewCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentMenuDelegate, UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let myURL = url as URL
        if FileManager.default.fileSize(forURL: myURL) < 5 {
            document = myURL
            saveAsAttachement()
            self.definePicker()
        } else {
            if let parent = parent {
                parent.showBanner(withTitle: "error_file_too_large".localized, withColor: .redPink)
            }
        }
    }
    
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        if let parent = parent, let navigationController = parent.navigationController {
            navigationController.present(documentPicker, animated: true, completion: nil)
        } else {
            parent?.present(documentPicker, animated: true, completion: nil)
        }
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        if let parent = parent, let navigationController = parent.navigationController {
            navigationController.dismiss(animated: true, completion: nil)
        }
    }
    
    func openDocumentPicker() {
        let docMenu = UIDocumentMenuViewController(documentTypes: [String(kUTTypePDF)], in: .import)
        docMenu.delegate = self
        docMenu.modalPresentationStyle = .formSheet
        docMenu.addOption(withTitle: "photo library", image: nil, order: .first, handler: { self.takePictureFromLibrary() }) //TBL
        if DeviceType.isIpad {
            docMenu.modalPresentationStyle = .popover
            docMenu.popoverPresentationController?.sourceView = self.pickerViewDocument
            docMenu.popoverPresentationController?.sourceRect = self.pickerViewDocument.frame
            parent?.present(docMenu, animated: true, completion: nil)
        } else if let parent = parent, let navigationController = parent.navigationController {
            navigationController.present(docMenu, animated: true, completion: nil)
        } else {
            parent?.present(docMenu, animated: true, completion: nil)
        }
    }
    
    func takePicture() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .camera
            isFromLibrary = false
            
            if let parent = parent, let navigationController = parent.navigationController {
                navigationController.present(imagePicker, animated: true, completion: nil)
            } else {
                parent?.present(imagePicker, animated: true, completion: nil)
            }
        } else {
            if let parent = parent {
                parent.showBanner(withTitle: "error_general".localized, withColor: .redPink)
            }
        }
    }
    
    func takePictureFromLibrary() {
        self.imagePicker =  UIImagePickerController()
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .photoLibrary
        isFromLibrary = true
        if let parent = parent, let navigationController = parent.navigationController {
            navigationController.present(imagePicker, animated: true, completion: nil)
        } else {
            parent?.present(imagePicker, animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        self.imagePicker.dismiss(animated: true, completion: nil)
        if isFromLibrary {
            self.photoFromLibrary = info[.originalImage] as? UIImage
//            if #available(iOS 11.0, *) {
//                if let url = info[.imageURL] as? URL {
//                    try? FileManager.default.removeItem(at: url)
//                }
//            }
            saveAsAttachement()
        } else {
            self.photo = info[.originalImage] as? UIImage
            saveAsAttachement()
        }
        self.definePicker()
    }
    
    func saveAsAttachement() {
        attachementURL = nil
        var isFromCamera = false
        if let photo = self.photo {
            attachementURL = CreateAndEditTaskManager().saveImageOnDisk(image: photo)
            isFromCamera = true
        } else if let libraryImage = self.photoFromLibrary {
            attachementURL = CreateAndEditTaskManager().saveImageOnDisk(image: libraryImage)
        } else if let pdfFile = self.document {
            attachementURL = CreateAndEditTaskManager().savePDFOnDisk(originalPath: pdfFile)
        }
        
        if let attachementURL = attachementURL {
            self.delegate?.pickAnAttachement(path: attachementURL, fromCamera: isFromCamera)
        }
    }
    
    func deleteAttachement() {
        if let attachmentURL = attachementURL {
            if FileManager.default.fileExists(atPath: attachmentURL.path) {
                try? FileManager.default.removeItem(at: attachmentURL)
                self.delegate?.deleteAnAttachement()
            }
        }
    }
}
