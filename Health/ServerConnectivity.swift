 //
//  ServerConnectivity.swift
//  Health
//
//  Created by HW-Anil on 6/29/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit
import Alamofire

class ServerConnectivity: NSObject, XMLParserDelegate {
    var mutableData:NSMutableData  = NSMutableData()
    var currentElementName:NSString = ""
    var resultTagName = ""
    var methodName = ""
    
    var myClass:serverTaskComplete?
    typealias CompletionHandler = (_ success:Bool) -> Void

    
    
   // var object:protocol<serverTaskComplete> = ...
//   var myView: protocol< ,serverTaskComplete>
    
  
    
    
 /*   internal func callWebservice(_ dictParameters : Dictionary<String, String> , resulttagname : String , methodname : String , className : serverTaskComplete)  {
        resultTagName = resulttagname
        myClass = className
        methodName = methodname
        
        
        var soapURL = String(format:"<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><%@ xmlns='http://23.101.24.132/healthservice/webservice.asmx'>",methodName)
     //    var soapURL = String(format:"<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><%@ xmlns='http://23.101.24.132/HealthTest/webservice.asmx'>",methodName)
        
        for i in (0..<dictParameters.count) {
            let key = [String](dictParameters.keys)[i]
            var value : String!

            if methodname == "SaveRecord_New" && key == "recordString"{
                value = [String](dictParameters.values)[i]
            }else{
           // let value = [String](dictParameters.values)[i]
             value = AESEncryptionDecryption().EncryptAstring([String](dictParameters.values)[i])
            }
            let newParams = String(format: "<%@>%@</%@>",key,value,key)
            let newUrl = soapURL + newParams
            soapURL = newUrl
        }
        let endUrl = String(format:"<eType>I</eType></%@></soap12:Body></soap12:Envelope>",methodName)
        let finalSoapUrl = soapURL + endUrl
        
        let urlString = "http://23.101.24.132/healthservice/webservice.asmx"
      //  let urlString = "http://23.101.24.132/HealthTest/webservice.asmx"
        let url = URL(string: urlString)
        let theRequest = NSMutableURLRequest(url: url!)
        let msgLength = finalSoapUrl.characters.count
        
        theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        theRequest.addValue(String(msgLength), forHTTPHeaderField: "Content-Length")
        theRequest.httpMethod = "POST"
        if (methodName == "SaveRecord_New" || methodName == "GetRecordsFromServer") {
            theRequest.timeoutInterval = 300
        }else if (methodName == "SaveCorporateCustomer_V3") {
            theRequest.timeoutInterval = 100
        }else{
           theRequest.timeoutInterval = 30
        }
        
        theRequest.httpBody = finalSoapUrl.data(using: String.Encoding.utf8, allowLossyConversion: false) // or false
        let connection = NSURLConnection(request: theRequest as URLRequest, delegate: self, startImmediately: true)
       
        
        connection!.start()
        
//        if (connection == true) {
//            let mutableData : Void = NSMutableData.initialize()
//            
//        }
    
    } */
    
    
    
    
    func callWebservice(_ dictParameters : Dictionary<String, String> , resulttagname : String , methodname : String , className : serverTaskComplete){
        resultTagName = resulttagname
        myClass = className
        methodName = methodname
        var soapURL = String(format:"<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><%@ xmlns='http://23.101.24.132/healthservice/webservice.asmx'>",methodname)
        
        for i in (0..<dictParameters.count) {
            let key = [String](dictParameters.keys)[i]
            var value : String!
            
            if methodname == "SaveRecord_New" && key == "recordString"{
                value = [String](dictParameters.values)[i]
            }else{
                // let value = [String](dictParameters.values)[i]
                value = AESEncryptionDecryption().EncryptAstring([String](dictParameters.values)[i])
            }
            let newParams = String(format: "<%@>%@</%@>",key,value,key)
            let newUrl = soapURL + newParams
            soapURL = newUrl
        }
        
        let endUrl = String(format:"<eType>I</eType></%@></soap12:Body></soap12:Envelope>",methodname)
        let finalSoapUrl = soapURL + endUrl
        let msgLength = finalSoapUrl.characters.count
        
        do{
            var request = try URLRequest(url: URL(string: "http://23.101.24.132/healthservice/webservice.asmx")!, method: .post)
            request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.addValue(String(msgLength), forHTTPHeaderField: "Content-Length")
            request.httpBody = finalSoapUrl.data(using: String.Encoding.utf8, allowLossyConversion: false) // or false
            let _ = Alamofire.request(request)
                .responseData{ response in
                    /*        do{
                     
                     
                     //  let responseDict = try XMLReader.dictionary(forXMLString: result)
                     let responseDict = try XMLReader.dictionary(forXMLData: response.data!)
                     print(responseDict)
                     
                     var result = ""
                     let string = String(describing: responseDict)
                     if (self.methodName == "GetRecordsFromServer"){
                     
                     
                     result = string as AnyObject as! String
                     }else{
                     
                     result = AESEncryptionDecryption().DecryptAstring(string)
                     }
                     
                     print(result)
                     
                     
                     
                     var newString = ""
                     if self.methodName == "GetTestDetails" || self.methodName == "GetOrderInformation" {
                     newString = result.replacingOccurrences(of: "\r\n", with: "", options: NSString.CompareOptions.literal, range: nil)
                     }else{
                     newString = result.replacingOccurrences(of: "\n", with: "", options: NSString.CompareOptions.literal, range: nil)
                     }
                     
                     
                     
                     if (result .range(of: "[") != nil) {
                     print(result)
                     let json: AnyObject? = newString.parseJSONString
                     
                     print(json ?? "")
                     self.myClass!.getAllResponse(json!, methodName: self.methodName)
                     }else{
                     print("Simple stingn")
                     self.myClass!.getAllResponse(result as AnyObject, methodName: self.methodName)
                     }
                     
                     }catch{
                     print("Enable to Parse Data")
                     } */
                    
                    let xmlParser = XMLParser(data: response.data!)
                    xmlParser.delegate = self
                    xmlParser.parse()
                    xmlParser.shouldResolveExternalEntities = true
            }
            //                .responseJSON { response in
            //
            //
            //
            //
            //                    print(response.request)  // original URL request
            //                    print(response.response) // HTTP URL response
            //                    print(response.data)     // server data
            //                    print(response.result)   // result of response serialization
            //
            //                    if let JSON = response.result.value {
            //                        print("JSON: \(JSON)")
            //                    }
            //            }
            
            
        }catch{
            
        }
    }


    // MARK: - NSURLConnectionDeledate
   
    
//    func connection(_ connection: NSURLConnection!, didReceiveResponse response: URLResponse!) {
//        mutableData.length = 0;
//    }
//    
//    func connection(_ connection: NSURLConnection!, didReceiveData data: Data!) {
//        mutableData.append(data)
//    }
//    func connection(_ conn:NSURLConnection!, didFailWithError error:NSError!) {
//        
//        print(error)
//        
//        myClass!.getAllResponse("error" as AnyObject, methodName: methodName)
//        print("fail with error")
//       
//    }
//    
//    func connectionDidFinishLoading(_ connection: NSURLConnection!) {
//        let response = NSString(data: mutableData as Data, encoding: String.Encoding.utf8.rawValue)
//        
//        
//        let xmlParser = XMLParser(data: mutableData as Data)
//        xmlParser.delegate = self
//        xmlParser.parse()
//        xmlParser.shouldResolveExternalEntities = true
//    }
     // MARK: - XMLParserDelegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElementName = elementName as NSString
        
        if currentElementName == "soap:Fault" {
            let error : AnyObject = "Something went wrong. Please try again." as AnyObject
            myClass?.getAllResponse(error, methodName: methodName)
            
           
        }
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        
       print(methodName)
        
       
        if currentElementName as String == resultTagName {
            
            var result = ""
            
            if (methodName == "GetRecordsFromServer" || methodName == "GetReminders"){
                
                
                 result = string as AnyObject as! String
            }else{
                
                 result = AESEncryptionDecryption().DecryptAstring(string)
            }
            
            var newString = ""  //"GetOrderInformation"
            if methodName == "GetTestDetails" || methodName == "GetOrderInformation" {
            newString = result.replacingOccurrences(of: "\r\n", with: "", options: NSString.CompareOptions.literal, range: nil)
            }else{
             newString = result.replacingOccurrences(of: "\n", with: "", options: NSString.CompareOptions.literal, range: nil)
            }

           
            
            if (result .range(of: "[") != nil) {
                print(result)
                let json: AnyObject? = newString.parseJSONString
                myClass!.getAllResponse(json!, methodName: methodName)
            }else{
                print("Simple stingn")
                myClass!.getAllResponse(result as AnyObject, methodName: methodName)
            }
        }
        
    }
    
}


extension String
{
    var parseJSONString: AnyObject?
    {
        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        if let jsonData = data
        {
            // Will return an object or nil if JSON decoding fails
            do
            {
                let message = try JSONSerialization.jsonObject(with: jsonData, options:.mutableContainers)
                if let jsonResult = message as? NSMutableArray
                {
                    return jsonResult //Will return the json array output
                }
                else
                {
                    return nil
                }
            }
            catch let error as NSError
            {
                print("An error occurred: \(error)")
                return nil
            }
        }
        else
        {
            // Lossless conversion of the string was not possible
            return nil
        }
    }
}

