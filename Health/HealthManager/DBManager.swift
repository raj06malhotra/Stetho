//
//  DBManager.swift
//  Stetho Update
//
//  Created by Administrator on 18/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import CoreData

class DBManager {
    static let sharedDBManager = DBManager()
    
    private init() {
        print("Private DB Manager")
    }
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.cadiridris.coreDataTemplate" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Stetho_Update", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("Stetho_Updatea.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    //MARK: CUSTOM METHODS
    
    func fetchStepsDatafromDB(ascending: Bool) -> [StepDayMO] {
        let fetchRequest = NSFetchRequest<StepDayMO>(entityName: "StepDayMO")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending:ascending)]
        do{
            return try DBManager.sharedDBManager.managedObjectContext.fetch(fetchRequest)
        }
        catch{
            fatalError("Something went wrong when performing fetch")
        }
        
    }
    
    
    
    func fetchKMsDatafromDB(ascending: Bool) -> [KMsDayMO] {
        let fetchRequest = NSFetchRequest<KMsDayMO>(entityName: "KMsDayMO")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: ascending)]
        do{
            return try DBManager.sharedDBManager.managedObjectContext.fetch(fetchRequest)
        }
        catch{
            fatalError("Something went wrong when performing fetch")
        }
    }
    
    func fetchStepDataforDay(date: String) -> StepDayMO? {
        let fetchRequest = NSFetchRequest<StepDayMO>(entityName: "StepDayMO")
        fetchRequest.predicate = NSPredicate(format: "date=%@", date)
        do{
            let stepDayArr = try DBManager.sharedDBManager.managedObjectContext.fetch(fetchRequest)
            if stepDayArr.count > 0{
                return stepDayArr[0]
            }
            return nil
        }
        catch{
            fatalError("Something went wrong when performing fetch")
        }
    }
    
    func fetchKMsDataforDay(date: String) -> KMsDayMO? {
        let fetchRequest = NSFetchRequest<KMsDayMO>(entityName: "KMsDayMO")
        fetchRequest.predicate = NSPredicate(format: "date=%@", date)
        do{
            let kmsDayMO = try DBManager.sharedDBManager.managedObjectContext.fetch(fetchRequest)
            if kmsDayMO.count > 0{
                return kmsDayMO[0]
            }
            return nil
        }
        catch{
            fatalError("Something went wrong when performing fetch")
        }
    }
    
    func fetchWaterDataforDay(date: String) -> WaterDayMO? {
        let fetchRequest = NSFetchRequest<WaterDayMO>(entityName: "WaterDayMO")
        fetchRequest.predicate = NSPredicate(format: "date=%@", date)
        do{
            let waterDayMO = try DBManager.sharedDBManager.managedObjectContext.fetch(fetchRequest)
            if waterDayMO.count > 0{
                return waterDayMO[0]
            }
            return nil
        }
        catch{
            fatalError("Something went wrong when performing fetch")
        }
    }
    
    func fetchSugarDataforDay(date: String) -> SugarDayMO? {
        let fetchRequest = NSFetchRequest<SugarDayMO>(entityName: "SugarDayMO")
        fetchRequest.predicate = NSPredicate(format: "date=%@", date)
        do{
            let sugarDayMO = try DBManager.sharedDBManager.managedObjectContext.fetch(fetchRequest)
            if sugarDayMO.count > 0{
                return sugarDayMO[0]
            }
            return nil
        }
        catch{
            fatalError("Something went wrong when performing fetch")
        }
    }
    
}
