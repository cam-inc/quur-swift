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

    let reader = QuuR.Reader()

    override func viewDidLoad() {
        super.viewDidLoad()

        reader.frame = view.frame
        reader.delegate = self
        view.addSubview(reader)
        reader.startDetection()
    }
}

extension ReaderViewController: ReaderDidDetectQRCode {

    public func reader(_ reader: Reader, didDetect text: String) {
        print(text)
    }
}
