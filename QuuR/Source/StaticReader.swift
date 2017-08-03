//
//  StaticReader.swift
//  QuuR
//
//  Created by Yukio Ejiri on 2017/08/03.
//  Copyright © 2017年 C.A.Mobile, LTD. All rights reserved.
//

import Foundation

public class StaticReader {

    /// Read a text from a given static image name
    public static func read(imageName: String) -> [String]? {
        guard let image = UIImage(named: imageName) else {
            return nil
        }
        return read(image: image)
    }

    /// Read a text from a given static image
    public static func read(image: UIImage) -> [String]? {
        guard
            let ciImage = CIImage(image: image),
            let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: nil) else {
                return nil
        }

        guard let features = detector.features(in: ciImage) as? [CIQRCodeFeature] else {
            return nil
        }

        var messages = [String]()
        for feature in features {
            guard let messageString = feature.messageString else {
                continue
            }
            messages.append(messageString)
        }
        return messages
    }
}
