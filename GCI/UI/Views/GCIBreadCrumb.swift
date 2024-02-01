//
//  GCIBreadCrumb.swift
//  GCI
//
//  Created by Anthony Chollet on 05/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class GCIBreadCrumb: UIView {
    
    typealias Action = (_ controllerSelectedIndex: Int) -> Void
    private var arrayOfControllers: [AbstractCreateOrEditViewController]?
    private var numberOfElements = 0
    private var currentIndex = 0
    var totalWidth: CGFloat = 0
    private var actionOnTouch: Action?
    
    func define(withNumbersElements numberOfElements: Int, andSelectedIndex selectedIndex: Int, andArrayOfControllers arrayOfControllers: [AbstractCreateOrEditViewController]?, actionOnTouch: @escaping Action) {
        self.numberOfElements = numberOfElements
        self.arrayOfControllers = arrayOfControllers
        self.currentIndex = selectedIndex
        self.actionOnTouch = actionOnTouch
        self.setInterface()
    }
    
    func setInterface() {
        
        totalWidth = 0
        self.removeSubviews()
        
        var xPosition: CGFloat = 0
        for i in 0..<numberOfElements {
            let button: UIButton
            if i <= self.currentIndex {
                button = UIButton(frame: CGRect(x: xPosition, y: 0, width: 40, height: 40))
                button.setTitle("\(i+1)", for: .normal)
                button.titleLabel?.font = UIFont.gciFontBold(21)
                button.setTitleColor(UIColor.tangerine, for: .normal)
                button.backgroundColor = UIColor.white
            } else {
                if let arrayOfControllers = arrayOfControllers, let viewController = arrayOfControllers[safe: i], viewController.isAccessible {
                    button = UIButton(frame: CGRect(x: xPosition, y: 0, width: 40, height: 40))
                    button.titleLabel?.font = UIFont.gciFontBold(21)
                    button.setTitleColor(UIColor.tangerine, for: .normal)
                } else {
                    button = UIButton(frame: CGRect(x: xPosition, y: 5, width: 30, height: 30))
                    button.titleLabel?.font = UIFont.gciFontBold(16)
                    button.setTitleColor(UIColor.cerulean, for: .normal)
                }
                button.setTitle("\(i+1)", for: .normal)
                button.backgroundColor = UIColor.white
                button.alpha = 0.7
            }
            button.tag = i
            button.setRounded()
            
            if let arrayOfControllers = arrayOfControllers, let viewController = arrayOfControllers[safe: i], viewController.isAccessible {
                button.addTarget(self, action: #selector(self.pressed(_:)), for: .touchUpInside)
            }
            
            xPosition += button.width
            totalWidth += button.width
            
            self.addSubview(button)
            
            if i != numberOfElements-1 {
                let dash = UIView(frame: CGRect(x: xPosition, y: 20, width: 25, height: 2))
                
                if i >= self.currentIndex {
                    if let arrayOfControllers = arrayOfControllers, let viewController = arrayOfControllers[safe: i+1], viewController.isAccessible {
                        dash.backgroundColor = UIColor.white
                    } else {
                        if i == self.currentIndex {
                            dash.backgroundColor = UIColor.clear
                            dash.drawDottedLine(start: CGPoint(x: dash.bounds.minX, y: dash.bounds.minY), end: CGPoint(x: dash.bounds.maxX, y: dash.bounds.minY), color: UIColor.white)
                        }
                    }
                } else {
                    dash.backgroundColor = UIColor.white
                }
                xPosition += dash.width
                totalWidth += dash.width
                
                self.addSubview(dash)
            }
        }
        
    }

    @IBAction func pressed(_ sender: UIButton) {
            self.actionOnTouch?(sender.tag)
    }
}
