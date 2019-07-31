//
//  WeatherAPI.swift
//  Virtual Tourist
//
//  Created by A.M.W on 7/29/19.
//  Copyright © 2019 AW. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreData
import MapKit

struct WeatherAPI  {
    static let WEATHER_URL = "api.openweathermap.org/data/2.5/weather"
    static let api_key = "92ea2dbef46f1d806b753f29da07c642"
    
    struct parmet {
    
        static let latitude = "&lat="
        static let longitude = "&lon="
        static let apiKey = "?api_key="
    }
    
    
    enum EndPoint {
        
        case getWeatherDegree(latitude: Double, longitude: Double)
        

        var stringValue: String {
            switch self {
            case let .getWeatherDegree(latitude, longitude) :
                return "\(WeatherAPI.WEATHER_URL)\(parmet.apiKey)\(WeatherAPI.APP_ID)&method=\(parmet.latitude)\(latitude)\(parmet.longitude)\(longitude))"
                
            }
            
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
        
    }
    
}
