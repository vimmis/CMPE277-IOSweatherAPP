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
    
    var  cities = ["San Jose","London","Mumbai"]
    var newCity: String = ""
    var temp: Bool = false // False = C, True= F
    var citySelected : String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func segmentedTemp(_ sender: UISegmentedControl) {
        
        let selectedPreference  = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        if(selectedPreference == "C"){
           temp = false
        }else{
            temp = true
        }
        // post temp changes, temp calculations may require and end reload data
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        return   cities.count
    }
    
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath) 
        cell.textLabel!.text = cities[indexPath.row]
        return cell
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            NSLog("Deleting at :")
            cities.remove(at: indexPath.row)
            NSLog("Post deletion of city")
            NSLog(cities.description)
            tableView.deleteRows(at: [indexPath], with: .fade)
            //cities.remove(at: indexPath.row)
            
            //self.tableView.reloadData()
        } //else if editingStyle == .insert {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        // }
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
        super.performSegue(withIdentifier: "ViewControllerSeague", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         NSLog("Inside prepareseagyue")
        
        if (segue.identifier == "ViewControllerSeague") {
             NSLog("Inside prepareseagyue2")
            // initialize new view controller and cast it as your view controller
            let viewController = segue.destination as! ViewController
            // your new view controller should have property that will store passed value
            NSLog("Inside prepareseagyue3")
            
            viewController.passedValue = citySelected
            NSLog("after prepareseagyue")
            NSLog(viewController.passedValue)
        }
    }
    
    @IBAction func addCityGooglePlaces(_ sender: UIButton) {
        
        NSLog("Im clicked")
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CityList: GMSAutocompleteViewControllerDelegate {

    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print(place.name)
        print(place.formattedAddress)
        print(place.attributions)
        var lat = place.coordinate.latitude
        var lon = place.coordinate.longitude
        print("lat lon",lat,lon)

        dismiss(animated: true, completion: nil)
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
