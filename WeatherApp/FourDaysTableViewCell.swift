//
//  FourDaysTableViewCell.swift
//  WeatherApp
//
//  Created by Vimmi Swami on 11/26/17.
//  Copyright © 2017 Vimmi Swami. All rights reserved.
//

import UIKit

class FourDaysTableViewCell: UITableViewCell {
    @IBOutlet weak var DayText: UITextField!
    @IBOutlet weak var weatherImageId: UIImageView!
    @IBOutlet weak var minTemp: UITextField!
    @IBOutlet weak var maxTemp: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
