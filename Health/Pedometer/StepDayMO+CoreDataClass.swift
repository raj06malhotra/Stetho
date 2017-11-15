//
//  StepDayMO+CoreDataClass.swift
//  Stetho Update
//
//  Created by Administrator on 18/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import CoreData

@objc(StepDayMO)
public class StepDayMO: NSManagedObject {
    
    class func createStepDayModel() -> StepDayMO{
        return NSManagedObject(entity: NSEntityDescription.entity(forEntityName: "StepDayMO", in: DBManager.sharedDBManager.managedObjectContext)!, insertInto: DBManager.sharedDBManager.managedObjectContext) as! StepDayMO
        
    }
    
    class func saveStepMOArr(arr: Array<Dictionary<String, Any>>, completion: (()->())) {
        for stepMODict in arr {
            let stepDayMO = createStepDayModel()
            stepDayMO.date = stepMODict["DATE"] as? String
            stepDayMO.activeSeconds = Int16((stepMODict["Active_Min"] as? String)!)!*60
            stepDayMO.totalSteps = Double(stepMODict["Complete_step"] as! String) ?? 0
            stepDayMO.targetSteps = Double(stepMODict["Target_step"] as! String) ?? 0
            stepDayMO.creationDate = Date() as NSDate
        }
        UserDefaults.standard.set(arr.last?["DATE"] as? String, forKey: KLASTSYNCDATE)
        completion()
    }

}
