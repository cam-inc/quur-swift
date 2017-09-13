//
//  UIAlertController+Orientation.swift
//  QuuR
//
//  Created by Yukio Ejiri on 2017/08/09.
//  Copyright © 2017 Yukio Ejiri. All rights reserved.
//

import UIKit

extension UIAlertController {

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override open var shouldAutorotate: Bool {
        return false
    }
}
