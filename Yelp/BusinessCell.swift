//
//  BusinessCell.swift
//  Yelp
//
//  Created by Gelei Chen on 25/1/2016.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var reviesCountsLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    
    @IBOutlet weak var styleLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var business : Business! {
        didSet {
            nameLabel.text = business.name
            thumbImageView.setImageWithURL(business.imageURL!)
            ratingImageView.setImageWithURL(business.ratingImageURL!)
            reviesCountsLabel.text = "\(business.reviewCount!) Reviews"
            addressLabel.text = business.address
            
            styleLabel.text = business.categories
            distanceLabel.text = business.distance
//            priceLabel.text = business.
            
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        thumbImageView.layer.cornerRadius = 3
        thumbImageView.clipsToBounds = true
        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
        // Initialization code
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
