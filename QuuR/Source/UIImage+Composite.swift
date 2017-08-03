//
//  UIImage+Composite.swift
//  QuuR
//
//  Created by Yukio Ejiri on 2017/08/02.
//  Copyright © 2017年 C.A.Mobile, LTD. All rights reserved.
//

import UIKit

extension UIImage {

    public func compositeToCenter(image: UIImage) -> UIImage? {

        guard let centerImage = scaledToFitTo(newSize: CGSize(width: size.width * 0.2, height: size.height * 0.2), image: image) else {
            return nil
        }

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }

        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        centerImage.draw(in: CGRect(x: (size.width - centerImage.size.width) / 2, y: (size.height - centerImage.size.height) / 2, width: centerImage.size.width, height: centerImage.size.height), blendMode: .normal, alpha: 1.0)
        guard let finalImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        return finalImage
    }

    internal func scaledTo(size: CGSize, rect: CGRect, image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: rect)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage
    }

    internal func scaledToFitTo(newSize: CGSize, image: UIImage) -> UIImage? {
        if image.size.width < newSize.width && image.size.height < newSize.height {
            return image.copy() as? UIImage
        }
        let widthScale: CGFloat = newSize.width / image.size.width
        let heightScale: CGFloat = newSize.height / image.size.height
        let scaleFactor: CGFloat = (widthScale < heightScale) ? widthScale : heightScale
        let scaledSize = CGSize(width: image.size.width * scaleFactor, height: image.size.height * scaleFactor);
        return scaledTo(size: scaledSize, rect: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height), image: image)
    }
}
