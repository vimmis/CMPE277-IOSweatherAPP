//
//  cityList.swift
//  WeatherApp
//
//  Created by Vimmi Swami on 11/24/17.
//  Copyright © 2017 Vimmi Swami. All rights reserved.
//

import UIKit
import GooglePlaces
// This class takes care of managing list of cities for viewing, adding, deleting and tapping.
class CityList: UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    var newCity: String = ""
    static var  temp: Bool = false // False = C, True= F
    var citySelected : String = ""
    var cityWeather : String = ""
    var cityMax : String = ""
    var cityMin : String = ""

    static var alertmsg : String? = nil
    @IBOutlet weak var segmentControll: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    //Based on user C/F preference, we store it for other view to accordignly manupulate temp
    @IBAction func segmentedTemp(_ sender: UISegmentedControl) {

        let selectedPreference  = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        if(selectedPreference == "C"){
            CityList.temp = false
            let subViewOfSegment: UIView = segmentControll.subviews[0] as UIView
            subViewOfSegment.tintColor = UIColor.blue

        }else{
            CityList.temp = true
            let subViewOfSegment: UIView = segmentControll.subviews[1] as UIView
            subViewOfSegment.tintColor = UIColor.blue

        }
        // post temp changes, temp calculations may require and end reload data
        tableView.reloadData()
    }
    
    // To maintain  user preference on each view load
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print("inside viewdownload")
        
        // Sustain segmented stemperature selections.
        if CityList.temp{
            segmentControll.selectedSegmentIndex = 1
        }else{
            segmentControll.selectedSegmentIndex = 0
        }
        segmentControll.sendActions(for: UIControlEvents.valueChanged)

    }
    // Show pop up message incase of any error caught
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if CityList.alertmsg != nil{
            let alert = UIAlertController(title: "ERROR", message: CityList.alertmsg, preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            let time = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: time){
                alert.dismiss(animated: true, completion: nil)
            }
            CityList.alertmsg = nil;
        }
 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return   Cities.cities.count
    }
    
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    // Manages data for each cell of table view with current time, city name and temp
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        let CityInfo = Cities.cities[indexPath.row]
        let cityobject = Cities.cityObjectsMap[CityInfo]
        Cities.jsonToday = nil
        Cities.getToday((cityobject?.lat)!,(cityobject?.lon)!)
        while (Cities.jsonToday == nil){
            //do nothing
        }
        let jsonWeatherToday = Cities.jsonToday
        var weather = ""
        if CityList.temp {
            weather = Cities.getF(jsonWeatherToday!["main"]["temp"].stringValue)
        }else{
            weather = String(format: "%.1f", jsonWeatherToday!["main"]["temp"].double!)
        }
        let currentTime = Cities.CityCurrentTime(CityInfo)
        cell.textLabel!.numberOfLines = 0
        cell.textLabel!.text = currentTime + "\n" + CityInfo + "\n" + "AvgTemp: " + weather

        return cell
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source from corresponding stored objects

            let place = Cities.cities[indexPath.row]
            Cities.cities.remove(at: indexPath.row)
            Cities.cityObjectsMap.removeValue(forKey: place)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return false
    }
    
    // Manages selection of city on tap on it and load its corresponding weather data before it shows in next view
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
        // Get Cell Label
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        
        citySelected = Cities.cities[indexPath.row]
        NSLog("City Selected")
        NSLog(citySelected)
        let cityobject = Cities.cityObjectsMap[citySelected]
        print("Selected city object :" + cityobject.debugDescription)
        Cities.getToday((cityobject?.lat)!,(cityobject?.lon)!)
        while (Cities.jsonToday == nil){
            //do nothing
        }
        
        Cities.getHourly((cityobject?.lat)!,(cityobject?.lon)!)
        while (Cities.jsonHourly == nil){
            //do nothing
        }
        super.performSegue(withIdentifier: "ViewControllerSeague", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         NSLog("Inside prepareseagyue")
        
        if (segue.identifier == "ViewControllerSeague") {
            ViewController.passedValue = citySelected
        }
    }
    
    // For launching google place API view
    @IBAction func addCityGooglePlaces(_ sender: UIButton) {
        
        NSLog("Im clicked")
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        
    }

}
// Delegate to handle google places API related functionalities
extension CityList: GMSAutocompleteViewControllerDelegate {

    
    // Handle the user's selection, validate and respond if valid city and valid data from weather API recieved
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print(place.name)
        if !Cities.cities.contains(place.name){
            Cities.cities.append(place.name)
            print (Cities.cities.joined(separator:","))
            let lat = place.coordinate.latitude
            let lon = place.coordinate.longitude
            print("lat lon",lat,lon)
            if Cities.cityObjectsMap.index(forKey: place.name) == nil
            {
                let cityObject = City (placeName : place.name, lat: String(format:"%f", lat), lon : String(format:"%f", lon), countryISO: "", timezone: "")
                Cities.cityObjectsMap[place.name] = cityObject
            }
            
            Cities.getTimezone(String(format:"%f", lat),String(format:"%f", lon), place.name)
            sleep(1)
            if CityList.alertmsg != nil{
                print("Timezone exception caught")
                print(Cities.cities)
                Cities.cities.removeLast()
                print(Cities.cities)
                dismiss(animated: true, completion: nil)
                tableView.reloadData()
            }
            let city = Cities.cityObjectsMap[place.name]
            print("Selected city object : \(String(describing: city))")
            Cities.getToday((city?.lat)!,(city?.lon)!)
            while (Cities.jsonToday == nil && CityList.alertmsg == nil){
                //do nothing
            }
            if CityList.alertmsg != nil{
                print("Weather API Today exception caught")
                print(Cities.cities)
                Cities.cities.removeLast()
                print(Cities.cities)
                dismiss(animated: true, completion: nil)
                tableView.reloadData()
            }
            Cities.getHourly((city?.lat)!,(city?.lon)!)
            while (Cities.jsonHourly == nil && CityList.alertmsg == nil){
                //do nothing
            }
            // Load data for next city going to be viewed
            dismiss(animated: true, completion: nil)
            tableView.reloadData()
        }else{

            print ("Duplicate city")
            CityList.alertmsg = "City already exist, not adding"
            dismiss(animated: true, completion: nil)
            tableView.reloadData()
        }
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}


