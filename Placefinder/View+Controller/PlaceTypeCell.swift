//
//  PlaceTypeCell.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 29/08/18.
//

import UIKit

class PlaceTypeCell: UITableViewCell {
    
    static let reuseIdentifier = "PlaceTypeCell"
    
    var model: GooglePlaceType? {
        didSet {
            fillUI()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        textLabel?.text = "Place Type"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func fillUI() {
        textLabel?.text = model?.rawValue
    }
}
