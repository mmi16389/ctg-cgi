//
//  UILabel.swift
//  neopixl_ext
//
//  Created by Joris Thiery on 15/12/2017.
//  Copyright © 2017 Joris Thiery. All rights reserved.
//

import UIKit

extension UILabel {
    
    var requiredHeight: CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.attributedText = attributedText
        label.sizeToFit()
        return label.frame.height
    }
    
    func countFromZeroTo(value: Int, duration: TimeInterval) {
        self.text = "0"
        var textValue = 0
        
        var timeInterval = duration/Double(value)
        var addValue = 1
        if duration / Double(value) < 0.01 {
            timeInterval = duration/(duration/0.01)
            addValue = Int(Double(value)/(duration/timeInterval))
        }
        
        let timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { (timer) in
            if (textValue + addValue) < value {
                textValue += addValue
                self.text = "\(textValue)"
            } else {
                self.text = "\(value)"
                timer.invalidate()
            }
        }
        
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
    }
    
    func animate(newText: String, characterInterval: TimeInterval = 0.25) {
        text = ""
        DispatchQueue.global(qos: .userInteractive).async {
            
            newText.forEach({ (character) in
                DispatchQueue.main.async {
                    self.text = self.text! + String(character)
                }
                Thread.sleep(forTimeInterval: characterInterval)
            })            
        }
    }
}
