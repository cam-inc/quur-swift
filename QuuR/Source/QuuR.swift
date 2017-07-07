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
    fileprivate let videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    fileprivate var videoLayer: AVCaptureVideoPreviewLayer? {
        willSet {
            videoLayer?.removeFromSuperlayer()
        }
    }

    fileprivate var videoInput: AVCaptureDeviceInput? {
        willSet {
            captureSession.removeInput(videoInput)
        }
    }

    fileprivate var metadataOutput: AVCaptureMetadataOutput? {
        willSet {
            captureSession.removeOutput(metadataOutput)
        }
    }

    public weak var delegate: ReaderDidDetectQRCode?

    public func startDetection() {

        if captureSession.isRunning {
            return
        }

        do {
            videoInput = try AVCaptureDeviceInput(device: videoDevice)
            captureSession.addInput(videoInput)

            metadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(metadataOutput)
            metadataOutput?.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput?.metadataObjectTypes = [AVMetadataObjectTypeQRCode]

            guard let video = AVCaptureVideoPreviewLayer(session: captureSession) else {
                return
            }
            video.frame = bounds
            video.videoGravity = AVLayerVideoGravityResizeAspectFill
            layer.addSublayer(video)
            videoLayer = video

            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
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
