//
//  WeatherGetter.swift
//  Virtual Tourist
//
//  Created by  on 28/11/1440 AH.
//  Copyright © 1440 AW. All rights reserved.
//

import Foundation


struct API {
    
    static let APIKey = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    static let BaseURL = URL(string: "https://api.darksky.net/forecast/")!
    
    static var AuthenticatedBaseURL: URL {
        return BaseURL.appendingPathComponent(APIKey)
    }
    
}


struct Defaults {
    
    static let Latitude: Double = 37.8267
    static let Longitude: Double = -122.423
    
}


enum DataManagerError: Error {
    
    case Unknown
    case FailedRequest
    case InvalidResponse
    
}

final class DataManager {
    
    typealias WeatherDataCompletion = (AnyObject?, DataManagerError?) -> ()
    
    let baseURL: URL
    
    // MARK: - Initialization
    
    init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    // MARK: - Requesting Data
    
    func weatherDataForLocation(latitude: Double, longitude: Double, completion: WeatherDataCompletion) {
        
    }
    
}

struct getWeather {
    
    func weatherDataForLocation(latitude: Double, longitude: Double, completion: WeatherDataCompletion) {
        // Create URL
        let URL = baseURL.appendingPathComponent("\(latitude),\(longitude)")
        
        // Create Data Task
        URLSession.shared.dataTask(with: URL) { (data, response, error) in
            self.didFetchWeatherData(data: data, response: response, error: error, completion: completion)
            }.resume()
    }
    
    // MARK: - Helper Methods
    
    private func didFetchWeatherData(data: Data?, response: URLResponse?, error: Error?, completion: WeatherDataCompletion) {
        if let _ = error {
            completion(nil, .FailedRequest)
            
        } else if let data = data, let response = response as? HTTPURLResponse {
            if response.statusCode == 200 {
                processWeatherData(data: data, completion: completion)
            } else {
                completion(nil, .FailedRequest)
            }
            
        } else {
            completion(nil, .Unknown)
        }
    }
    
    
    private func processWeatherData(data: Data, completion: WeatherDataCompletion) {
        if let JSON = try? JSONSerialization.jsonObject(with: data, options: []) as AnyObject {
            completion(JSON, nil)
        } else {
            completion(nil, .InvalidResponse)
        }
    }
    
}
