//
//  QuuR.swift
//  QuuR
//
//  Created by 江尻 幸生 on 2017/07/06.
//  Copyright © 2017年 Yukio Ejiri. All rights reserved.
//

import Foundation
import AVFoundation

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

public protocol ReaderDidDetectQRCode: NSObjectProtocol {
    func reader(_ reader: Reader, didDetect text: String)
}

public class Reader: UIView {

    fileprivate let captureSession = AVCaptureSession()
    fileprivate var videoLayer: AVCaptureVideoPreviewLayer?

    public weak var delegate: ReaderDidDetectQRCode?

    public func startDetection() {

        if captureSession.isRunning {
            return
        }

        let videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            captureSession.addInput(videoInput)

            let metadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]

            guard let video = AVCaptureVideoPreviewLayer(session: captureSession) else {
                return
            }
            video.frame = bounds
            video.videoGravity = AVLayerVideoGravityResizeAspectFill
            layer.addSublayer(video)
            videoLayer = video

            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }

        } catch let error {
            print(error)
        }
    }

    public func stopDetection() {
        captureSession.stopRunning()
    }
}

extension Reader: AVCaptureMetadataOutputObjectsDelegate {

    // swiftlint:disable:next implicitly_unwrapped_optional
    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {

        for any in metadataObjects {
            guard let metadata = any as? AVMetadataMachineReadableCodeObject else {
                continue
            }

            guard
                metadata.type == AVMetadataObjectTypeQRCode,
                let text = metadata.stringValue else {
                return
            }

            delegate?.reader(self, didDetect: text)
        }
    }
}
