//
//  CustomTabBar.swift
//  GCI
//
//  Created by Anthony Chollet on 28/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit

class CustomTabBar: UITabBar {
    
    private var _safeAreaInsets = UIEdgeInsets.zero
    private var _subviewsFrames: [CGRect] = []
    
    @available(iOS 11.0, *)
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        
        if _safeAreaInsets != safeAreaInsets {
            _safeAreaInsets = safeAreaInsets
            
            invalidateIntrinsicContentSize()
            superview?.setNeedsLayout()
            superview?.layoutSubviews()
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        if #available(iOS 12.0, *) {
            let bottomInset = safeAreaInsets.bottom
            if bottomInset > 0 && size.height < 50 && (size.height + bottomInset < 90) {
                size.height += bottomInset
            }
        }
        return size
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            var tmp = newValue
            if let superview = superview, tmp.maxY !=
                superview.frame.height {
                tmp.origin.y = superview.frame.height - tmp.height
            }
            
            super.frame = tmp
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let state = subviews.map { $0.frame }
        if (state.first { $0.width == 0 } == nil) {
            _subviewsFrames = state
        } else {
            zip(subviews, _subviewsFrames).forEach { (view, rect) in
                view.frame = rect
            }
        }
        
    }
    
}
