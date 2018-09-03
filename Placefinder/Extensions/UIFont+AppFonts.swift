//
//  UIFont+AppFonts.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 02/09/18.
//

import UIKit

extension UIFont {
    
    static func robotoRegular(_ fontSize: CGFloat) -> UIFont {
        let fontName = "Roboto-Regular"
        guard let font = UIFont(name: fontName, size: fontSize) else { fatalError("Font file not found in bundle for font \(fontName)") }
        return font
    }
    
    // Add more fonts as needed
}
