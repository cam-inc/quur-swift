//
//  Reader.swift
//  QuuR
//
//  Created by Yukio Ejiri on 2017/07/31.
//  Copyright © 2017年 C.A.Mobile, LTD. All rights reserved.
//

import UIKit
import AVFoundation

@objc public protocol ReaderDidDetectQRCode: NSObjectProtocol {
    func reader(_ reader: Reader, didDetect text: String)
}

public class Reader: UIView {

    let minZoomScale: CGFloat = 1.0

    @IBInspectable public var maxZoomScale: CGFloat = 8.0 {
        didSet {
            guard minZoomScale <= maxZoomScale else {
                return maxZoomScale = minZoomScale
            }
            guard 0 < maxZoomScale else {
                return maxZoomScale = 1.0
            }
        }
    }

    @IBInspectable public var isZoomable: Bool = true {
        didSet {
            if isZoomable {
                let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(Reader.pinchedGesture(gestureRecognizer:)))
                addGestureRecognizer(pinchGesture)
            } else {
                for recognizer in gestureRecognizers ?? [] {
                    removeGestureRecognizer(recognizer)
                }
            }
        }
    }

    fileprivate var oldZoomScale: CGFloat = 1.0

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

    #if TARGET_INTERFACE_BUILDER
    @IBOutlet public weak var delegate: AnyObject?
    #else
    public weak var delegate: ReaderDidDetectQRCode?
    #endif

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(Reader.didChangeOrientation(notification:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

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

    func pinchedGesture(gestureRecognizer: UIPinchGestureRecognizer) {
        guard let video = videoDevice else {
            return
        }
        do {
            try video.lockForConfiguration()
            var currentZoomScale: CGFloat = video.videoZoomFactor
            let pinchZoomScale: CGFloat = gestureRecognizer.scale

            if pinchZoomScale > 1.0 {
                currentZoomScale = oldZoomScale + pinchZoomScale-1
            } else {
                currentZoomScale = oldZoomScale - (1 - pinchZoomScale) * oldZoomScale
            }

            if currentZoomScale < minZoomScale {
                currentZoomScale = minZoomScale
            } else if currentZoomScale > maxZoomScale {
                currentZoomScale = maxZoomScale
            }

            if gestureRecognizer.state == .ended {
                oldZoomScale = currentZoomScale
            }

            video.videoZoomFactor = currentZoomScale
            video.unlockForConfiguration()
        } catch  {

        }
    }

    func didChangeOrientation(notification: Notification) {
        guard
            let connection = videoLayer?.connection,
            let device = notification.object as? UIDevice,
            let videoOrientation = device.videoOrientation else {
                return
        }
        videoLayer?.frame = bounds
        connection.videoOrientation = videoOrientation
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension Reader: AVCaptureMetadataOutputObjectsDelegate {

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

extension UIDevice {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch orientation {
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .portrait:
            return .portrait
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        case.faceUp:
            return .portrait
        case .faceDown:
            return .portraitUpsideDown
        case .unknown:
            return nil
        }
    }
}
