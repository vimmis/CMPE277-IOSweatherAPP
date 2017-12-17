//
//  APIsnStatic.swift
//  WeatherApp
//
//  Created by Vimmi Swami on 12/15/17.
//  Copyright © 2017 Vimmi Swami. All rights reserved.
//

import Foundation


class Cities {
    
    static var cities:[String] = []
    static var cityObjectsMap: [String : City] = [:]
    static var jsonToday :JSON? = nil
    static var jsonHourly :JSON? = nil
    static let weatherAPIToday = "http://api.openweathermap.org/data/2.5/weather?appid=4d24bc6be2371dad87666ac843e640ad&units=metric"
    static let weatherAPIHourly = "http://api.openweathermap.org/data/2.5/forecast?appid=4d24bc6be2371dad87666ac843e640ad&units=metric"
    static let timeZoneAPI = "http://api.timezonedb.com/v2/get-time-zone?key=MRKZ336VAE4Y&format=json&by=position&"
    
    static func getToday(_ lat:String,_ long:String){
        let urlString = weatherAPIToday + "&lat=" + lat + "&lon=" + long
        print("Calling today api:" + urlString)
        
        let url = URL(string:urlString)
        let session = URLSession.shared
        let task = session.dataTask(with: url!) { (data : Data?, response : URLResponse?, err : Error?) in
            if err != nil{
                print("error")
                print(err.debugDescription)
                return
            }
            
            do{
                jsonToday = try JSON(data:data!)
            }catch{
                print("ERROR in JSON")
            }
            
        }
        task.resume()
        while(jsonToday == nil){
            //do nothing
        }
    }
    
    static func getHourly(_ lat:String,_ long:String){
        let urlString = weatherAPIHourly + "&lat=" + lat + "&lon=" + long
        print("Calling hourly api:" + urlString)
        jsonHourly = nil
        let url = URL(string:urlString)
        let session = URLSession.shared
        let task = session.dataTask(with: url!) { (data : Data?, response : URLResponse?, err : Error?) in
            if err != nil{
                print("error")
                print(err.debugDescription)
                return
            }
            
            do{
                jsonHourly = try JSON(data:data!)
            }catch{
                print("ERROR in JSON")
            }
            
        }
        task.resume()
        while(jsonHourly == nil){
            //do nothing
        }
        
    }
    
    static func getTimezone(_ lat:String,_ long:String, _ placename :String){
        
        let urlString = timeZoneAPI + "&lat=" + lat + "&lng=" + long
        print("Calling time zone:" + urlString)
        let url = URL(string:urlString)
        let session = URLSession.shared
        let task = session.dataTask(with: url!) { (data : Data?, response : URLResponse?, err : Error?) in
            if err != nil{
                print("error")
                print(err.debugDescription)
                return
            }
            var json :JSON? = nil
            do{
                json = try JSON(data:data!)
            }catch{
                print("ERROR in JSON")
                return
            }
            if json!["status"] == "OK"{
                if Cities.cityObjectsMap.index(forKey: placename) != nil
                {
                    var city :City = Cities.cityObjectsMap[placename]!
                    city.countryISO = json!["countryCode"].string!
                    city.timezone = json!["zoneName"].string!
                    Cities.cityObjectsMap[placename] = city
                    print("Timezone city object:" + String(describing: city))
                }
                else{
                    print("CityObject not found inside timezone API")
                }
            }else{
                print("ERROR IN STATUS CODE OF TIMEZONE RESPONSE")
            }
        }
        task.resume()
        while(Cities.cityObjectsMap[placename]?.countryISO == ""){
            //do nothing
        }
    }
    
    static func getDay(_ placename : String) -> String {
        print("Inside get day")
        if Cities.cityObjectsMap.index(forKey: placename) != nil
        {
            var city :City = Cities.cityObjectsMap[placename]!
            while (city.timezone == ""){
                city = Cities.cityObjectsMap[placename]!
            }
            
            let dateFormatter = DateFormatter()
            
            dateFormatter.timeZone = NSTimeZone(name: city.timezone)! as TimeZone
            dateFormatter.dateFormat = "EEEE MMM d"
            let str = dateFormatter.string(from: NSDate() as Date)
            print(str)
            return str
        }
        else{
            print("CityObject not found inside timezone API")
            return ""
        }
        
    }
    
    static func getF(_ temp : String) -> String {
        print("Inside get Fahrenhiet")
        if var tempd = Double(temp) {
            print("The Double is:  \(tempd)")
            tempd = ( tempd * 1.8 ) + 32
            return String(tempd)
        } else {
            print("Not a valid Double")
            return ""
        }
        
    }
    
    static func getTmrwNoonToUTC(_ placename : String) -> String {
        print("Inside get tmrw noon in utc")
        if Cities.cityObjectsMap.index(forKey: placename) != nil
        {
            var city :City = Cities.cityObjectsMap[placename]!
            while (city.timezone == ""){
                city = Cities.cityObjectsMap[placename]!
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.timeZone = NSTimeZone(name: city.timezone)! as TimeZone
            //To get timezone's next day Noon datetimestamp
            var calendar = NSCalendar.current
            calendar.timeZone = TimeZone(identifier: city.timezone)!
            let nowNoon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: NSDate() as Date)!
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: nowNoon as Date)
            let str = dateFormatter.string(from: tomorrow! as Date)
            print("timezone's tomorow date:" + str)
            print("UTC time for tomorow timezone Noon: \(tomorrow)")
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
            let timezoneTmrNoonToUtc = dateFormatter.string(from: tomorrow! as Date)
            print("final timezone's tmrw noon in UTC: " + timezoneTmrNoonToUtc)
            return timezoneTmrNoonToUtc

        }
        else{
            print("CityObject not found inside timezone API")
            return ""
        }
        
    }
}



