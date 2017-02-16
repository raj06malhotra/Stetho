//
//  HealthInfo.swift
//  Health
//
//  Created by HW-Anil on 7/4/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class HealthInfo: NSObject {
    
    //try database.executeUpdate("insert into MyFamily (MemberId , MemberName , Relation , MemberPhoto , Active) values (?,?,?,?,?)", values: [member_id , MemberName , relation,memberPhoto, active])
    
    
    var memberId: String = String()
//    var memberName: String = String()
//    var memberRelation: String = String()
//    var memberPhoto: String = String()
//    var memberActive : String = String()
    var recordType: String = String()
    
    // report Variable
    var reportLabName: String = String()
    var reportTestName: String = String()
    var reportDate: String = String()
    var dataBaseId: String = String()
    var recordId: String = String()
  //  var syncStatus: String = String()
    // Prescription variable
    var doctorName: String = String()
    //var PresDiseaseName: String = String()
    //DiteChart
    var dietitianName : String = String()
    //Invoice
     var diseaseName: String = String()
    
    var PDFDataString :String = String()
    var recordLink : String = String()
    
    
    
    
    
    
    
    
    
    

}
