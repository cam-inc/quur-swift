//
//  Code.swift
//  QuuR
//
//  Created by 江尻 幸生 on 2017/07/31.
//  Copyright © 2017年 Yukio Ejiri. All rights reserved.
//

import Foundation

public struct Code {

    public private(set) var image: UIImage?
    public var encoding = String.Encoding.utf8

    public var text: String {
        didSet {
            image = generate(from: text, encoding: encoding, scaleX: quality.rawValue, scaleY: quality.rawValue)
        }
    }

    public var quality: Quality {
        didSet {
            image = generate(from: text, encoding: encoding, scaleX: quality.rawValue, scaleY: quality.rawValue)
        }
    }

    public init(from: String, quality: Quality) {
        self.text = from
        self.quality = quality
        image = generate(from: text, encoding: encoding, scaleX: quality.rawValue, scaleY: quality.rawValue)
    }
}
