//
//  SugarDayMO+CoreDataProperties.swift
//  Stetho Update
//
//  Created by Administrator on 27/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import CoreData


extension SugarDayMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SugarDayMO> {
        return NSFetchRequest<SugarDayMO>(entityName: "SugarDayMO")
    }

    @NSManaged public var creationDate: NSDate?
    @NSManaged public var date: String?
    @NSManaged public var totalSugarIntake: Float
    @NSManaged public var totalSugarTarget: Float

}
