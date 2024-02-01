//
//  LoaderViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 26/04/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit
import Lottie

class LoaderViewController: UIViewController {
    private let loadAnimationView = LottieAnimationView()
    var canRotate = false
    
    @objc func iPadCanRotate() {}
    
    convenience init(isTransparent: Bool, canRotate: Bool = false) {
        self.init()
        if isTransparent {
            let loadAnimation = LottieAnimation.named("animation_loader_blue_tint")
            self.loadAnimationView.animation = loadAnimation
            self.view.backgroundColor = UIColor.clear
        } else {
            let loadAnimation = LottieAnimation.named("animation_loader")
            self.loadAnimationView.animation = loadAnimation
            self.view.backgroundColor = UIColor.cerulean.withAlphaComponent(0.9)
        }
        
        self.canRotate = canRotate
        loadAnimationView.loopMode = .loop
        loadAnimationView.contentMode = .scaleAspectFit
        
        self.view.addSubview(loadAnimationView)
        self.setConstraint()
    }
    
    func setConstraint() {
        loadAnimationView.translatesAutoresizingMaskIntoConstraints = false
        
        let centerY = NSLayoutConstraint(item: loadAnimationView,
                                         attribute: .centerY,
                                         relatedBy: .equal,
                                         toItem: self.view,
                                         attribute: .centerY,
                                         multiplier: 1,
                                         constant: 0)
        
        let width = NSLayoutConstraint(item: loadAnimationView,
                                     attribute: .width,
                                     relatedBy: .equal,
                                     toItem: nil,
                                     attribute: .notAnAttribute,
                                     multiplier: 1,
                                     constant: DeviceType.isIpad ? 300 : self.view.width)
        
        let height = NSLayoutConstraint(item: loadAnimationView,
                                        attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1,
                                        constant: DeviceType.isIpad ? 300 : self.view.height)
        
        let centerX = NSLayoutConstraint(item: loadAnimationView,
                                          attribute: .centerX,
                                          relatedBy: .equal,
                                          toItem: self.view,
                                          attribute: .centerX,
                                          multiplier: 1,
                                          constant: 0)
        
        self.view.addConstraints([centerY, centerX, width, height])
        self.view.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadAnimationView.play()
    }
    
}
