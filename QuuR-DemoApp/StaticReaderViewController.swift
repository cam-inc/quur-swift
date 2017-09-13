//
//  StaticReaderViewController.swift
//  QuuR
//
//  Created by 江尻 幸生 on 2017/08/03.
//  Copyright © 2017 Yukio Ejiri. All rights reserved.
//

import UIKit
import QuuR

class StaticReaderViewController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!

    @IBOutlet private weak var readLabel: UILabel!

    fileprivate var qrCodeImage: UIImage? {
        didSet {
            guard let qrCodeImage = qrCodeImage else {
                return
            }
            guard
                let texts = QuuR.StaticReader.read(image: qrCodeImage),
                !texts.isEmpty else {
                    readLabel.text = "Could not read texts from this image."
                    return
            }
            imageView.image = qrCodeImage
            readLabel.text = texts.first
        }
    }

    @IBAction func readFromPhotoLibrary(_ sender: Any) {

        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
}

extension StaticReaderViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            qrCodeImage = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension StaticReaderViewController: UINavigationControllerDelegate {
}
