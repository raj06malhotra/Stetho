//
//  KMsDayMO+CoreDataProperties.swift
//  Stetho Update
//
//  Created by Administrator on 20/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import CoreData


extension KMsDayMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KMsDayMO> {
        return NSFetchRequest<KMsDayMO>(entityName: "KMsDayMO")
    }

    @NSManaged public var creationDate: NSDate?
    @NSManaged public var date: String?
    @NSManaged public var totalKMs: Double
    @NSManaged public var totalKMsTraget: Double
    @NSManaged public var kmsTimeInterval: NSSet?

}

// MARK: Generated accessors for kmsTimeInterval
extension KMsDayMO {

    @objc(addKmsTimeIntervalObject:)
    @NSManaged public func addToKmsTimeInterval(_ value: KMsTimeIntervalMO)

    @objc(removeKmsTimeIntervalObject:)
    @NSManaged public func removeFromKmsTimeInterval(_ value: KMsTimeIntervalMO)

    @objc(addKmsTimeInterval:)
    @NSManaged public func addToKmsTimeInterval(_ values: NSSet)

    @objc(removeKmsTimeInterval:)
    @NSManaged public func removeFromKmsTimeInterval(_ values: NSSet)

}
