//
//  cityList.swift
//  WeatherApp
//
//  Created by Vimmi Swami on 11/24/17.
//  Copyright © 2017 Vimmi Swami. All rights reserved.
//

import UIKit
import GooglePlaces

class CityList: UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    //var  cities = ["San Jose","London","Mumbai"]
    var newCity: String = ""
    static var  temp: Bool = false // False = C, True= F
    var citySelected : String = ""
    var cityWeather : String = ""
    var cityMax : String = ""
    var cityMin : String = ""
    //static var segmentControll : UISegmentedControl? = nil
    
    @IBOutlet weak var segmentControll: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func segmentedTemp(_ sender: UISegmentedControl) {
        //CityList.segmentControll = sender
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Sustain segmented stemperature selections.
        if CityList.temp{
            segmentControll.selectedSegmentIndex = 1
        }else{
            segmentControll.selectedSegmentIndex = 0
        }
        segmentControll.sendActions(for: UIControlEvents.valueChanged)
        // Do any additional setup after loading the view.
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath) 
        cell.textLabel!.text = Cities.cities[indexPath.row]
        return cell
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source

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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
        // Get Cell Label
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        
        citySelected = currentCell.textLabel!.text!
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
    
    @IBAction func addCityGooglePlaces(_ sender: UIButton) {
        
        NSLog("Im clicked")
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        
    }

    class  func toastView(messsage : String, view: UIView ){
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 150, y: view.frame.size.height-100, width: 300,  height : 35))
        toastLabel.backgroundColor = UIColor.white
        toastLabel.textColor = UIColor.black
        toastLabel.textAlignment = NSTextAlignment.center;
        view.addSubview(toastLabel)
        toastLabel.text = messsage
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        UIView.animate(withDuration: 4.0, delay: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: {
            toastLabel.alpha = 0.0
            
        })
    }
}

extension CityList: GMSAutocompleteViewControllerDelegate {

    
    // Handle the user's selection.
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
            let city = Cities.cityObjectsMap[place.name]
            print("Selected city object : \(String(describing: city))")
            Cities.getToday((city?.lat)!,(city?.lon)!)
            while (Cities.jsonToday == nil){
                //do nothing
            }
            Cities.getHourly((city?.lat)!,(city?.lon)!)
            while (Cities.jsonHourly == nil){
                //do nothing
            }
            // Load data for next city going to be viewed
            dismiss(animated: true, completion: nil)
            tableView.reloadData()
        }else{
            CityList.toastView(messsage:"City already exist", view: self.view)
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


