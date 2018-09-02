//
//  ViewController+Extension.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 28/08/18.
//

import UIKit

extension UIViewController {
    
//    static func hideKeyboardOnTouch(_ contextViewController: UIViewController) {
//        let tapGesture = UITapGestureRecognizer(target: contextViewController, action: #selector(UIViewController.dismissKeyboard))
//        contextViewController.view.addGestureRecognizer(tapGesture)
//    }
//
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }
    
    func promptAlert(withTitle title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
