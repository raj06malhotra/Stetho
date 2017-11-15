//
//  PedometerMO+CoreDataProperties.swift
//  Stetho Update
//
//  Created by Administrator on 18/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import CoreData


extension PedometerMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PedometerMO> {
        return NSFetchRequest<PedometerMO>(entityName: "PedometerMO")
    }

    @NSManaged public var endTime: String?
    @NSManaged public var startTime: String?
    @NSManaged public var timeIntervalSecs: Int16

}
