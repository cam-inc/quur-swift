//
//  UINavigationController+Orientation.swift
//  QuuR
//
//  Created by 江尻 幸生 on 2017/08/01.
//  Copyright © 2017年 Yukio Ejiri. All rights reserved.
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
