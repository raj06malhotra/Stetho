//
//  StepDayMO+CoreDataProperties.swift
//  Stetho Update
//
//  Created by Administrator on 18/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import CoreData


extension StepDayMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StepDayMO> {
        return NSFetchRequest<StepDayMO>(entityName: "StepDayMO")
    }

    @NSManaged public var creationDate: NSDate?
    @NSManaged public var resultStartDate: NSDate?
    @NSManaged public var resultEndDate: NSDate?
    @NSManaged public var date: String?
    @NSManaged public var totalSteps: Double
    @NSManaged public var uuid: String?
    @NSManaged public var stepTimeInterval: NSSet?
    @NSManaged public var activeSeconds: Int16
    @NSManaged public var targetSteps: Double
}

// MARK: Generated accessors for stepTimeInterval
extension StepDayMO {

    @objc(addStepTimeIntervalObject:)
    @NSManaged public func addToStepTimeInterval(_ value: StepTimeIntervalMO)

    @objc(removeStepTimeIntervalObject:)
    @NSManaged public func removeFromStepTimeInterval(_ value: StepTimeIntervalMO)

    @objc(addStepTimeInterval:)
    @NSManaged public func addToStepTimeInterval(_ values: NSSet)

    @objc(removeStepTimeInterval:)
    @NSManaged public func removeFromStepTimeInterval(_ values: NSSet)

}
