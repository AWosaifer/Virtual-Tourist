//
//  Configuration.swift
//  Virtual Tourist
//
//  Created by A.M.W on 7/28/19.
//  Copyright © 2019 AW. All rights reserved.
//


import Foundation

struct API {

    static let APIKey = "4d8dbd2a6a249a4fb43f40623a58810a"
    static let BaseURL = URL(string: "https://api.forecast.io/forecast/")!

    static var AuthenticatedBaseURL: URL {
        return BaseURL.appendingPathComponent(APIKey)
    }

}
