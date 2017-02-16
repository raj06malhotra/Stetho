//
//  MRMSiOS.h
//  MRMSiOS
//
//  Created by Anoop Valluthadam on 17/11/14.
//  Copyright (c) 2014 MerchantRMS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
@import AdSupport;

@interface MRMSDevFPiOS : NSObject {
    NSString *deviceAPIURL;
}

- (id)init;
- (id)initWithDemo:(bool)useDemo;
- (NSString *)createSession;
- (NSDictionary *)callDeviceAPIwithParameters:(NSDictionary *)params;

@end
