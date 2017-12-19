//
//  APIsnStatic.swift
//  WeatherApp
//
//  Created by Vimmi Swami on 12/15/17.
//  Copyright © 2017 Vimmi Swami. All rights reserved.
//

import Foundation

// For storing independent functionalities and data objects accessible for complete application(static)
class Cities {
    static let dyaskey = ["Monday": "Tuesday", "Tuesday": "Wednesday", "Wednesday": "Thursday","Thursday": "Friday", "Friday":"Saturday", "Saturday":"Sunday","Sunday":"Monday"]
    static var cities:[String] = []
    static var cityObjectsMap: [String : City] = [:]
    static var jsonToday :JSON? = nil
    static var jsonHourly :JSON? = nil
    static let weatherAPIToday = "http://api.openweathermap.org/data/2.5/weather?appid=4d24bc6be2371dad87666ac843e640ad&units=metric"
    static let weatherAPIHourly = "http://api.openweathermap.org/data/2.5/forecast?appid=4d24bc6be2371dad87666ac843e640ad&units=metric"
    static let timeZoneAPI = "http://api.timezonedb.com/v2/get-time-zone?key=MRKZ336VAE4Y&format=json&by=position"
    
    // Fetches Today weather for a city
    static func getToday(_ lat:String,_ long:String){
        let urlString = weatherAPIToday + "&lat=" + lat + "&lon=" + long
        print("Calling today api:" + urlString)
        
        let url = URL(string:urlString)
        let session = URLSession.shared
        let task = session.dataTask(with: url!) { (data : Data?, response : URLResponse?, err : Error?) in
            if err != nil{
                print("error")
                print(err.debugDescription)
                CityList.alertmsg = "Weather API Connection Timeout, try again later"
                return
            }
            var jsonTodaytemp: JSON? = nil
            do{
                jsonTodaytemp = try JSON(data:data!)
            }catch{
                print("ERROR in JSON")
            }
            print(jsonTodaytemp!["cod"] )
            if jsonTodaytemp!["cod"] == 200{
                jsonToday = jsonTodaytemp
            }else{
                CityList.alertmsg = "Weather API doesnt support this place daily, deleting"
            }
        }
        task.resume()
        while(jsonToday == nil && CityList.alertmsg == nil){
            //do nothing
        }
    }
    // Fetches 5days 3 hours weather for a city
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
                CityList.alertmsg = "Weather API Connection Timeout, try again later"
                return
            }
            var jsonHourlytemp: JSON? = nil
            do{
                jsonHourlytemp = try JSON(data:data!)
            }catch{
                print("ERROR in JSON")
            }
            if jsonHourlytemp!["cod"] == "200"{
                jsonHourly = jsonHourlytemp
            }else{
                CityList.alertmsg = "Weather API doesnt support this place hourly, deleting"
            }
            
        }
        task.resume()
        while(jsonHourly == nil && CityList.alertmsg == nil){
            //do nothing
        }
        
    }
    
    // Fetches Timezone related data for a city
    static func getTimezone(_ lat:String,_ long:String, _ placename :String){
        
        let urlString = timeZoneAPI + "&lat=" + lat + "&lng=" + long
        print("Calling time zone:" + urlString)
        let url = URL(string:urlString)
        let session = URLSession.shared
        let task = session.dataTask(with: url!) { (data : Data?, response : URLResponse?, err : Error?) in
            if err != nil{
                print("error")
                print(err.debugDescription)
                CityList.alertmsg = "Weather API Connection Timeout, try again later"
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
                CityList.alertmsg = "Error in fetching timezone, try other place"
                return
            }
        }
        task.resume()
        while(Cities.cityObjectsMap[placename]?.countryISO == "" && CityList.alertmsg == nil){
            //do nothing
        }
    }
    
    // Fetches Today Day for a city
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
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let test = dateFormatter.string(from: NSDate() as Date)
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
    
    // Fetches current utc date and time
    static func getLocaltoUTCNow() -> String {
        //print("Inside getLocaltoUTCNow")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let tempstr = Cities.DatetoString(NSDate() as Date)
        let dtnowinUTC = dateFormatter.date(from: tempstr)
        print("nowinUTC : \(dtnowinUTC)")
        let nowinUTCString = Cities.DatetoString(dtnowinUTC!)
        return nowinUTCString
    }
    
    // Fetches Fahrenheit equivalent for a given C temp
    static func getF(_ temp : String) -> String {
        print("Inside get Fahrenhiet")
        if var tempd = Double(temp) {
            print("The Double is:  \(tempd)")
            tempd = ( tempd * 1.8 ) + 32
            return String(format: "%.1f", tempd)
        } else {
            print("Not a valid Double")
            return ""
        }
        
    }
    
    // Fetches closest Hour match of utc to 3 multiple HR match for Weather json data
    static func getClosest3MultipleHR(_ temp : String) -> Int {
        print("Inside get 3multiple")
        
        var closest = 99
        var match = 0
        if let tempd = Int(temp) {
            print("The Int is:  \(tempd)")
            let possibleValues = [0,3,6,9,12,15,18,21,24]
            for x in possibleValues{
                if abs(tempd - x) < closest {
                    closest = abs(tempd - x)
                    match = x
                }
            }
            print("Closest value chose : \(match)")
            
        }
        if match == 24 {
            match = 0
        }
        return match
    }
    
    // Fetches place's tomorrow noon equivalent in UTC
    static func getTmrwNoonToUTCDate(_ placename : String) -> Date {
      
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
            return tomorrow!
    }
    
    //To convert a UTC Date to Date without time
    static func DateWithoutTime(_ datewithT : Date) -> Date {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        let str = dateFormatter.string(from: datewithT as Date)
        var dateFromString : Date = dateFormatter.date(from: str)!
        return dateFromString
    }
    
    //To convert JSON String date to only UTC Date without time
    static func StringtoDate(_ strDate : String) -> Date {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        var dateFromString : Date = dateFormatter.date(from: strDate)! as Date
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let str = dateFormatter.string(from: dateFromString as Date)
        let dateFromStringfinal : Date = dateFormatter.date(from: str)!
        return dateFromStringfinal
    }
    
    //To convert JSON String date to only UTC Date with time
    static func StringtoDateTime(_ strDate : String) -> Date {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        var dateFromString : Date = dateFormatter.date(from: strDate)! as Date
        return dateFromString
    }
    
    //To fecth hour portion from a string of date
    static func StringtoHR(_ strDate : String) -> Int {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        let dateFromString : NSDate = dateFormatter.date(from: strDate)! as NSDate
        dateFormatter.dateFormat = "HH"
        let strHR  = dateFormatter.string(from: dateFromString as Date)
        //print ("HR from string :" + strHR)
        return Int(strHR)!
    }
    
    //To convert a UTC date to String
    static func DatetoString(_ date : Date) -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        let dateWithTime  = dateFormatter.string(from: date as Date)
        return dateWithTime
    }
    
    //To fetch whats tomorrow Day for a place
    static func getTmrwTimezoneDAY( _ placename : String) -> String {
        var city :City = Cities.cityObjectsMap[placename]!

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: city.timezone)! as TimeZone
        dateFormatter.dateFormat = "EEEE"
        let LocalDay = dateFormatter.string(from: NSDate() as Date)
        print("LOCAL Day : " + LocalDay)
        let tomDay = Cities.dyaskey[LocalDay]
        print("LOCAL TMRW Day : " + tomDay!)
        return tomDay!
    }
    
    //To fetch place current time's hour value
    static func LocalHR(_ placename : String) -> Int {
        var city :City = Cities.cityObjectsMap[placename]!
        while (city.timezone == ""){
            city = Cities.cityObjectsMap[placename]!
        }
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.timeZone = NSTimeZone(name: city.timezone)! as TimeZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let placedatetime = dateFormatter.string(from: NSDate() as Date)
        print("LOCAL TIME NOW : " + placedatetime)
        let timeList = placedatetime.components(separatedBy: " ")
        let hourList = timeList[1].components(separatedBy: ":")
        return Int(hourList[0])!
    }
    
    //To fetch place current time (HH:ss AM/PM)
    static func CityCurrentTime(_ placename : String) -> String {
        var city :City = Cities.cityObjectsMap[placename]!
        while (city.timezone == ""){
            city = Cities.cityObjectsMap[placename]!
        }
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.timeZone = NSTimeZone(name: city.timezone)! as TimeZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let placedatetime = dateFormatter.string(from: NSDate() as Date)
        let start = placedatetime.index(placedatetime.startIndex, offsetBy: 11)
        let end = placedatetime.index(placedatetime.endIndex, offsetBy: -3)
        let range = start..<end
        
        let substr = placedatetime[range]
        var time = String(substr)
        let hourList = time.components(separatedBy: ":")
        if Int(hourList[0])! < 12{
            time = time + " AM"
        }else{
            time = time + " PM"
        }
        return time
    }

    
}



