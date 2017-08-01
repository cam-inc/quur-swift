//
//  Code.swift
//  QuuR
//
//  Created by Yukio Ejiri on 2017/07/31.
//  Copyright © 2017年 C.A.Mobile, LTD. All rights reserved.
//

import Foundation

public struct Code {

    /// UIImage QRCode representation
    public var image: UIImage? {
        guard let ciImage = ciImage else {
            return nil
        }
        return UIImage(ciImage: ciImage)
    }

    /// CIImage QRCode representation
    public var ciImage: CIImage? {
        let data = text.data(using: encoding)

        guard let qrCodeFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }

        qrCodeFilter.setValue(data, forKey: "inputMessage")
        qrCodeFilter.setValue(errorCorrectionLevel.rawValue, forKey: "inputCorrectionLevel")
        let transform = CGAffineTransform(scaleX: quality.rawValue, y: quality.rawValue)

        guard let qrOutput = qrCodeFilter.outputImage?.applying(transform) else {
            return nil
        }

        guard let colorFilter = CIFilter(name: "CIFalseColor") else {
            return nil
        }

        colorFilter.setDefaults()
        colorFilter.setValue(qrOutput, forKey: "inputImage")
        colorFilter.setValue(color, forKey: "inputColor0")
        colorFilter.setValue(backgroundColor, forKey: "inputColor1")
        return colorFilter.outputImage
    }

    /// Text encoding
    public var encoding = String.Encoding.utf8

    /// Foreground color of the QRCode
    public var color = CIColor(red: 0, green: 0, blue: 0)

    /// Background color of the QRCode
    public var backgroundColor = CIColor(red: 1, green: 1, blue: 1)

    /// A string to be included a QRCode
    public var text: String

    /// Affected to a size to generated
    public var quality: Quality

    /// A level to recovery data if the QRCode is dirty or damaged
    public var errorCorrectionLevel: ErrorCorrectionLevel = .low

    public init(from: String, quality: Quality) {
        self.text = from
        self.quality = quality
    }
}
