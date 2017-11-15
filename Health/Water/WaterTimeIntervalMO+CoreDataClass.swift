//
//  WaterTimeIntervalMO+CoreDataClass.swift
//  Stetho Update
//
//  Created by Administrator on 25/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import CoreData

@objc(WaterTimeIntervalMO)
public class WaterTimeIntervalMO: NSManagedObject {

    class func createWaterTimeIntervalModel() -> WaterTimeIntervalMO{
        return NSManagedObject(entity: NSEntityDescription.entity(forEntityName: "WaterTimeIntervalMO", in: DBManager.sharedDBManager.managedObjectContext)!, insertInto: DBManager.sharedDBManager.managedObjectContext) as! WaterTimeIntervalMO
    }
}
