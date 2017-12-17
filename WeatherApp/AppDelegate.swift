//
//  AppDelegate.swift
//  WeatherApp
//
//  Created by Vimmi Swami on 11/24/17.
//  Copyright © 2017 Vimmi Swami. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GMSPlacesClient.provideAPIKey("AIzaSyBoDQtDBiYoOzFI-S1aowHU89xNFibj_bc")
        GMSServices.provideAPIKey("AIzaSyBoDQtDBiYoOzFI-S1aowHU89xNFibj_bc")
        print("In delegate")
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        print("path" + path)
        let url = URL(fileURLWithPath: path)
        
        let filePath = url.appendingPathComponent("cities.txt").path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            print("FILE AVAILABLE")
            let file = "cities.txt" //this is the file. we will write to and read from it
            
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                var citiesList : [String] = []
                let fileURL = dir.appendingPathComponent(file)
                do {
                    let citiesString = try String(contentsOf: fileURL, encoding: .utf8)
                    if citiesString != ""
                    {
                        citiesList = citiesString.components(separatedBy: ",")
                        for c in citiesList{
                            print(c)
                            let temp = c.components(separatedBy: ":")
                            Cities.cities.append(temp[0])
                            let tempobject = City(placeName : temp[0] , lat : temp[1] , lon : temp[2], countryISO : "" , timezone : "")
                            Cities.cityObjectsMap[temp[0]] = tempobject
                            Cities.getTimezone(temp[1],temp[2], temp[0])
                            sleep(1)
                            /*while Cities.cityObjectsMap[temp[0]]?.countryISO == ""{
                                //do nothing- allow this seesion to complete before calling other
                            }*/
                        }
                        print(Cities.cities)
                        print(Cities.cityObjectsMap)
                        print("FILE READ")
                    }
                }
                catch {print("Error in cities list reading")}
            }
        } else {
            print("FILE NOT AVAILABLE, creating")
            fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
            
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        print("INSIDE BACKGROUND path" + path)
        let url = URL(fileURLWithPath: path)
        
        let filePath = url.appendingPathComponent("cities.txt").path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            do {
                try fileManager.removeItem(atPath: filePath)
            }
            catch let error as NSError {
                print("Ooops! Something went wrong in deleting: \(error)")
            }
        }
        if !fileManager.fileExists(atPath: filePath) {
            print("Should recreate everytime")
            fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
        }
            print("FILE AVAILABLE")
            let file = "cities.txt" //this is the file. we will write to and read from it
            
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = dir.appendingPathComponent(file)
                var citiesStore : [String] = []
                for c in Cities.cities{
                    citiesStore.append(c + ":" + (Cities.cityObjectsMap[c]?.lat)! + ":" + (Cities.cityObjectsMap[c]?.lon)!)
                }
                
                do {
                    let stringRepresentation = citiesStore.joined(separator:",")
                    print("STORING" + stringRepresentation)
                    try stringRepresentation.write(to: fileURL, atomically: false, encoding: .utf8)
                }
                catch {print("Error in cities list writing")}
            }

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

