//
//  KMsDayMO+CoreDataClass.swift
//  Stetho Update
//
//  Created by Administrator on 20/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import CoreData

@objc(KMsDayMO)
public class KMsDayMO: NSManagedObject {
    
    class func createKMsDayModel() -> KMsDayMO{
        return NSManagedObject(entity: NSEntityDescription.entity(forEntityName: "KMsDayMO", in: DBManager.sharedDBManager.managedObjectContext)!, insertInto: DBManager.sharedDBManager.managedObjectContext) as! KMsDayMO
    }

}
