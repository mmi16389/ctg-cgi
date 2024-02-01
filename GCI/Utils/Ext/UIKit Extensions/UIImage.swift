//
//  UIImage.swift
//  neopixl_ext
//
//  Created by Joris Thiery on 15/12/2017.
//  Copyright © 2017 Joris Thiery. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// UIImage Cropped to CGRect.
    public func cropped(to rect: CGRect) -> UIImage {
        guard rect.size.height < size.height && rect.size.height < size.height else {
            return self
        }
        guard let image: CGImage = cgImage?.cropping(to: rect) else {
            return self
        }
        return UIImage(cgImage: image)
    }
    
    /// UIImage scaled to height with respect to aspect ratio.
    public func scaled(toHeight: CGFloat, with orientation: UIImage.Orientation? = nil) -> UIImage? {
        let scale = toHeight / size.height
        let newWidth = size.width * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: toHeight))
        draw(in: CGRect(x: 0, y: 0, width: newWidth, height: toHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// UIImage scaled to width with respect to aspect ratio.
    public func scaled(toWidth: CGFloat, with orientation: UIImage.Orientation? = nil) -> UIImage? {
        let scale = toWidth / size.width
        let newHeight = size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: toWidth, height: newHeight))
        draw(in: CGRect(x: 0, y: 0, width: toWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    public convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            self.init()
            return
        }
        UIGraphicsEndImageContext()
        guard let aCgImage = image.cgImage else {
            self.init()
            return
        }
        self.init(cgImage: aCgImage)
    }

    func saveImageInDisk(withName name: String) -> String? {
        
        if let data = self.jpegData(compressionQuality: 0.8) {
            let fileName = "\(name).jpg"
            let path = FileManager.default.getDocumentsDirectoryURL().appendingPathComponent(fileName)
            try? data.write(to: path)
            return fileName
        } else {
            return nil
        }
    }
    
    func imageInDisk(forName name: String!) -> UIImage? {
        
        let fileName = "\(name).jpg"
        let path = FileManager.default.getDocumentsDirectoryURL().appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: path) {
            return UIImage(data: data)
        } else {
            return nil
        }
    }
    
    func resizeAndCompressed(toMaxWith maxWidth: Float = 1920.0, andMaxHeight maxHeight: Float = 1080.0, forCompression compressionQuality: Double = 0.8) -> UIImage {
        var actualHeight = Float(self.size.height)
        var actualWidth = Float(self.size.width)
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            } else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            } else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        self.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = img?.jpegData(compressionQuality: CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        return UIImage(data: imageData!) ?? UIImage()
    }
    
    func addText(drawText text: NSString) -> UIImage {
        //draw image first
        UIGraphicsBeginImageContext(self.size)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        //text attributes
        let font = UIFont.gciFontBold(21)
        let text_style = NSMutableParagraphStyle()
        text_style.alignment = NSTextAlignment.center
        let text_color = UIColor.white
        let attributes = [NSAttributedString.Key.font: font,
                          NSAttributedString.Key.paragraphStyle: text_style,
                          NSAttributedString.Key.foregroundColor: text_color]
        
        //vertically center (depending on font)
        let text_h = font.lineHeight
        let text_y: CGFloat = 10.0
        let text_rect = CGRect(x: 0, y: text_y, width: self.size.width, height: text_h)
        text.draw(in: text_rect.integral, withAttributes: attributes)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result!
    }
}
