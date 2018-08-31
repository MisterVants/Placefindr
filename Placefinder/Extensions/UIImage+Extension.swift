//
//  UIImage+Extension.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 31/08/18.
//

import UIKit

extension UIImage {
    
    static func iconImage(_ identifier: String, size: Int) -> UIImage? {
        let filename = "icon-\(identifier)-\(size)"
        return UIImage(named: filename)
    }
}
