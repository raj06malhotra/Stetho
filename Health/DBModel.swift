//
//  DBModel.swift
//  Health
//
//  Created by HW-Anil on 7/4/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class DBModel: NSObject {
    
  internal  func createDataBase()  {
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = URL(fileURLWithPath: path)
        let filePath = url.appendingPathComponent("HealthDatabase.db").path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            print("FILE AVAILABLE")
            print(filePath)
        } else {
            print("FILE NOT AVAILABLE")
            let documents = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documents.appendingPathComponent("HealthDatabase.db")
            let database = FMDatabase(path: fileURL.path)
            
            if !(database?.open())! {
                print("Unable to open database")
                return
            }
            self.createTables()
            
        }
    }
    
    func createTables()  {
        
        let documents = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileURL = documents.appendingPathComponent("HealthDatabase.db")
        
        let database = FMDatabase(path: fileURL.path)
        
        if !(database?.open())! {
            print("Unable to open database")
            return
        }
        
        do {
            try database?.executeUpdate("CREATE TABLE UserDetails ("
                + "_id INTEGER PRIMARY KEY AUTOINCREMENT, "
                + "DatabaseId INTEGER, "
                + "FullName TEXT, "
                + "CurrentDate TEXT, "
                + "MobileNumber TEXT, "
                + "IsUserActive INTEGER DEFAULT 0)", values: nil)
            
//            try database.executeUpdate("CREATE TABLE Notifications ("
//                + "_id INTEGER PRIMARY KEY AUTOINCREMENT, "
//                + "NotificationId INT, "
//                + "NotificationText INT, "
//                + "MemberPhoto TEXT, "
//                + "MemberName TEXT, "
//                + "Relation TEXT, "
//                + "MemberId TEXT, "
//                + "AcceptStatus INT, "
//                + "SeenStatus INT, "
//                + "RecordLink TEXT, "
//                + "RecordType TEXT, "
//                + "NotificationType TEXT)", values: nil)
            
            try database?.executeUpdate("CREATE TABLE MyFamily ("
                + "_id INTEGER PRIMARY KEY AUTOINCREMENT, "
                + "MemberId INT, "
                + "MemberName TEXT, "
                + "Relation TEXT, "
                + "MemberPhoto TEXT, "
                + "MemberEmail TEXT, "
                + "MemberGender TEXT,"
                + "MemberMobileNo TEXT,"
                + "MemberDOB TEXT,"
                + "SyncStatus TEXT,"
                + "Verified TEXT,"
                + "Active INT)", values: nil)
            
            try database?.executeUpdate("CREATE TABLE RecordDetails ("
                + "_id INTEGER PRIMARY KEY AUTOINCREMENT, "
                + "DataBaseId INT , "
                + "RecordLink TEXT, "
                + "RecordId TEXT, "
                + "MemberId INT, "
                + "RecordDate TEXT, "
                + "RecordLabName TEXT, "
                + "RecordTestName TEXT, "
                + "DoctorName TEXT, "
                + "DietitianName TEXT, "
                + "RecordDisease TEXT, "
                + "RecordType TEXT, "
                + "RecordString TEXT, "
                + "ServerToLocalSyncStatus TEXT,"
                + "LocalToServerSyncStatus TEXT,"
                + "isDeleted TEXT)", values: nil)
            
            try database?.executeUpdate("CREATE TABLE OrderDetails ("
                + "_id INTEGER PRIMARY KEY AUTOINCREMENT, "
                + "OrderId TEXT, "
                + "MemberId INT, "
                + "DOB TEXT, "
                + "Gender TEXT, "
                + "FirstName TEXT, "
                + "LastName TEXT, "
                + "MemberPhone TEXT, "
                + "MemberEmail TEXT)", values: nil)
            
            try database?.executeUpdate("CREATE TABLE PickupAddress ("
                + "_id INTEGER PRIMARY KEY AUTOINCREMENT, "
                + "MemberId TEXT, "
                + "AddressLine1 TEXT, "
                + "AddressLine2 TEXT, "
                + "LandMark TEXT, "
                + "City TEXT, "
                + "Pincode TEXT, "
                + "GeoAddress TEXT, "
                + "Latitude TEXT, "
                + "Longitude TEXT, "
                + "OrderDay TEXT, "
                + "OrderDate TEXT, "
                + "OrderTime TEXT)", values: nil)
            
            try database?.executeUpdate("CREATE TABLE Order_Package_Purchased ("
                + "_id INTEGER PRIMARY KEY AUTOINCREMENT, "
                + "OrderId TEXT, "
                + "PackageId TEXT, "
                + "PackageName TEXT, "
                + "PackageType TEXT, "
                + "addedToCart TEXT, "
                + "PackagePrice TEXT)", values: nil)
            
//                //+ "MemberId INT, "
//                + "MemberName TEXT, "
//                + "Quantity INTEGER, "
//                + "Duration INTEGER, "
//                + "DataBaseId INT, "
//                + "IsDeleted INT, "
//                + "SyncStatus TEXT)
            
            try database?.executeUpdate("CREATE TABLE Reminder ("
                + "_id INTEGER PRIMARY KEY AUTOINCREMENT, "
                + "ReminderId TEXT,"
                + "MemberId INT,"
                + "MemberName TEXT,"
                + "MedicineName TEXT, "
                + "ReminderImage TEXT, "
                + "MorningTime TEXT, "
                + "AfternoonTime TEXT, "
                + "EveningTime TEXT, "
                + "StartDate TEXT, "
                + "EndDate TEXT, "
                + "Quantity INTEGER,"
                + "Duration INTEGER,"
                + "IsDeleted INT,"
                + "SyncStatus INTEGER)", values: nil)
            
            
            try database?.executeUpdate("CREATE TABLE Notifications ("
                + "_id INTEGER PRIMARY KEY AUTOINCREMENT, "
                + "NotificationId INT, "
                + "NotificationText TEXT, "
                + "NotificationMessage TEXT, "
                + "NotificationImage TEXT, "
                + "NotificationTime TEXT, "
                + "MemberPhoto TEXT, "
                + "MemberName TEXT, "
                + "MemberNumber TEXT, "
                + "MemberEmail TEXT, "
                + "MemberGender TEXT, "
                + "MemberDOB TEXT, "
                + "Relation TEXT, "
                + "MemberId TEXT, "
                + "AcceptStatus INT, "
                + "SeenStatus INT, "
                + "RecordLink TEXT, "
                + "RecordType TEXT, "
                + "NotificationType TEXT)", values: nil);
            
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        
        database?.close()

        
    }
    
    
    func exequteQuery(_ query : String)  {
        
        let documents = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileURL = documents.appendingPathComponent("HealthDatabase.db")
        
        let database = FMDatabase(path: fileURL.path)
        
        if !(database?.open())! {
            print("Unable to open database")
            return
        }
        
        do {
             try database?.executeUpdate("insert into UserDetails (FullName) values (?)", values: ["roshan"])
            
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        
        database?.close()
        
        
    }
    
       
    
    
        
}
