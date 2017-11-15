//
//  GlobalInfo.swift
//  Stetho Update
//
//  Created by Administrator on 16/05/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class GlobalInfo2: NSObject {
    
   /* func setNavigationBarTintColor(){
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 18.0), NSForegroundColorAttributeName: KAPPCOLOR]
        self.navigationController?.navigationBar.tintColor = KAPPCOLOR
    }*/
    static let sharedGlobalInfo2 = GlobalInfo2()
    let dateFormatterWithGMT0: DateFormatter!
    let localDateFormatter_dd_MMM_yyyy: DateFormatter!
   
    private override init() {
        //dateFormatterWithGMT0.dateFormat = ""
        dateFormatterWithGMT0 = DateFormatter()
        localDateFormatter_dd_MMM_yyyy = DateFormatter()
        dateFormatterWithGMT0.dateFormat = "yyyy-MM-dd"//"dd-MMM-yyyy"
        localDateFormatter_dd_MMM_yyyy.dateFormat = "yyyy-MM-dd"//"yyyy-MMM-dd"
        localDateFormatter_dd_MMM_yyyy.timeZone = NSTimeZone.local
        dateFormatterWithGMT0.timeZone = TimeZone(secondsFromGMT: 0)
    }
    
    func pushtoHome(){
        
    }

}

extension String {
    
    var parseJSONString: AnyObject?
    {
        let data = self.data(using: .utf8)
        if let jsonData = data
        {
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
    
    func aesEncrypt(key: String, iv: String) throws -> String {
        let data = self.data(using: .utf8)!
        let encrypted = try! AES(key: key, iv: iv, blockMode: .CBC, padding: PKCS7()).encrypt([UInt8](data))
        let encryptedData = Data(encrypted)
        return encryptedData.base64EncodedString()
    }
    
    func aesDecrypt(key: String, iv: String) throws -> String {
        let data = Data(base64Encoded: self)!
        let decrypted = try! AES(key: key, iv: iv, blockMode: .CBC, padding: PKCS7()).decrypt([UInt8](data))
        let decryptedData = Data(decrypted)
        return String(bytes: decryptedData.bytes, encoding: .utf8) ?? "Could not decrypt"
    }
}
