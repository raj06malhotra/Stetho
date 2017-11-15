//
//  SugarDayMO+CoreDataClass.swift
//  Stetho Update
//
//  Created by Administrator on 27/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import CoreData

@objc(SugarDayMO)
public class SugarDayMO: NSManagedObject {
    
    class func createSugarDayModel() -> SugarDayMO{
        return NSManagedObject(entity: NSEntityDescription.entity(forEntityName: "SugarDayMO", in: DBManager.sharedDBManager.managedObjectContext)!, insertInto: DBManager.sharedDBManager.managedObjectContext) as! SugarDayMO
    }
    
    class func fetchSugarData(ascending: Bool) -> [SugarDayMO] {
        let fetchRequest = NSFetchRequest<SugarDayMO>(entityName: "SugarDayMO")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: ascending)]
        do{
            return try DBManager.sharedDBManager.managedObjectContext.fetch(fetchRequest)
        }catch{
            fatalError("Something went wrong when performing fetch")
        }
    }
    
    class func saveSugarMOArr(arr: Array<Dictionary<String, Any>>, completion: (()->())) {
        for sugarMODict in arr {
            if DBManager.sharedDBManager.fetchWaterDataforDay(date: sugarMODict["DATE"] as! String) != nil {
                completion()
                return
            }
            let sugarDayMO = createSugarDayModel()
            sugarDayMO.date = sugarMODict["DATE"] as? String
            sugarDayMO.totalSugarIntake = Float(sugarMODict["Complete_step"] as! String) ?? 0
            sugarDayMO.totalSugarTarget = Float(sugarMODict["Target_step"] as! String) ?? 0
            sugarDayMO.creationDate = Date() as NSDate
        }
  //      UserDefaults.standard.set(arr.last?["DATE"] as? String, forKey: KLASTSYNCDATE)
        completion()
    }

}
