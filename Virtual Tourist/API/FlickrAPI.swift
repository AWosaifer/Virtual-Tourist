//
//  FlickrAPI.swift
//  Virtual Tourist
//
//  Created by A.M.W on 7/8/19.
//  Copyright © 2019 AW. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct FlickrAPI {
    static let apiKey = "9adac33cf155eb08acc4b0e471eade84"
    static let baseURL = "https://api.flickr.com/services/rest"
    
    struct Parameters {
        static let FlickrSearch = "flickr.photos.search"
        static let apiKeyVar = "?api_key="
        static let latitude = "&lat="
        static let longitude = "&lon="
        static let extras = "&extras=url_m"
        static let perPage = "&per_page="
        static let page = "&page="
        static let format = "&format=json"
        static let callBack = "&nojsoncallback=1"
        static let radious = "&radius=10"
        static let numOfPhotos = 20
    }
 
    enum EndPoints {

        case searchPhoto(latitude: Double, longitude: Double, page: Int ,perPage: Int)


        var stringValue: String {
            switch self {
            case let .searchPhoto(latitude, longitude, page , perPage) :
            return "\(FlickrAPI.baseURL)\(Parameters.apiKeyVar)\(FlickrAPI.apiKey)&method=\(Parameters.FlickrSearch)\(Parameters.perPage)\(perPage)\(Parameters.numOfPhotos)\(Parameters.format)\(Parameters.callBack)\(Parameters.latitude)\(latitude)\(Parameters.longitude)\(longitude)\(Parameters.extras)\(Parameters.page)\(page)"


            }
        }

        var url: URL {
            return URL(string: stringValue)!
        }

    }


}

