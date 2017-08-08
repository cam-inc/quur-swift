//
//  UINavigationController+Orientation.swift
//  QuuR
//
//  Created by Yukio Ejiri on 2017/08/01.
//  Copyright © 2017 C.A.Mobile, LTD. All rights reserved.
//

import UIKit

extension UINavigationController {

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {

        if let _ = self.visibleViewController {
            return self.visibleViewController!.supportedInterfaceOrientations
        }
        let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.portrait]
        return orientation
    }

    override open var shouldAutorotate: Bool {
        if let _ = self.visibleViewController {
            return self.visibleViewController!.shouldAutorotate
        }
        return false
    }
}
