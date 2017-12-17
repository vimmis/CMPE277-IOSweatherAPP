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
    static var passedValue: String = ""
    var hourData: [String] = [] //etc needs to be calculated based on current local HOUR number
    var weatherDataID: [String] = [] //etc needs to be calculated based on current local HOUR number
    var tempData: [String] = [] //etc needs to be calculated based on current local HOUR number
    var tDay: String = ""
    var tWeather: String = ""
    var tMax: String = ""
    var tMin: String = ""
    var today: JSON? = nil
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
        today = Cities.jsonToday!
        let tmrwnoon = Cities.getTmrwNoonToUTC(ViewController.passedValue)
        super.viewDidLoad()
        NSLog("In controller, value passed: " + ViewController.passedValue)
        
        self.cityName.text = ViewController.passedValue.capitalized
        self.todayDay.text = Cities.getDay(ViewController.passedValue)
        self.cityWeather.text = today!["weather"][0]["description"].string!.capitalized
        if CityList.temp {
            self.cityMax.text = Cities.getF(today!["main"]["temp_max"].stringValue)
            self.cityMin.text = Cities.getF(today!["main"]["temp_min"].stringValue)
        }else{
            self.cityMax.text = today!["main"]["temp_max"].stringValue
            self.cityMin.text = today!["main"]["temp_min"].stringValue
        }
        let directions: [UISwipeGestureRecognizerDirection] = [.right, .left]
        for direction in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleSwipe(sender:)))
            gesture.direction = direction
            self.view.addGestureRecognizer(gesture)
        }
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
    
    @objc func handleSwipe(sender: UISwipeGestureRecognizer) {
            
            switch sender.direction {
                
            case UISwipeGestureRecognizerDirection.right:
                
                print("Swiped right")
                
                //change view controllers
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                
                let resultViewController = storyBoard.instantiateViewController(withIdentifier: "detailViewStoryBoard") as! ViewController
                let position = Cities.cities.index(of: ViewController.passedValue)
                if position != 0{
                    // Load data for next city going to be viewed
                    ViewController.passedValue = Cities.cities[position! - 1]
                    let cityobject = Cities.cityObjectsMap[ViewController.passedValue]
                    print("Selected city object :" + cityobject.debugDescription)
                    Cities.getToday((cityobject?.lat)!,(cityobject?.lon)!)
                    while (Cities.jsonToday == nil){
                        //do nothing
                    }
                    
                    Cities.getHourly((cityobject?.lat)!,(cityobject?.lon)!)
                    while (Cities.jsonHourly == nil){
                        //do nothing
                    }
                    let transition = CATransition()
                    transition.duration = 0.5
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromLeft
                    transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
                    view.window!.layer.add(transition, forKey: kCATransition)
                    self.present(resultViewController, animated:false, completion:nil)
                }
                
            case UISwipeGestureRecognizerDirection.left:
                
                print("Swiped left")
                
                //change view controllers
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                
                let resultViewController = storyBoard.instantiateViewController(withIdentifier: "detailViewStoryBoard") as! ViewController
                
                let position = Cities.cities.index(of: ViewController.passedValue)

                if position != (Cities.cities.count - 1){
                    // Load data for next city going to be viewed
                    ViewController.passedValue = Cities.cities[position! + 1]
                    let cityobject = Cities.cityObjectsMap[ViewController.passedValue]
                    print("Selected city object :" + cityobject.debugDescription)
                    Cities.getToday((cityobject?.lat)!,(cityobject?.lon)!)
                    while (Cities.jsonToday == nil){
                        //do nothing
                    }
                    
                    Cities.getHourly((cityobject?.lat)!,(cityobject?.lon)!)
                    while (Cities.jsonHourly == nil){
                        //do nothing
                    }
                    let transition = CATransition()
                    transition.duration = 0.5
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromRight
                    transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
                    view.window!.layer.add(transition, forKey: kCATransition)
                    self.present(resultViewController, animated:false, completion:nil)
                }
                
            default:
                break
        }
    }
    
}



