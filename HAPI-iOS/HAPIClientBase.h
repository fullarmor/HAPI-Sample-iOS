//
//  HAPIClientBase.h
//  HAPI_iOS
//
//  Created by Scott Jackson on 3/23/15.
//  Copyright (c) 2015 FullArmor. All rights reserved.
//

#ifndef HAPI_iOS_HAPIClientBase_h
#define HAPI_iOS_HAPIClientBase_h

#import <Foundation/Foundation.h>

@interface HAPIClientBase : NSObject
@property (readwrite) NSURL * BaseURL;
@property (readwrite) NSString * Token;
@property (readwrite) NSString * UserSID;
@property (readwrite) NSString * EmailAddress;
@property (readwrite) NSArray  * cookies;
- (BOOL) Login:(NSString *)basesUrl userName:(NSString *)userName password:(NSString *)password;
- (NSData*) HttpPost:(NSString *)urlSuffix postDict:(NSMutableDictionary*) postDict;

@end


#endif
