//
//  ViewController.swift
//  WeatherApp
//
//  Created by Vimmi Swami on 11/24/17.
//  Copyright © 2017 Vimmi Swami. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    let cellSpacingHeight: CGFloat = 5

    //let weatherController = WeatherController()
    var passedValue: String = ""
    var hourData: [String] = ["0 AM","3 AM"] //etc needs to be calculated based on current local HOUR number
    var weatherDataID: [String] = ["01d","01n"] //etc needs to be calculated based on current local HOUR number
    var tempData: [String] = ["38.2","22.6"] //etc needs to be calculated based on current local HOUR number
    
    @IBOutlet weak var cityName: UITextField!
    @IBOutlet weak var todayDay: UITextField!
    @IBOutlet weak var cityWeather: UITextField!
    @IBOutlet weak var cityMax: UITextField!
    @IBOutlet weak var cityMin: UITextField!
   
    @IBAction func settings(_ sender: UIButton) {
        NSLog("im tapped")
       // NSLog(weatherController.fetchWeather(cityName))
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("In controller, value passed")
        self.cityName.text = passedValue
        self.automaticallyAdjustsScrollViewInsets = false;
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height / 4;
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        NSLog("inside table view")
        let cell = tableView.dequeueReusableCell(withIdentifier: "fourdaysCell") as! FourDaysTableViewCell
        
        cell.DayText.text = "Monday"
        cell.maxTemp.text = "40"
        cell.minTemp.text = "20"
        var urlString = "https://openweathermap.org/img/w/" + "01n" + ".png"
        if let url = NSURL(string: urlString) {
            if let data = NSData(contentsOf: url as URL) {
                cell.weatherImageId.image = UIImage(data: data as Data)
            }
        }
        return cell
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1     //return number of sections in collection view
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //Total number of columns shown for 24 hours-3hr interval is 9
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        NSLog("inside collection view")
        var cell: DayCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "dayCell", for: indexPath) as! DayCollectionCell
        cell.hourText.text = "0 AM"//hourData[indexPath.row]
        var urlString = "https://openweathermap.org/img/w/"  + "01d.png"//weatherDataID[indexPath.row]
        if let url = NSURL(string: urlString) {
            if let data = NSData(contentsOf: url as URL) {
                cell.weatherImage.image = UIImage(data: data as Data)
            }
        }

        cell.avgTemp.text = "36.82" //tempData[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    

}



