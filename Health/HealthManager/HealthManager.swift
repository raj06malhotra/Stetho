 //
//  File.swift
//  Stetho Update
//
//  Created by Administrator on 18/07/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import Foundation
import HealthKit
 
 protocol AcitveMinsSyncedProtocol {
    func activeMinsSyncedSuccessfully()
 }

final class HealthManager: NSObject {
    
    let hkHealthStore:HKHealthStore = HKHealthStore()
    static let sharedHealthManger = HealthManager()
    
    let calendar = Calendar.current
    var interval = DateComponents()
    //calendar.component([.day, .month, .year], from: Date())
    var anchorDate: Date!
    let quantityTypeSteps = HKObjectType.quantityType(forIdentifier: .stepCount)
    let quantityTypeKMs = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)
    var stepDayMOArr: [StepDayMO] = []
    var delegateActiveMins: AcitveMinsSyncedProtocol?


    
    private override init() {
        super.init()
        interval.day = 1
        var anchorComponents = calendar.dateComponents([.day, .month, .year], from: Date())
        anchorComponents.hour = 0
        anchorDate = calendar.date(from: anchorComponents)
        
        print("Default Private Constructor")
    }
    
    deinit {
        print("deinitializing health manager")
    }
    
    func isHealthkitAuthorize() -> HKAuthorizationStatus{
        return self.hkHealthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!)
    }
    
    func authrizeHealthKit(completion:@escaping ((Bool, NSError?) -> Void)){
        let heathKitTypetoRead_Write: Set<HKQuantityType> = [HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!]//, HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
        
        
        
        if HKHealthStore.isHealthDataAvailable() {
            hkHealthStore.requestAuthorization(toShare: heathKitTypetoRead_Write, read: heathKitTypetoRead_Write, completion: { (success, error) in
                
                if self.hkHealthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!) == .sharingDenied {
                    completion(false, error as NSError?)
                }else{
                    completion(success, error as NSError?)
                }
            })
        }else{
            completion(false, NSError(domain: "HealthKit Error", code: 2, userInfo: [NSLocalizedDescriptionKey : "HealthKit is not available in this Device"]))
        }
    }
    
    func readStaisticsData(completion: @escaping (()-> ())){
        let calendar = Calendar.current
        var interval = DateComponents()
        interval.day = 1
        //calendar.component([.day, .month, .year], from: Date())
        var anchorComponents = calendar.dateComponents([.day, .month, .year], from: Date())
        anchorComponents.hour = 0
        let anchorDate = calendar.date(from: anchorComponents)
        let quantityType = HKObjectType.quantityType(forIdentifier: .stepCount)
//        serialQueue.sync {
            let collectionQuery = HKStatisticsCollectionQuery(quantityType: quantityType!, quantitySamplePredicate: nil, options: .cumulativeSum, anchorDate: anchorDate!, intervalComponents: interval)
            collectionQuery.initialResultsHandler = {(query, result, error) in
                if error != nil {
                    print("*** An error occurred while calculating the statistics: %@ ***",error?.localizedDescription ?? "")
                }
                let endDate = Date()
                let startDate = calendar.date(byAdding: Calendar.Component.month, value: -1, to: endDate)
                result?.enumerateStatistics(from: startDate!, to: endDate, with: { (result, stop) in
                    let quantity: HKQuantity? = result.sumQuantity()
                    let stepsMO = StepDayMO.createStepDayModel()
                    stepsMO.date = GlobalInfo.sharedGlobalInfo.localDateFormatter_dd_MMM_yyyy.string(from: result.startDate)
                    stepsMO.creationDate = Date() as NSDate
                    stepsMO.resultStartDate = result.startDate as NSDate
                    stepsMO.resultEndDate = result.endDate as NSDate
                    stepsMO.targetSteps = targetSteps
                    if quantity != nil{
                        stepsMO.totalSteps = quantity!.doubleValue(for: HKUnit.count())
                    }
                        DBManager.sharedDBManager.saveContext()
                })
                completion()
            }
            self.hkHealthStore.execute(collectionQuery)
//        }
        
    }
    
    func fetchActiveMins(fromIndex: Int) {
        print(fromIndex)
      let stepDayMO = stepDayMOArr[fromIndex]
        
        if stepDayMO.totalSteps == 0 {
            if fromIndex+1 < self.stepDayMOArr.count {
                self.fetchActiveMins(fromIndex: fromIndex + 1 )
            }else{
              self.delegateActiveMins?.activeMinsSyncedSuccessfully()
            }
            return
        }
        let predicate = HKSampleQuery.predicateForSamples(withStart: stepDayMO.resultStartDate! as Date, end: stepDayMO.resultEndDate as Date?, options: HKQueryOptions(rawValue: 0))

        
            let query = HKSampleQuery(sampleType: quantityTypeSteps!, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, sampleResult, error) in
                
                if error == nil{
                    var totalSeconds:Int16 = 0
                    for sample in sampleResult! as! [HKQuantitySample] {
//                        let stepTimeIntervalMO = StepTimeIntervalMO.createStepTimeIntervalModel()
//                        stepTimeIntervalMO.creationDate = Date() as NSDate
//                        stepTimeIntervalMO.startTime = DateFormatter.localizedString(from: sample.startDate, dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.medium)
//                        stepTimeIntervalMO.endTime = DateFormatter.localizedString(from: sample.endDate, dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.medium)
//                        stepTimeIntervalMO.steps = sample.quantity.doubleValue(for: HKUnit.count())
                        totalSeconds += Int16(sample.endDate.seconds(from: sample.startDate))
//                        stepTimeIntervalMO.timeIntervalSecs = Int16(sample.endDate.seconds(from: sample.startDate))
//                        stepDayMO.addToStepTimeInterval(stepTimeIntervalMO)
                    }
                    stepDayMO.activeSeconds = totalSeconds
                    DBManager.sharedDBManager.saveContext()
                    if fromIndex+1 < self.stepDayMOArr.count {
                        
                        self.fetchActiveMins(fromIndex: fromIndex + 1)
                    }else{
                        self.delegateActiveMins?.activeMinsSyncedSuccessfully()
                    }
                   // self.hkHealthStore.stop(query)
                    //completion(true, nil)
                }
            }
        self.hkHealthStore.execute(query)
        }
    
    func readStatisticsStepsDataforPeriod(startDate: Date, completion: @escaping (() -> ()) ){
        stepDayMOArr.removeAll()
        let collectionQuery = HKStatisticsCollectionQuery(quantityType: quantityTypeSteps!, quantitySamplePredicate: nil, options: .cumulativeSum, anchorDate: anchorDate!, intervalComponents: interval)
        collectionQuery.initialResultsHandler = {(query, result, error) in
            if error != nil {
                print("*** An error occurred while calculating the statistics: %@ ***",error?.localizedDescription ?? "")
            }
            let endDate = Date()
            //let startDate = self.calendar.date(byAdding: Calendar.Component.month, value: -1, to: endDate)
            result?.enumerateStatistics(from: startDate, to: endDate, with: { (result, stop) in
                let quantity: HKQuantity? = result.sumQuantity()
                var stepsMO: StepDayMO!
                var needSaveContext: Bool = true
                if let stepDayMO = DBManager.sharedDBManager.fetchStepDataforDay(date: GlobalInfo.sharedGlobalInfo.localDateFormatter_dd_MMM_yyyy.string(from: result.startDate)) {
                    stepsMO = stepDayMO
                    stepsMO.mutableSetValue(forKey: "stepTimeInterval").removeAllObjects()
                   // needSaveContext = false
                }else{
                    stepsMO = StepDayMO.createStepDayModel()
                    stepsMO.targetSteps = targetSteps
                    
                }
                stepsMO.resultStartDate = result.startDate as NSDate
                stepsMO.resultEndDate = result.endDate as NSDate
                stepsMO.date = GlobalInfo.sharedGlobalInfo.localDateFormatter_dd_MMM_yyyy.string(from: result.startDate)
                stepsMO.creationDate = Date() as NSDate
                
                if quantity != nil{
                    stepsMO.totalSteps = quantity!.doubleValue(for: HKUnit.count())
                }else{
                    stepsMO.totalSteps = 0
                }
                //else{
                    if needSaveContext {
                        DBManager.sharedDBManager.saveContext()
                    }
                    self.stepDayMOArr.append(stepsMO)
//                }
            })
            completion()
        }
        self.hkHealthStore.execute(collectionQuery)
        
    }
    
    func readStaisticsKMsData(completion: @escaping (()-> ())){
        let calendar = Calendar.current
        var interval = DateComponents()
        interval.day = 1
        //calendar.component([.day, .month, .year], from: Date())
        var anchorComponents = calendar.dateComponents([.day, .month, .year], from: Date())
        anchorComponents.hour = 0
        let anchorDate = calendar.date(from: anchorComponents)
        let quantityType = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)
        
        let collectionQuery = HKStatisticsCollectionQuery(quantityType: quantityType!, quantitySamplePredicate: nil, options: .cumulativeSum, anchorDate: anchorDate!, intervalComponents: interval)
        collectionQuery.initialResultsHandler = {(query, result, error) in
            if error != nil {
                print("*** An error occurred while calculating the statistics: %@ ***",error?.localizedDescription ?? "")
            }
            let endDate = Date()
            let startDate = calendar.date(byAdding: Calendar.Component.month, value: -1, to: endDate)
            result?.enumerateStatistics(from: startDate!, to: endDate, with: { (result, stop) in
                
                let quantity: HKQuantity? = result.sumQuantity()
                
                let kmsMO = KMsDayMO.createKMsDayModel()
                kmsMO.date = GlobalInfo.sharedGlobalInfo.localDateFormatter_dd_MMM_yyyy.string(from: result.startDate)
                kmsMO.creationDate = Date() as NSDate
                
                kmsMO.totalKMsTraget = Double(totalKmsTarget)
                if quantity != nil{
                    kmsMO.totalKMs = quantity!.doubleValue(for: HKUnit.meterUnit(with: HKMetricPrefix.kilo))
                    
                    let predicate = HKSampleQuery.predicateForSamples(withStart: result.startDate, end: result.endDate, options: HKQueryOptions(rawValue: 0))
                    
                
                    
                    let query = HKSampleQuery(sampleType: quantityType!, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, sampleResult, error) in
                        if error == nil{
                            
                            for sample in sampleResult! as! [HKQuantitySample] {
                                
                                let kmTimeIntervalMO = KMsTimeIntervalMO.createKMsTimeIntervalModel()
                                kmTimeIntervalMO.creationDate = Date() as NSDate
                                kmTimeIntervalMO.startTime = DateFormatter.localizedString(from: sample.startDate, dateStyle: DateFormatter.Style.medium, timeStyle: DateFormatter.Style.medium)
                                kmTimeIntervalMO.endTime = DateFormatter.localizedString(from: sample.endDate, dateStyle: DateFormatter.Style.medium, timeStyle: DateFormatter.Style.medium)
                                kmTimeIntervalMO.kms = sample.quantity.doubleValue(for: HKUnit.meterUnit(with: HKMetricPrefix.kilo))
                                kmTimeIntervalMO.timeIntervalSecs = Int16(sample.endDate.seconds(from: sample.startDate))
                                kmsMO.addToKmsTimeInterval(kmTimeIntervalMO)//addt (kmTimeIntervalMO)
                            }
                            DBManager.sharedDBManager.saveContext()
                            //completion(true, nil)
                        }
                    }
                    self.hkHealthStore.execute(query)
                }else{
                    DBManager.sharedDBManager.saveContext()
                }
            })
            completion()
        }
        self.hkHealthStore.execute(collectionQuery)
        
    }
    
    func readKMsDataforPeriod(startDate: Date, completion: @escaping (()->())){
        
        let collectionQuery = HKStatisticsCollectionQuery(quantityType: quantityTypeKMs!, quantitySamplePredicate: nil, options: .cumulativeSum, anchorDate: anchorDate!, intervalComponents: interval)
        collectionQuery.initialResultsHandler = {(query, result, error) in
            if error != nil {
                print("*** An error occurred while calculating the statistics: %@ ***",error?.localizedDescription ?? "")
            }
            let endDate = Date()
            //let startDate = calendar.date(byAdding: Calendar.Component.month, value: -1, to: endDate)
            result?.enumerateStatistics(from: startDate, to: endDate, with: { (result, stop) in
                
                let quantity: HKQuantity? = result.sumQuantity()
                
                let kmsMO: KMsDayMO!
                var needSaveContext: Bool = true
                if let kmDayMO = DBManager.sharedDBManager.fetchKMsDataforDay(date: GlobalInfo.sharedGlobalInfo.localDateFormatter_dd_MMM_yyyy.string(from: result.startDate)){
                    kmsMO = kmDayMO
                    kmsMO.mutableSetValue(forKey: "kmsTimeInterval").removeAllObjects()
                    needSaveContext = false
                }else{
                    kmsMO = KMsDayMO.createKMsDayModel()
                    kmsMO.totalKMsTraget = Double(totalKmsTarget)
                }
                
                kmsMO.date = GlobalInfo.sharedGlobalInfo.localDateFormatter_dd_MMM_yyyy.string(from: result.startDate)
                kmsMO.creationDate = Date() as NSDate
                
                if quantity != nil{
                    kmsMO.totalKMs = quantity!.doubleValue(for: HKUnit.meterUnit(with: HKMetricPrefix.kilo))
                    
                    let predicate = HKSampleQuery.predicateForSamples(withStart: result.startDate, end: result.endDate, options: HKQueryOptions(rawValue: 0))
                    
                    
                    
                    let query = HKSampleQuery(sampleType: self.quantityTypeKMs!, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, sampleResult, error) in
                        if error == nil{
                            
                            for sample in sampleResult! as! [HKQuantitySample] {
                                
                                let kmTimeIntervalMO = KMsTimeIntervalMO.createKMsTimeIntervalModel()
                                kmTimeIntervalMO.creationDate = Date() as NSDate
                                kmTimeIntervalMO.startTime = DateFormatter.localizedString(from: sample.startDate, dateStyle: DateFormatter.Style.medium, timeStyle: DateFormatter.Style.medium)
                                kmTimeIntervalMO.endTime = DateFormatter.localizedString(from: sample.endDate, dateStyle: DateFormatter.Style.medium, timeStyle: DateFormatter.Style.medium)
                                kmTimeIntervalMO.kms = sample.quantity.doubleValue(for: HKUnit.meterUnit(with: HKMetricPrefix.kilo))
                                kmTimeIntervalMO.timeIntervalSecs = Int16(sample.endDate.seconds(from: sample.startDate))
                                kmsMO.addToKmsTimeInterval(kmTimeIntervalMO)//addt (kmTimeIntervalMO)
                            }
                            if needSaveContext{
                                DBManager.sharedDBManager.saveContext()
                            }
                            //completion(true, nil)
                        }
                    }
                    self.hkHealthStore.execute(query)
                }else{
                    if needSaveContext {
                        DBManager.sharedDBManager.saveContext()
                    }
                }
            })
            completion()
        }
        self.hkHealthStore.execute(collectionQuery)
        
    }
    
    
}
 

extension Date {
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    
    static func getCurrentDateWithGMT0() -> Date {
        let currentDate = DateFormatter.localizedString(from: Date(), dateStyle: DateFormatter.Style.medium, timeStyle: DateFormatter.Style.none)
        
        return GlobalInfo.sharedGlobalInfo.dateFormatterWithGMT0.date(from: currentDate)!
    }
}
