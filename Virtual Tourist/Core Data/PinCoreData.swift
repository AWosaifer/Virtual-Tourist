//
//  PinCoreData.swift
//  Virtual Tourist
//
//  Created by A.M.W on 7/8/19.
//  Copyright © 2019 AW. All rights reserved.
//

import Foundation

class PinCoreData{
    class func getNewPin(latitude: Double, longitude: Double) -> Pin {
        
        let pin = Pin(context: DataController.shared.viewContext)
        pin.createdAt = Date()
        pin.latitude = latitude
        pin.longitude = longitude
        DataController.shared.saveContext()
        return pin
    }
    
     class func deletePin(pin:Pin){
        DataController.shared.viewContext.delete(pin)
        DataController.shared.saveContext()
        
    }
    
}
