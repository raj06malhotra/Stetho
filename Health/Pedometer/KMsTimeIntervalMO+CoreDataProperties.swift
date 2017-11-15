//
//  KMsTimeIntervalMO+CoreDataProperties.swift
//  Stetho Update
//
//  Created by Administrator on 20/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import CoreData


extension KMsTimeIntervalMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KMsTimeIntervalMO> {
        return NSFetchRequest<KMsTimeIntervalMO>(entityName: "KMsTimeIntervalMO")
    }

    @NSManaged public var uuid: String?
    @NSManaged public var kms: Double
    @NSManaged public var date: String?
    @NSManaged public var creationDate: NSDate?

}
