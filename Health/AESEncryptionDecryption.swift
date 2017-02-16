//
//  AESEncryptionDecryption.swift
//  Health
//
//  Created by HW-Anil on 6/27/16.
//  Copyright © 2016 Hindustan Wellness. All rights reserved.
//

import UIKit
let password = "78AZet%@/*5A"

class AESEncryptionDecryption: NSObject {
    
    internal  func EncryptAstring(_ myString : String) -> String {
        // Encryption
        let string = myString
        let data: Data = string.data(using: String.Encoding.utf8)!
        let ciphertext = RNCryptor.encrypt(data: data as Data, withPassword: password)
        //let ciphertext = RNCryptor.encryptData(data: data as NSData, password: password)
        let myBase64String = ciphertext.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0));
//        let cfStr:CFString = myBase64String
//        let nsTypeString = cfStr as NSString
//        let swiftString:String = nsTypeString as String

        
        
        return myBase64String
    }
    
    internal  func DecryptAstring(_ encryptedString : String) -> String {
        // Decryption
        do {
            let decodedData = Data(base64Encoded: encryptedString, options: NSData.Base64DecodingOptions(rawValue: 0))
            if decodedData == nil {
             return "error"
            }
            let originalData = try RNCryptor.decrypt(data: decodedData! as Data, withPassword: password)
            //let originalData = try RNCryptor.decryptData(data: decodedData! as NSData, password: password)
            let decodedString = NSString(data: originalData as Data, encoding: String.Encoding.utf8.rawValue)
            return decodedString! as String
            // ...
        } catch {
            print(error)
            return "error"
        }
       
        }

}
