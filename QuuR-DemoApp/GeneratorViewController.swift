//
//  GeneratorViewController.swift
//  QuuR
//
//  Created by Yukio Ejiri on 2017/07/06.
//  Copyright © 2017 C.A.Mobile, LTD. All rights reserved.
//

import UIKit
import QuuR

class GeneratorViewController: UIViewController {

    @IBOutlet weak var sliderR: UISlider!
    @IBOutlet weak var sliderG: UISlider!
    @IBOutlet weak var sliderB: UISlider!

    @IBOutlet fileprivate weak var qrcode: UIImageView!
    @IBOutlet private weak var text: UITextField!

    fileprivate var code: QuuR.Code?

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }

    func keyboardWillShow(notification: Notification) {

        guard let rect = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        guard let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }

        UIView.animate(withDuration: duration, animations: { () in
            let transform = CGAffineTransform(translationX: 0, y: -(rect.size.height))
            self.view.transform = transform
        })
    }

    func keyboardWillHide(notification: Notification) {

        guard let duration = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as?  TimeInterval else {
            return
        }

        UIView.animate(withDuration: duration, animations: { () in
            self.view.transform = CGAffineTransform.identity
        })
    }

    @IBAction func updateRGB(_ sender: Any) {
        code?.color = CIColor(red: CGFloat(sliderR.value), green: CGFloat(sliderG.value), blue: CGFloat(sliderB.value))
        qrcode.image = code?.image
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension GeneratorViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        if let text = textField.text {
            if code == nil {
                code = QuuR.Code(from: text, quality: .middle)
            } else {
                code?.text = text
            }
            qrcode.image = code?.image
        }
        return true
    }
}
