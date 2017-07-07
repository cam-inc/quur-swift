//
//  function.swift
//  QuuR
//
//  Created by 江尻 幸生 on 2017/07/06.
//  Copyright © 2017年 Yukio Ejiri. All rights reserved.
//

import Foundation

internal func generate(from string: String, scaleX: CGFloat, scaleY: CGFloat) -> UIImage? {

    let data = string.data(using: String.Encoding.ascii)

    guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
        return nil
    }

    filter.setValue(data, forKey: "inputMessage")
    let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)

    guard let output = filter.outputImage?.applying(transform) else {
        return nil
    }
    return UIImage(ciImage: output)
}
