//
//  KMsTimeIntervalMO+CoreDataClass.swift
//  Stetho Update
//
//  Created by Administrator on 20/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import CoreData

@objc(KMsTimeIntervalMO)
public class KMsTimeIntervalMO: PedometerMO {
    
    class func createKMsTimeIntervalModel() -> KMsTimeIntervalMO {
        return NSManagedObject(entity: NSEntityDescription.entity(forEntityName: "KMsTimeIntervalMO", in: DBManager.sharedDBManager.managedObjectContext)!, insertInto: DBManager.sharedDBManager.managedObjectContext) as! KMsTimeIntervalMO
    }

}
