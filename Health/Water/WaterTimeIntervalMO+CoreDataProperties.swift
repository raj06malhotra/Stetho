//
//  WaterTimeIntervalMO+CoreDataProperties.swift
//  Stetho Update
//
//  Created by Administrator on 25/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import CoreData


extension WaterTimeIntervalMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WaterTimeIntervalMO> {
        return NSFetchRequest<WaterTimeIntervalMO>(entityName: "WaterTimeIntervalMO")
    }

    @NSManaged public var time: String?
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var qunatityLitre: Float

}
