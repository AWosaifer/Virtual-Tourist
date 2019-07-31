//
//  PhotoCoreData.swift
//  Virtual Tourist
//
//  Created by A.M.W on 7/8/19.
//  Copyright © 2019 AW. All rights reserved.
//

import Foundation

class PhotoCoreData {
      
        class func getNewPhoto(pin: Pin, imageUrl: String) {
            
            let photo = Images(context: DataController.shared.viewContext)
            photo.createdAt = Date()
            photo.imageURL = imageUrl
            photo.pin = pin
        }
        
        class func savePhotos(pin: Pin, images: [FlickrImage]) {
            
            for image in images {
                getNewPhoto(pin: pin, imageUrl: image.urlM)
            }
            DataController.shared.saveContext()
        }
        
        class func deletePhotos(photos: [Images]) {
            for photo in photos {
                deletePhoto(photo: photo)
            }
            DataController.shared.saveContext()
        }
        
        class func deletePhoto(photo: Images) {
            DataController.shared.viewContext.delete(photo)
        }
        
        
        
    }


