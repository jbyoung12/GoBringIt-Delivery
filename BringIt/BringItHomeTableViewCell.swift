//
//  BringItHomeTableViewCell.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/16/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit

class BringItHomeTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var restaurantBannerImage: UIImageView!
    //@IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var cuisineTypeLabel: UILabel!
    @IBOutlet weak var restaurantHoursLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
