//
//  ReaderTest.swift
//  QuuR
//
//  Created by Yukio Ejiri on 2017/07/31.
//  Copyright © 2017 C.A.Mobile, LTD. All rights reserved.
//

import XCTest
@testable import QuuR

class ReaderTest: XCTestCase {

    private var reader: Reader!

    override func setUp() {
        super.setUp()
        reader = Reader()
    }
    
    override func tearDown() {
        super.tearDown()
        reader = nil
    }
    
    func testZoomableOn() {
        reader.isZoomable = true
        let recognizer = (reader.gestureRecognizers ?? []).first as? UIPinchGestureRecognizer
        XCTAssertNotNil(recognizer, "UIPinchGestureRecognizer does not set.")
    }

    func testZoomableOff() {
        reader.isZoomable = false
        XCTAssertNil(reader.gestureRecognizers, "Some gesture recognizers are still set.")
    }

    func testNegativeZoomScale() {
        reader.maxZoomScale = -100.0
        XCTAssertEqual(reader.maxZoomScale, 1.0, "maxZoomScale has still an illegal value.")
    }

    func testIllegalZoomScale() {
        reader.maxZoomScale = -3.0
        print(reader.maxZoomScale)

        XCTAssertEqual(reader.maxZoomScale, reader.minZoomScale, "max or min zoom scale has an illegal value.")
    }
}
