//
//  HAPIClientBase.m
//  HAPI_iOS
//
//  Created by Scott Jackson on 3/30/15.
//  Copyright (c) 2015 FullArmor. All rights reserved.
//

#import <Foundation/Foundation.h>


//
//  HAPIClient.m
//  HAPI_iOS
//
//  Created by Scott Jackson on 3/23/15.
//  Copyright (c) 2015 FullArmor. All rights reserved.
//

#import "HAPIClientBase.h"

@implementation NSURLRequest (IgnoreSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
    
    /*if( [host  isEqual: @"sandbox.fullarmorhapi.com"])
        return YES;
    
    return NO;*/
}

@end


@implementation HAPIClientBase


- (BOOL) Login:(NSString *)serverUrl userName:(NSString *)userName password:(NSString *)password
{
    self.BaseURL = [[NSURL alloc] initWithString:serverUrl];
    
    NSString * serverURL = [NSString stringWithFormat:@"%@/%s", self.BaseURL, "route/hapi/login"];
    
    NSMutableDictionary *postDict = [NSMutableDictionary dictionary];
    [postDict setValue:userName forKey:@"UserName"];
    [postDict setValue:password forKey:@"Password"];
    
    NSError *error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:postDict options:kNilOptions error:&error];
    NSURLResponse *response;
    NSData *localData = nil;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serverURL]];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonData];
    
    // Send the request and get the response
    localData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    // Cookies
    self.cookies = [[ NSHTTPCookieStorage sharedHTTPCookieStorage ]
                    cookiesForURL: self.BaseURL ];
    
    NSString *result = [[NSString alloc] initWithData:localData encoding:NSASCIIStringEncoding];
    NSLog(@"Post result : %@", result);
    
    NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary* resultDict = [NSJSONSerialization JSONObjectWithData:data
                                                               options:kNilOptions
                                                                 error:&error];
   
    NSNumber * isSuccessNumber = (NSNumber *)[resultDict objectForKey: @"Success"];
    if([isSuccessNumber boolValue] == YES)
    {
        self.Token = [resultDict objectForKey:@"Token"];
        self.UserSID = [resultDict objectForKey:@"UserSID"];
        self.EmailAddress = [resultDict objectForKey:@"EmailAddress"];
        return true;
    }
    else
        return false;
}

- (NSData*) HttpPost:(NSString *)urlSuffix postDict:(NSMutableDictionary*) postDict
{
    NSString * serverURL = [NSString stringWithFormat:@"%@/%@", self.BaseURL, urlSuffix];
    NSLog(@"%@", serverURL);
    
    NSString * gwToken = [self.cookies containsObject:@"GW_HAPITokenid"] ? [self.cookies valueForKey:@"GW_HAPIToken"] :@"";
    NSString * gwSPToken = [self.cookies containsObject:@"GW_DefaultSPSite"] ? [self.cookies valueForKey:@"GW_DefaultSPSite"] :@"";
    
    
    [postDict setValue:self.Token forKey:@"HAPIToken"];
    [postDict setValue:gwToken forKey:@"GW_HAPIToken"];
    [postDict setValue:gwSPToken forKey:@"GW_DefaultSPSite"];
    
    NSError *error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:postDict options:kNilOptions error:&error];
    NSURLResponse *response;
    NSData *localData = nil;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serverURL]];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonData];
    
    // Send the request and get the response
    localData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    // Cookies
    self.cookies = [[ NSHTTPCookieStorage sharedHTTPCookieStorage ]
                    cookiesForURL: self.BaseURL ];
    
    NSString *result = [[NSString alloc] initWithData:localData encoding:NSASCIIStringEncoding];
    
    NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
    
    return data;
}

@end