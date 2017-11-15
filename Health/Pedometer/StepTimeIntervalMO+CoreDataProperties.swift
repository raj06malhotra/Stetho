//
//  StepTimeIntervalMO+CoreDataProperties.swift
//  Stetho Update
//
//  Created by Administrator on 18/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import CoreData


extension StepTimeIntervalMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StepTimeIntervalMO> {
        return NSFetchRequest<StepTimeIntervalMO>(entityName: "StepTimeIntervalMO")
    }

    @NSManaged public var steps: Double
    @NSManaged public var uuid: String?
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var date: String?
    @NSManaged public var stepsDay: StepDayMO?

}
