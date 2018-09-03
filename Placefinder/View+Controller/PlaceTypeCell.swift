//
//  PlaceTypeCell.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 29/08/18.
//

import UIKit

class PlaceTypeCell: UITableViewCell {
    
    static let reuseIdentifier = "PlaceTypeCell"
    
    private let iconSize: Int = 24
    
    var model: GooglePlaceType? {
        didSet { fillUI() }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        textLabel?.font = UIFont.robotoRegular(17.0)
        textLabel?.textColor = .darkGray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func fillUI() {
        guard let model = model else { return }
        textLabel?.text = model.localizedTitle
        imageView?.image = UIImage.iconImage(model.iconIdentifier, size: iconSize)
        imageView?.image = imageView?.image?.withRenderingMode(.alwaysTemplate)
        imageView?.tintColor = .lightGray
    }
}
