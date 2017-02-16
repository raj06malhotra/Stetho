 //
//  ServerConnectivity.swift
//  Health
//
//  Created by HW-Anil on 6/29/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit

class ServerConnectivity: NSObject, XMLParserDelegate {
    var mutableData:NSMutableData  = NSMutableData()
    var currentElementName:NSString = ""
    var resultTagName = ""
    var methodName = ""
    
    var myClass:serverTaskComplete?
    typealias CompletionHandler = (_ success:Bool) -> Void

    
    
   // var object:protocol<serverTaskComplete> = ...
//   var myView: protocol< ,serverTaskComplete>
    
  
    
    
    internal func callWebservice(_ dictParameters : Dictionary<String, String> , resulttagname : String , methodname : String , className : serverTaskComplete)  {
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
    
    }
    
    
 /*   internal func callWebserviceForImageUploading(dictParameters : Dictionary<String, String> , resulttagname : String , methodname : String ,className : serverTaskComplete)  {
        
        
    /*    resultTagName = resulttagname
        myClass = className
        methodName = methodname
       
        
       
        
        var soapURL = String(format:"<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><%@ xmlns='http://23.101.24.132/healthservice_IOS/webservice.asmx'>",methodName)
        // var soapURL = String(format:"<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><%@ xmlns='http://23.101.24.132/healthservice_IOS/webservice.asmx'>",methodName)
        
        for i in (0..<dictParameters.count) {
            let key = [String](dictParameters.keys)[i]
            let value = [String](dictParameters.values)[i]
            let newParams = String(format: "<%@>%@</%@>",key,value,key)
            let newUrl = soapURL + newParams
            soapURL = newUrl
        }
        let endUrl = String(format:"<eType>I</eType></%@></soap12:Body></soap12:Envelope>",methodName)
        let finalSoapUrl = soapURL + endUrl
        
       // let urlString = "http://23.101.24.132/healthservice/webservice.asmx"
        let urlString = "http://23.101.24.132/healthservice_IOS/webservice.asmx"
        let url = NSURL(string: urlString)
        let theRequest = NSMutableURLRequest(URL: url!)
        let msgLength = finalSoapUrl.characters.count
        
        theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        theRequest.addValue(String(msgLength), forHTTPHeaderField: "Content-Length")
        theRequest.HTTPMethod = "POST"
        theRequest.timeoutInterval = 30
        theRequest.HTTPBody = finalSoapUrl.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) // or false
        
        let boundary = "---------------------------14737809831466499882746641449"
        let contentType = String(format: "multipart/form-data; boundary=%@",boundary)
        theRequest.addValue(contentType, forHTTPHeaderField: "Content-Type")
        let postbody = NSMutableData()
        postbody.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        postbody.appendData("Content-Disposition:form-data; name=\"test\";filename=\"anil.pdf\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        postbody.appendData("Content-Type:image/jpg\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        postbody.appendData(pdfData)
        postbody.appendData("\r\n--(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        theRequest.HTTPBody = postbody
        
        
        let session = NSURLSession.sharedSession()
        
        
        let task = session.dataTaskWithRequest(theRequest) {
            (
            let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
     
                return
            }
            
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
     
            
        }
        
        task.resume()
        
        
        //        let connection = NSURLConnection(request: theRequest, delegate: self, startImmediately: true)
        //        connection!.start()
        //
        //        if (connection == true) {
        //            let mutableData : Void = NSMutableData.initialize()
        //
        //        }  */
        
        
        
        
        
        
        resultTagName = resulttagname
        myClass = className
        methodName = methodname
        
        
        //  var soapURL = String(format:"<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><%@ xmlns='http://23.101.24.132/healthservice/webservice.asmx'>",methodName)
        var soapURL = String(format:"<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><%@ xmlns='http://23.101.24.132/healthservice_IOS/webservice.asmx'>",methodName)
        
        for i in (0..<dictParameters.count) {
            let key = [String](dictParameters.keys)[i]
            let value = [String](dictParameters.values)[i]
            let newParams = String(format: "<%@>%@</%@>",key,value,key)
            let newUrl = soapURL + newParams
            soapURL = newUrl
        }
        let endUrl = String(format:"<eType>I</eType></%@></soap12:Body></soap12:Envelope>",methodName)
        let finalSoapUrl = soapURL + endUrl
        
        //    let urlString = "http://23.101.24.132/healthservice/webservice.asmx"
        let urlString = "http://23.101.24.132/healthservice_IOS/webservice.asmx"
        let url = NSURL(string: urlString)
        let theRequest = NSMutableURLRequest(URL: url!)
        let msgLength = finalSoapUrl.characters.count
        
        theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        theRequest.addValue(String(msgLength), forHTTPHeaderField: "Content-Length")
        theRequest.HTTPMethod = "POST"
        theRequest.timeoutInterval = 60
        theRequest.HTTPBody = finalSoapUrl.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) // or false
        let connection = NSURLConnection(request: theRequest, delegate: self, startImmediately: true)
        connection!.start()
        
        if (connection == true) {
            
            
            let mutableData : Void = NSMutableData.initialize()
            
        }
    } */

    

    // MARK: - NSURLConnectionDeledate
   
    
    func connection(_ connection: NSURLConnection!, didReceiveResponse response: URLResponse!) {
        mutableData.length = 0;
    }
    
    func connection(_ connection: NSURLConnection!, didReceiveData data: Data!) {
        mutableData.append(data)
    }
    func connection(_ conn:NSURLConnection!, didFailWithError error:NSError!) {
        
        print(error)
        
        myClass!.getAllResponse("error" as AnyObject, methodName: methodName)
        print("fail with error")
       
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection!) {
        let response = NSString(data: mutableData as Data, encoding: String.Encoding.utf8.rawValue)
        
        
        let xmlParser = XMLParser(data: mutableData as Data)
        xmlParser.delegate = self
        xmlParser.parse()
        xmlParser.shouldResolveExternalEntities = true
    }
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
            
            if (methodName == "GetRecordsFromServer"){
                
                
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

