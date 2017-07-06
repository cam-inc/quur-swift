//
//  QuuR.swift
//  QuuR
//
//  Created by 江尻 幸生 on 2017/07/06.
//  Copyright © 2017年 Yukio Ejiri. All rights reserved.
//

import Foundation

public struct Code {

    public private(set) var image: UIImage?
    public private(set) var text: String

    public init(from: String, quality: Quality) {
        text = from
        image = generate(from: text, scaleX: quality.rawValue, scaleY: quality.rawValue)
    }
}

public enum Quality: CGFloat {
    case low = 5.0
    case middle = 8.0
    case high = 13.0
}
