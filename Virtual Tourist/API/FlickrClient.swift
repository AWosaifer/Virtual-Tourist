//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by A.M.W on 7/8/19.
//  Copyright © 2019 AW. All rights reserved.
//

import Foundation
import UIKit

class FlickrClient {
    
    class func searchPhotos(latitude: Double, longitude: Double, done: @escaping ([FlickrImage]) -> Void,  errors: @escaping (Error) -> Void ){
        
        // get Random page between 1...100
        let page = Int.random(in: 1...100)
       
        let url = FlickrAPI.EndPoints.searchPhoto(latitude: latitude, longitude: longitude, page: page, perPage: 9).url
        let request = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            if error != nil {
                
                let problemError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "You are not connected"])
                DispatchQueue.main.async {
                    
                    errors(problemError)
                }
            }
            print(url)
            
            guard let data = data else {
                return
            }
            
            do {
                
                let flickrResonse = try JSONDecoder().decode(FlickrResponse.self, from: data)
                DispatchQueue.main.async {
                    done(flickrResonse.photos.photo)
                    
                }
                
            }
            catch {
                DispatchQueue.main.async {
                    errors(error)
                }
            }
            
        }
        task.resume()
    }

}

