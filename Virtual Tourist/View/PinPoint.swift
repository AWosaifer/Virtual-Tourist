//
//  PinPoint.swift
//  Virtual Tourist
//
//  Created by A.M.W on 7/8/19.
//  Copyright © 2019 AW. All rights reserved.
//

import Foundation
import MapKit
class  PinPoint: MKPointAnnotation {
    
    var pinObject: Pin!
    
    init(pin: Pin){
        super.init()
        self.pinObject = pin
        coordinate.latitude = pin.latitude
        coordinate.longitude = pin.longitude
    }
    
    override init() {
        super.init()
    }
}
