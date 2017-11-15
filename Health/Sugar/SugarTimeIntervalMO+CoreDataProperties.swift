//
//  SugarTimeIntervalMO+CoreDataProperties.swift
//  Stetho Update
//
//  Created by Administrator on 27/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import CoreData


extension SugarTimeIntervalMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SugarTimeIntervalMO> {
        return NSFetchRequest<SugarTimeIntervalMO>(entityName: "SugarTimeIntervalMO")
    }

    @NSManaged public var creationDate: NSDate?
    @NSManaged public var qunatityGram: Float
    @NSManaged public var time: String?

}
