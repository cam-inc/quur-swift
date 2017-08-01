//
//  ReaderViewController.swift
//  QuuR-DemoApp
//
//  Created by Yukio Ejiri on 2017/07/06.
//  Copyright © 2017年 C.A.Mobile, LTD. All rights reserved.
//

import UIKit
import QuuR

class ReaderViewController: UIViewController {

    @IBOutlet fileprivate weak var reader: Reader!

    override func viewDidLoad() {
        super.viewDidLoad()
        reader.startDetection()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}

extension ReaderViewController: ReaderDidDetectQRCode {

    public func reader(_ reader: Reader, didDetect text: String) {
        guard
            (presentedViewController == nil),
            let url = URL(string: text) else {
            return
        }
        let alert = UIAlertController(title: "Result", message: text, preferredStyle: .actionSheet)
        if UIApplication.shared.canOpenURL(url) {
            alert.addAction(UIAlertAction(title: "Open in Safari", style: .default, handler: { (action: UIAlertAction) in
                    UIApplication.shared.openURL(url)
            }))
        }
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
