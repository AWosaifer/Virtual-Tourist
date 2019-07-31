//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by A.M.W on 7/8/19.
//  Copyright © 2019 AW. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    static let shared = DataController()
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "Virtual_Tourist")
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            completion?()
        }
    }
    
    
    
}

extension DataController {
    func autoSaveViewContext(interval:TimeInterval = 30) {
        guard interval > 0 else {
            return
        }
        saveContext()
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
    func saveContext() {
        if viewContext.hasChanges {
            try? viewContext.save()
        }
    }
    
}

