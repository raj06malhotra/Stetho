//
//  StepTimeIntervalMO+CoreDataClass.swift
//  Stetho Update
//
//  Created by Administrator on 18/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import CoreData

@objc(StepTimeIntervalMO)
public class StepTimeIntervalMO: PedometerMO {
    
    class func createStepTimeIntervalModel() -> StepTimeIntervalMO{
        return NSManagedObject(entity: NSEntityDescription.entity(forEntityName: "StepTimeIntervalMO", in: DBManager.sharedDBManager.managedObjectContext)!, insertInto: DBManager.sharedDBManager.managedObjectContext) as! StepTimeIntervalMO
    }

}
