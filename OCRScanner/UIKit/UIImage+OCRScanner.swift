//
//  UIImage+OCRScanner.swift
//  OCRScanner
//
//  Created by 이동근 on 2021/06/22.
//

import UIKit

extension UIImage {
    func scaledImage(_ maxDimension: CGFloat) -> UIImage? {
        guard size.width > maxDimension || size.height > maxDimension else {
            return self
        }
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        
        if size.width > size.height {
            scaledSize.height = size.height / size.width * scaledSize.width
        } else {
            scaledSize.width = size.width / size.height * scaledSize.height
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    func crop(_ rect: CGRect) -> UIImage? {
        let cropRect = rect.applying(CGAffineTransform(scaleX: self.scale, y: self.scale))
        
        guard let rotatedImage = rotate(.identity),
              let croppedImage = rotatedImage.cgImage?.cropping(to: cropRect) else {
            return nil
        }
        
        return UIImage(cgImage: croppedImage, scale: self.scale, orientation: rotatedImage.imageOrientation)
    }
    
    func rotate(_ transform: CGAffineTransform) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, true, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.translateBy(x: self.size.width / 2, y: self.size.height / 2)
        context.concatenate(transform)
        context.translateBy(x: self.size.width / -2, y: self.size.height / -2)
        
        draw(in: CGRect(origin: .zero, size: self.size))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
