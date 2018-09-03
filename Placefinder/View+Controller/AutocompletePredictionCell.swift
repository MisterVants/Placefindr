//
//  AutocompletePredictionCell.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 29/08/18.
//

import GooglePlaces

class AutocompletePredictionCell: UITableViewCell {
    
    static let reuseIdentifier = "ResultCell"
    
    var model: GMSAutocompletePrediction? {
        didSet { fillUI() }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        textLabel?.font = UIFont.robotoRegular(17.0)
        textLabel?.textColor = .darkGray
        detailTextLabel?.font = UIFont.robotoRegular(14.0)
        detailTextLabel?.textColor = .lightGray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func fillUI() {
        textLabel?.attributedText = model?.attributedPrimaryText
        detailTextLabel?.attributedText = model?.attributedSecondaryText
        imageView?.image = UIImage.iconImage("place", size: 36)
        imageView?.image = imageView?.image?.withRenderingMode(.alwaysTemplate)
        imageView?.tintColor = .lightGray
    }
}
