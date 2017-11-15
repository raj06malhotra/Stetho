//
//  WaterDayMO+CoreDataProperties.swift
//  Stetho Update
//
//  Created by Administrator on 25/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import CoreData


extension WaterDayMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WaterDayMO> {
        return NSFetchRequest<WaterDayMO>(entityName: "WaterDayMO")
    }

    @NSManaged public var creationDate: NSDate?
    @NSManaged public var date: String?
    @NSManaged public var totalWaterDrink: Float
    @NSManaged public var totalWaterTarget: Float

    

}
