//
//  ModalImageViewController.swift
//  GCI
//
//  Created by Anthony Chollet on 24/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class ModalImageViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var constraintLeading: NSLayoutConstraint!
    @IBOutlet weak var constraintTop: NSLayoutConstraint!
    @IBOutlet weak var constrainBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintTrailing: NSLayoutConstraint!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var scrollview: UIScrollView!
    
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imgView.image = image
        scrollview.minimumZoomScale = 1.0
        scrollview.maximumZoomScale = 4.0
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.doubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollview.addGestureRecognizer(doubleTap)
    }
    
    @objc func canRotate() {}
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func btnCloseTouched(_ sender: Any) {
        UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        self.dismiss(animated: true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgView
    }
    
    @objc func doubleTap(_ sender: UITapGestureRecognizer? = nil) {
        var scale: CGFloat = 0.0
        if scrollview.zoomScale < scrollview.maximumZoomScale {
            scale = min(scrollview.zoomScale * 2, scrollview.maximumZoomScale)
        } else {
            scale = scrollview.minimumZoomScale
        }
        
        if scale != scrollview.zoomScale {
            if let point = sender?.location(in: imgView) {
                let scrollSize = scrollview.frame.size
                let size = CGSize(width: scrollSize.width / scale,
                                  height: scrollSize.height / scale)
                let origin = CGPoint(x: point.x - size.width / 2,
                                     y: point.y - size.height / 2)
                scrollview.zoom(to: CGRect(origin: origin, size: size), animated: true)
                print(CGRect(origin: origin, size: size))
            }
        }
    }
}
