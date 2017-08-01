//
//  ReaderViewController.swift
//  QuuR-DemoApp
//
//  Created by 江尻 幸生 on 2017/07/06.
//  Copyright © 2017年 Yukio Ejiri. All rights reserved.
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
        print(text)
    }
}
