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
    var hourData: [[String]] = [] //holds hourly data for 24 hr scrollview
    var weatherDataID: [String] = [] //holds 4days data
    var fourdayData: [[String]] = []
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
        super.viewDidLoad()
        if CityList.alertmsg != nil{
            let alert = UIAlertController(title: "ERROR", message: CityList.alertmsg, preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            let time = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: time){
                alert.dismiss(animated: true, completion: nil)
            }
            CityList.alertmsg = nil;
            settings(UIButton())
        }
        explore4days()
        explorehourly()
        NSLog("In controller, value passed: " + ViewController.passedValue)
        
        self.cityName.text = ViewController.passedValue.capitalized
        self.todayDay.text = Cities.getDay(ViewController.passedValue)
        self.cityWeather.text = today!["weather"][0]["main"].string!.capitalized
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
        print("Inside each cell of index: \(indexPath.row)")
        cell.DayText.text = fourdayData[indexPath.row][0]
        cell.maxTemp.text = fourdayData[indexPath.row][2]
        cell.minTemp.text = fourdayData[indexPath.row][3]
        var urlString = "https://openweathermap.org/img/w/" + fourdayData[indexPath.row][1] + ".png"
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
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        NSLog("inside collection view")
        var cell: DayCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "dayCell", for: indexPath) as! DayCollectionCell
        cell.hourText.text = hourData[indexPath.row][0]
        var urlString = "https://openweathermap.org/img/w/"  + hourData[indexPath.row][1] + ".png"
        if let url = NSURL(string: urlString) {
            if let data = NSData(contentsOf: url as URL) {
                cell.weatherImage.image = UIImage(data: data as Data)
            }
        }

        cell.avgTemp.text = hourData[indexPath.row][2]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
    // Fetch 4 days data starting from timezone's tmorws afternoon
    func explore4days(){
        let days =  Cities.jsonHourly
        //Fetch timezone's tmrw Noon date with and without time
        let tmrwnoonDate = Cities.getTmrwNoonToUTCDate(ViewController.passedValue)
        print("Fetched tmrw noon DAte of timezone in UTC: \(tmrwnoonDate)")
        let tmrwnoonDatewithoutTime = Cities.DateWithoutTime(tmrwnoonDate)
        print("Fetched tmrw noon Date alone of timezone in UTC: \(tmrwnoonDate)")
        
        //Fetch HR string from above date and time variable
        let timezoneUTCNoonHR = Cities.StringtoHR(Cities.DatetoString(tmrwnoonDate))
        print("Fetched tmrw noon HR:  \(timezoneUTCNoonHR)")
        let hrMatchInt = Cities.getClosest3MultipleHR(String(timezoneUTCNoonHR))
        print("Fetched closst Match to 3 multiple:  \(hrMatchInt)")
        var dayPrev = Cities.getTmrwTimezoneDAY(ViewController.passedValue)
        print("Starting Json loop")
        let jsonList = days!["list"]
        var count = 4 //no of days
        for anItem in jsonList{
            let str = anItem.1["dt_txt"].string
            let jsonStringToDate = Cities.StringtoDate(str!)
            let jsonStringDatehr = Cities.StringtoHR(str!)
            
            if (jsonStringToDate >= tmrwnoonDatewithoutTime && jsonStringDatehr == hrMatchInt && count > 0){
                print(anItem.1["dt_txt"])
                var storeDataList: [String] = [];
                let jsonStringToDateTime = Cities.StringtoDateTime(str!)
                print("My string to date of json date \(jsonStringToDateTime)")
                
                let weatherdetail = anItem.1["weather"][0]["icon"].string!
                print("Weather icon : " + weatherdetail)
                
                let tempp = anItem.1["main"].dictionary
                let min = String(describing: tempp!["temp_min"]!)
                print("Min : " + min)
                
                let max = String(describing: tempp!["temp_max"]!)
                print("Max : " + max)
                
                let day = dayPrev
                print("day :" + day)
                
                storeDataList.append(day)
                storeDataList.append(weatherdetail)
                if CityList.temp {
                    storeDataList.append(Cities.getF(max))
                    storeDataList.append(Cities.getF(min))
                }else{
                    storeDataList.append(max)
                    storeDataList.append(min)
                }
                
                fourdayData.append(storeDataList)
                dayPrev = Cities.dyaskey[dayPrev]!
                count -= 1
            }
        }
        print(fourdayData)
    }
    
    func explorehourly(){
        let hourly =  Cities.jsonHourly
        let localtoUTCNow = Cities.getLocaltoUTCNow()
        print("CURRENT UTC : \(localtoUTCNow)")
        let localtoUTCNowDate = Cities.StringtoDateTime(localtoUTCNow)
        print("CURRENT UTC Date : \(localtoUTCNowDate)")
        var localHR = Cities.LocalHR(ViewController.passedValue)
        print("LOCAL HR NOW: \(localHR)")
        let currentUTCHR = Cities.StringtoHR(localtoUTCNow)
        print("CURRENT UTC HR: \(currentUTCHR)")
        let hrMartch = Cities.getClosest3MultipleHR(String(currentUTCHR))
        print("Starting Json loop")
        let jsonList = hourly!["list"]
        var count = 8 //no of for 24 hrs : 9-1: 8

        let strfirst = jsonList[0]["dt_txt"].string
        let jsonStringDatehr = Cities.StringtoHR(strfirst!)
        if hrMartch < jsonStringDatehr{
            print("Im in first if")
            var eachHourData : [String] = []
            eachHourData.append("NOW")
            let icon = Cities.jsonToday!["weather"][0]["icon"].string!
            eachHourData.append(icon)
            if CityList.temp {
                let temp = Cities.getF(Cities.jsonToday!["main"]["temp"].stringValue)
                eachHourData.append(temp)
            }else{
                let temp = Cities.jsonToday!["main"]["temp"].stringValue
                eachHourData.append(temp)
            }
            hourData.append(eachHourData)
            count -= 1
        }
        for anItem in jsonList {
            if count > 0{
                let str = anItem.1["dt_txt"].string
                let jsonStringDatehr = Cities.StringtoHR(str!)
                var eachHourData : [String] = []
                if count == 8{
                        print("Im in second if == 9")
                        eachHourData.append("NOW")
                        let weatherdetail = anItem.1["weather"][0]["icon"].string!
                        eachHourData.append(weatherdetail)
                    
                        let tempp = anItem.1["main"].dictionary
                        let tempAvg = String(describing: tempp!["temp"]!)
                        if CityList.temp {
                            eachHourData.append(Cities.getF(tempAvg))
                        }else{
                            eachHourData.append(tempAvg)
                        }
                        hourData.append(eachHourData)
                        count -= 1
                }
                else {
                    print("Im in generic loop")
                    localHR = localHR + 3
                    if localHR >= 24 {
                        localHR = 0
                    }
                    var hourStr = ""
                    if localHR < 12 {hourStr = String(localHR) + " AM"}
                    else if localHR > 12 {hourStr = String(localHR - 12) + " PM"}
                    else {hourStr = "Noon"}
                    
                    eachHourData.append(hourStr)
                    let weatherdetail = anItem.1["weather"][0]["icon"].string!
                    eachHourData.append(weatherdetail)
                    
                    let tempp = anItem.1["main"].dictionary
                    let tempAvg = String(describing: tempp!["temp"]!)
                    if CityList.temp {
                        eachHourData.append(Cities.getF(tempAvg))
                    }else{
                        eachHourData.append(tempAvg)
                    }
                    hourData.append(eachHourData)
                    count -= 1
                }
            }
        }
        print(hourData)
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



