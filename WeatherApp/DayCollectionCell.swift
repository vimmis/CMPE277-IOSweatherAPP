//
//  DayCollectionCell.swift
//  WeatherApp
//
//  Created by Vimmi Swami on 11/26/17.
//  Copyright © 2017 Vimmi Swami. All rights reserved.
//

import UIKit
//Linked cell for 24 hour display in ViewController.swift
class DayCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var hourText: UITextField!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var avgTemp: UITextField!
}
