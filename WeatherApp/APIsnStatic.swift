//
//  APIsnStatic.swift
//  WeatherApp
//
//  Created by Vimmi Swami on 12/15/17.
//  Copyright © 2017 Vimmi Swami. All rights reserved.
//

import Foundation


class Cities {
    static let dyaskey = ["Monday": "Tuesday", "Tuesday": "Wednesday", "Wednesday": "Thursday","Thursday": "Friday", "Friday":"Saturday", "Saturday":"Sunday","Sunday":"Monday"]
    static var cities:[String] = []
    static var cityObjectsMap: [String : City] = [:]
    static var jsonToday :JSON? = nil
    static var jsonHourly :JSON? = nil
    static let weatherAPIToday = "http://api.openweathermap.org/data/2.5/weather?appid=4d24bc6be2371dad87666ac843e640ad&units=metric"
    static let weatherAPIHourly = "http://api.openweathermap.org/data/2.5/forecast?appid=4d24bc6be2371dad87666ac843e640ad&units=metric"
    static let timeZoneAPI = "http://api.timezonedb.com/v2/get-time-zone?key=MRKZ336VAE4Y&format=json&by=position"
    
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
    
    /*static func getLocalNow(_ placename : String) -> String {
        print("Inside getLocalNow")
        var city :City = Cities.cityObjectsMap[placename]!
        while (city.timezone == ""){
            city = Cities.cityObjectsMap[placename]!
        }
        
        let dateFormatter = DateFormatter()
            
        dateFormatter.timeZone = NSTimeZone(name: city.timezone)! as TimeZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let str = dateFormatter.string(from: NSDate() as Date)
        print(str)
        return str
    }*/
    
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
    
    static func getTmrwNoonToUTCDate(_ placename : String) -> Date {
            //print("Inside get tmrw noon in utc")
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
            //print("timezone's tomorow date:" + str)
            //print("UTC time for tomorow timezone Noon: \(tomorrow)")
            /*dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
            let timezoneTmrNoonToUtc = dateFormatter.string(from: tomorrow! as Date)
            print("final timezone's tmrw noon in UTC: " + timezoneTmrNoonToUtc)*/
            return tomorrow!
    }
    //To convert a UTC Date to Date without time
    static func DateWithoutTime(_ datewithT : Date) -> Date {
        //print("Inside DateWithoutTime")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        let str = dateFormatter.string(from: datewithT as Date)
        var dateFromString : Date = dateFormatter.date(from: str)!
        //print ("Date to Date without time : \(dateFromString)")
        return dateFromString
    }
    //To convert JSON String date to only UTC Date without time
    static func StringtoDate(_ strDate : String) -> Date {
        //print("Inside StringtoDate")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        var dateFromString : Date = dateFormatter.date(from: strDate)! as Date
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let str = dateFormatter.string(from: dateFromString as Date)
        let dateFromStringfinal : Date = dateFormatter.date(from: str)!
        //print ("Str to Date without time : \(dateFromStringfinal)")
        return dateFromStringfinal
    }
    
    //To convert JSON String date to only UTC Date with time
    static func StringtoDateTime(_ strDate : String) -> Date {
        //print("Inside StringtoDate")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        var dateFromString : Date = dateFormatter.date(from: strDate)! as Date
        return dateFromString
    }
    
    static func StringtoHR(_ strDate : String) -> Int {
        //print("Inside StringtoHR")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        let dateFromString : NSDate = dateFormatter.date(from: strDate)! as NSDate
        dateFormatter.dateFormat = "HH"
        let strHR  = dateFormatter.string(from: dateFromString as Date)
        //print ("HR from string :" + strHR)
        return Int(strHR)!
    }
    
    static func DatetoString(_ date : Date) -> String {
        //print("Inside DatetoString")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        let dateWithTime  = dateFormatter.string(from: date as Date)
        //print ("Date to String: \(dateWithTime)")
        return dateWithTime
    }
    
    static func getTmrwTimezoneDAY( _ placename : String) -> String {
        var city :City = Cities.cityObjectsMap[placename]!
        /*let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let tempstr = Cities.DatetoString(utcDate)
        dateFormatter.timeZone = NSTimeZone(name: city.timezone)! as TimeZone

        let dt = dateFormatter.date(from: tempstr)
        dateFormatter.dateFormat = "EEEE"
        
        print(dateFormatter.string(from: dt!))
        return dateFormatter.string(from: dt!)*/
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: city.timezone)! as TimeZone
        dateFormatter.dateFormat = "EEEE"
        let LocalDay = dateFormatter.string(from: NSDate() as Date)
        print("LOCAL Day : " + LocalDay)
        let tomDay = Cities.dyaskey[LocalDay]
        print("LOCAL TMRW Day : " + tomDay!)
        return tomDay!
    }
    
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
    
}



