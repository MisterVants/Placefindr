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
        didSet {
            fillUI()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        textLabel?.text = "Auto result"
        detailTextLabel?.text = "BBB"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func fillUI() {
        textLabel?.attributedText = model?.attributedPrimaryText
        detailTextLabel?.attributedText = model?.attributedSecondaryText
    }
}
