//
//  Reader.swift
//  QuuR
//
//  Created by Yukio Ejiri on 2017/07/31.
//  Copyright © 2017 C.A.Mobile, LTD. All rights reserved.
//

import UIKit
import AVFoundation

/// Called when QRCode was detected
@objc public protocol ReaderDidDetectQRCode: NSObjectProtocol {
    func reader(_ reader: Reader, didDetect text: String)
}

/// Read QRCode from the video input.
open class Reader: UIView {

    public static var ReaderStateChangedNotification = Notification.Name("com.camplat.QuuR.Reader.DidChangeReaderState")

    /// Status of the reader object
    public private(set) var status: State = .unknown {
        didSet {
            NotificationCenter.default.post(name: Reader.ReaderStateChangedNotification, object: status)
            switch status {
            case .requestAccess:
                requestVideoAccess()
            case .authorized:
                configureSession()
            case .ready:
                captureSession.startRunning()
            case .suspend:
                captureSession.stopRunning()
            default:
                break
            }
        }
    }

    /// Minimum zooming scale of the video input
    let minZoomScale: CGFloat = 1.0

    /// Maximum zooming scale of the video input
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

    /// Enable to zoom the video input by pinching gesture.
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

    /// For calculating the current zoom scale
    fileprivate var oldZoomScale: CGFloat = 1.0

    fileprivate let captureSession = AVCaptureSession()

    fileprivate let videoDevice: AVCaptureDevice? = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)

    fileprivate var videoLayer: AVCaptureVideoPreviewLayer?

    fileprivate var videoInput: AVCaptureDeviceInput?

    fileprivate var metadataOutput = AVCaptureMetadataOutput()

    private let sessionQueue = DispatchQueue(label: "com.camplat.QuuR.queue.reader",
                                             attributes: [],
                                             target: nil)

    #if TARGET_INTERFACE_BUILDER
    @IBOutlet public weak var delegate: AnyObject?
    #else
    public weak var delegate: ReaderDidDetectQRCode?
    #endif

    open override func willMove(toSuperview newSuperview: UIView?) {
        NotificationCenter.default.addObserver(self, selector: #selector(Reader.didChangeOrientation(notification:)), name: .UIDeviceOrientationDidChange, object: nil)
    }

    open override func removeFromSuperview() {
        NotificationCenter.default.removeObserver(self)
        sessionQueue.async { [weak self] in
            self?.stopDetection()
        }
    }

    /// Start using the camera and detecting QRCode from the video input.
    open func startDetection() {
        switch status {
        case .suspend:
            status = .ready
        default:
            status = .requestAccess
        }
    }

    /// Returns the user's authorization status for the camera device
    public var authorizationStatus: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
    }

    /// Requests access to the camera device
    private func requestVideoAccess() {
        switch authorizationStatus {
        case .authorized:
            status = .authorized
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { [weak self] granted in
                self?.status = (granted) ? .authorized : .notAuthorized
                self?.sessionQueue.resume()
            })
        default:
            status = .notAuthorized
        }
    }

    /// Setup the video session
    private func configureSession() {

        do {
            videoInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch let error {
            return status = .configurationFailed(Reader.Error(message: error.localizedDescription))
        }

        guard
            captureSession.canAddInput(videoInput),
            captureSession.canAddOutput(metadataOutput) else {
                return status = .configurationFailed(Reader.Error(message: "Could not configure the session."))
        }
        captureSession.beginConfiguration()
        captureSession.addInput(videoInput)
        captureSession.addOutput(metadataOutput)
        captureSession.commitConfiguration()
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]

        videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        guard let videoLayer = videoLayer else {
            return status = .configurationFailed(Reader.Error(message: "Could not create the preview layer."))
        }
        videoLayer.frame = bounds
        videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

        DispatchQueue.main.async { [weak self] in
            self?.layer.addSublayer(videoLayer)
        }

        status = .ready
    }

    /// Stop updating the video input.
    open func stopDetection() {
        status = .suspend
    }

    /// Change the zoom scale of the video input.
    func pinchedGesture(gestureRecognizer: UIPinchGestureRecognizer) {
        guard let video = videoDevice else {
            return
        }
        do {
            try video.lockForConfiguration()
        } catch (let error)  {
            return print(error.localizedDescription)
        }

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
    }

    /// Follow the device orientation
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

extension Reader {

    /// Reader.State
    ///
    /// - unknown: Not initialized
    /// - requestAccess: Requesting to access the camera device
    /// - authorized: Authorized to access
    /// - notAuthorized: User decided to deny to access
    /// - ready: Reader is ready to capturing
    /// - configurationFailed: Something was failed to configure the camera device
    /// - suspend: The video input is suspended
    public enum State {
        case unknown
        case requestAccess
        case authorized
        case notAuthorized
        case ready
        case configurationFailed(Reader.Error)
        case suspend
    }

}

extension Reader {

    /// Reader.Error
    public class Error: Swift.Error {
        public private(set) var message: String

        public init(message: String) {
            self.message = message
        }
    }
}

public extension UIDevice {
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
