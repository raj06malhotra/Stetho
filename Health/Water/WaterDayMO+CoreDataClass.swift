//
//  WaterDayMO+CoreDataClass.swift
//  Stetho Update
//
//  Created by Administrator on 25/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import CoreData

@objc(WaterDayMO)
public class WaterDayMO: NSManagedObject {

    class func createWaterDayModel() -> WaterDayMO{
        return NSManagedObject(entity: NSEntityDescription.entity(forEntityName: "WaterDayMO", in: DBManager.sharedDBManager.managedObjectContext)!, insertInto: DBManager.sharedDBManager.managedObjectContext) as! WaterDayMO
    }
    
    class func fetchWaterData(ascending: Bool) -> [WaterDayMO] {
        let fetchRequest = NSFetchRequest<WaterDayMO>(entityName: "WaterDayMO")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: ascending)]
        do{
            return try DBManager.sharedDBManager.managedObjectContext.fetch(fetchRequest)
        }catch{
            fatalError("Something went wrong when performing fetch")
        }
    }
    
    class func saveWaterMOArr(arr: Array<Dictionary<String, Any>>, completion: (()->())) {
        for waterMODict in arr {
            if DBManager.sharedDBManager.fetchWaterDataforDay(date: waterMODict["DATE"] as! String) != nil {
                completion()
                return
            }
            let waterDayMO = createWaterDayModel()
            waterDayMO.date = waterMODict["DATE"] as? String
            waterDayMO.totalWaterDrink = Float(waterMODict["Complete_step"] as! String) ?? 0
            waterDayMO.totalWaterTarget = Float(waterMODict["Target_step"] as! String)!/1000
            waterDayMO.creationDate = Date() as NSDate
        }
       // UserDefaults.standard.set(arr.last?["DATE"] as? String, forKey: KLASTSYNCDATE)
        completion()
    }
}

