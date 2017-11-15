//
//  StethoUpdateService.swift
//  Stetho Update
//
//  Created by Administrator on 08/08/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit
import Alamofire

class StethoUpdateService: NSObject {
    
    static let sharedService = StethoUpdateService()
    
    //Array<Any>
    //Dictionary<String, Any>?
    var getSuccessResponse:((_ responseStr: String?, _ responseArr: Array<Dictionary<String, Any>>?, _ methodName: String)->())?
    //  var getSucpricessResponseString:((_ responseStr: String, _ methodName: String)->())?
    var getFailureResponse:((_ response: String, _ methodName: String)->())?
    
    
    
    func hitService(dictInfo: Dictionary<String, String>, methodName: String){
        
        if !Reachability.isConnectedToNetwork(){
            self.getFailureResponse!("Please Check your Internet Connection.", methodName)
            return
        }
        //http://23.101.24.132/healthservicetest/webservice.asmx
        var soapURL = String(format:"<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><%@ xmlns='http://23.101.24.132/HealthTest/webservice.asmx'>",methodName)
        
        
        
       // "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><%@ xmlns='http://23.101.24.132/healthservice/webservice.asmx'>"
        for key in dictInfo.keys{
            var newParams: String!
//            let newParams = String(format: "<ACA_ID>57645</ACA_ID>")//,key,value!,key)//,key,value!,key)
            if methodName == "FetchStepSummaryIOS" || methodName == "SaveStepSummaryIOS" || methodName == "SaveWaterSummaryIOS" {
                newParams = String(format: "<%@>%@</%@>", key, dictInfo[key]!, key)
            }else{
                let value = AESEncryptionDecryption().EncryptAstring((dictInfo[key])!)
              //  let value = try! dictInfo[key]?.aesEncrypt(key: KENCRYPTIONKEY, iv: KENCRYPTIONKEY)
               newParams = String(format: "<%@>%@</%@>", key, value, key)
            }
            
             //let newParams = String(format: "<%@>%@</%@>", key, dictInfo[key]!, key)
            let newUrl = soapURL + newParams
            soapURL = newUrl
        }
        let endUrl = String(format:"<eType>I</eType></%@></soap12:Body></soap12:Envelope>",methodName)
        //<eType>I</eType>
        let finalSoapUrl = soapURL + endUrl
        let msgLength = finalSoapUrl.characters.count
        print(finalSoapUrl)
        do{
            let manager = Alamofire.SessionManager.default
            manager.session.configuration.timeoutIntervalForRequest = 30
            var request = try URLRequest(url: URL(string: "http://23.101.24.132/HealthTest/webservice.asmx")!, method: .post)
            request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.addValue(String(msgLength), forHTTPHeaderField: "Content-Length")
            request.httpBody = finalSoapUrl.data(using: String.Encoding.utf8, allowLossyConversion: true) // or false
            let _ = manager.request(request)
                .responseData{ response in
                    //  print(self.methodName)
                    print(response.data!)
                    
                    do {
                        let second = try XMLReader.dictionary(forXMLData: response.data!, options: 1)
                        let mainDict = self.getMainDict(dict: second as! Dictionary<String, Any>)
                      //  print(mainDict)
                        
                        if mainDict.keys.contains("Fault"){
                            self.getFailureResponse!("Something went wrong.", methodName)
                            return
                        }
                        
                        let responseData = mainDict[methodName + "Response"] as! Dictionary<String, Any>
                        let resultData = responseData[methodName + "Result"] as! Dictionary<String, Any>
                        
                        var responseStr = AESEncryptionDecryption().DecryptAstring(resultData["text"] as! String)//(try! (resultData["text"] as! String).aesDecrypt(key: KENCRYPTIONKEY, iv: KENCRYPTIONKEY))
                        
                        if responseStr == "0"{
                            self.getFailureResponse!(responseStr, methodName)
                        }else{
//                            if methodName == KGETORDERS_METHOD || methodName == KGETTESTDETAILS_METHOD{
//                                responseStr = responseStr.replacingOccurrences(of: "\r\n", with: "", options: NSString.CompareOptions.literal, range: nil)
//                            }else{
                                responseStr = responseStr.replacingOccurrences(of: "\n", with: "", options: NSString.CompareOptions.literal, range: nil)
//                            }
                            
                            
                            if responseStr.range(of: "[") == nil{
                                self.getSuccessResponse!(responseStr, nil, methodName)
                            }else{
                                let responseDict =   responseStr.parseJSONString
                                print(responseDict!)
                                if responseDict!.isKind(of: NSArray.self){
                                    
                                    self.getSuccessResponse?(nil, responseDict as? Array<Dictionary<String, Any>>, methodName)
                                }else{
                                    self.getSuccessResponse!(responseStr, nil, methodName)
                                }
                            }
                            /*
                             if let responseDict = GlobalInfo.sharedGlobalInfo.convertToDictionary(text: responseStr){
                             self.getSuccessResponse!(nil, responseDict, methodName)
                             print(responseDict)
                             //   self.getSuccessResponseDict!(responseDict, methodName)
                             }else{
                             self.getSuccessResponse!(responseStr, nil, methodName)
                             
                             // self.getSuccessResponseString!(responseStr, methodName)
                             }*/
                        }
                    } catch _ {
                        
                    }
            }
            
        }catch{
            
        }
    }
    
    func getMainDict(dict: Dictionary<String, Any>) -> Dictionary<String, Any>{
        let envelope = dict["Envelope"] as! Dictionary<String, Any>
        let body = envelope["Body"] as! Dictionary<String, Any>
        return body
    }
    
}
