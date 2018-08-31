//
//  AssetManager.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 31/08/18.
//

import UIKit

class AssetManager {
    
    static func iconImage(_ term: String, size: Int) -> UIImage? {
        let filename = "icon-\(term)-\(size)"
        let image = UIImage(named: filename)
        return image
    }
}


