//
//  UICollectionView.swift
//  neopixl_ext
//
//  Created by Joris Thiery on 15/12/2017.
//  Copyright © 2017 Joris Thiery. All rights reserved.
//

import UIKit

extension UICollectionView {

    public func reloadData(_ completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion: { _ in
            completion()
        })
    }
    
    static func itemSize(totalWidth: CGFloat, itemsPerRow: CGFloat, collectionInsets: UIEdgeInsets, horizontalSpaceBetweenItem: CGFloat = 10, maxHeight: CGFloat = 110) -> CGSize {
        let paddingSpace = collectionInsets.left + collectionInsets.right + horizontalSpaceBetweenItem * itemsPerRow
        let availableWidth = totalWidth - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        let height = widthPerItem+4
        
        return CGSize(width: widthPerItem, height: height > maxHeight ? maxHeight : height)
    }
    
}
