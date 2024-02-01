//
//  TextfieldTableViewCell.swift
//  GCI
//
//  Created by Anthony Chollet on 03/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class TextviewTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textView: GCITextview!
    var placeHolder: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initCell(withPlaceHolder placeHolder: String, andPrefilledText text: String, icon: UIImage?, isEditable: Bool, parentDelegate: UITextViewDelegate? = nil, limitation: Int = 0) {
        
        self.textView.placeholder = placeHolder
        if !text.isEmpty {
            self.textView.text = text
        } else {
            self.textView.text = placeHolder
        }
        self.textView.delegate = parentDelegate
        
        if isEditable {
            self.textView.isUserInteractionEnabled = true
            self.textView.isEditable = true
        } else {
            self.textView.isUserInteractionEnabled = false
            self.textView.isEditable = false
        }
        
        self.textView.defineLimitation(limitation: limitation)
    }
}
