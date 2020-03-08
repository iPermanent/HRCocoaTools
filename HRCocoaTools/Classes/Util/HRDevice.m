//
//  HRDevice.m
//  HRCocoaTools
//
//  Created by ZhangHeng on 15/3/16.
//  Copyright (c) 2015年 ZhangHeng. All rights reserved.
//

#import "HRDevice.h"
#import <sys/utsname.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

static NSDictionary *deviceTypeStaticDic = nil;

//static HRDevice     *instance = nil;
@implementation HRDevice

+ (NSString *)deviceName {
    return [[self modelTypeMaps] valueForKey:[self deviceModel]];
}

//获取本机本地IP
+(NSString *)getLocalIPAddress{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}


+(NSString *)getSystemStringVersion{
    return [[UIDevice currentDevice] systemVersion];
}

+(CGFloat)getSystemFloatVersion{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+(CGSize)getScreenSize{
    return [UIScreen mainScreen].bounds.size;
}

+(NSString *)deviceModel
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return platform;
}

+ (NSDictionary *)modelTypeMaps {
    NSMutableDictionary *typeDics = [NSMutableDictionary new];
    
    NSArray *types = [[self modelListConfig] componentsSeparatedByString:@"\n"];
    for(NSString *typeUnit in types) {
        NSArray *keyAndValue = [typeUnit componentsSeparatedByString:@":"];
        NSString *modelName = keyAndValue[0];
        NSString *modelDisplayName = keyAndValue[1];
        
        [typeDics setValue:modelDisplayName forKey:modelName];
    }
    
    return typeDics.copy;
}

+ (NSString *)modelListConfig {
    return @"i386:iPhone Simulator\nx86_64:iPhone Simulator\niPhone1,1:iPhone\niPhone1,2:iPhone 3G\niPhone2,1:iPhone 3GS\niPhone3,1:iPhone 4\niPhone3,2:iPhone 4 GSM Rev A\niPhone3,3:iPhone 4 CDMA\niPhone4,1:iPhone 4S\niPhone5,1:iPhone 5 (GSM)\niPhone5,2 :\n iPhone 5 (GSM+CDMA)iPhone5,3:iPhone 5C (GSM)\niPhone5,4:iPhone 5C (Global)\niPhone6,1:iPhone 5S (GSM)\niPhone6,2:iPhone 5S (Global)\niPhone7,1:iPhone 6 Plus\niPhone7,2:iPhone 6\niPhone8,1:iPhone 6s\niPhone8,2:iPhone 6s Plus\niPhone8,4:iPhone SE (GSM)\niPhone9,1:iPhone 7\niPhone9,2:iPhone 7 Plus\niPhone9,3:iPhone 7\niPhone9,4:iPhone 7 Plus\niPhone10,1:iPhone 8\niPhone10,2:iPhone 8 Plus\niPhone10,3:iPhone X Global\niPhone10,4:iPhone 8\niPhone10,5:iPhone 8 Plus\niPhone10,6:iPhone X GSM\niPhone11,2:iPhone XS\niPhone11,4:iPhone XS Max\niPhone11,6:iPhone XS Max Global\niPhone11,8:iPhone XR\niPhone12,1:iPhone 11\niPhone12,3:iPhone 11 Pro\niPhone12,5:iPhone 11 Pro Max\niPod1,1:1st Gen iPod\niPod2,1:2nd Gen iPod\niPod3,1:3rd Gen iPod\niPod4,1:4th Gen iPod\niPod5,1:5th Gen iPod\niPod7,1:6th Gen iPod\niPod9,1:7th Gen iPod\niPad1,1:iPad\niPad1,2:iPad 3G\niPad2,1:2nd Gen iPad\niPad2,2:2nd Gen iPad GSM\niPad2,3:2nd Gen iPad CDMA\niPad2,4:2nd Gen iPad New Revision\niPad3,1:3rd Gen iPad\niPad3,2:3rd Gen iPad CDMA\niPad3,3:3rd Gen iPad GSM\niPad2,5:iPad mini\niPad2,6:iPad mini GSM+LTE\niPad2,7:iPad mini CDMA+LTE\niPad3,4:4th Gen iPad\niPad3,5:4th Gen iPad GSM+LTE\niPad3,6:4th Gen iPad CDMA+LTE\niPad4,1:iPad Air (WiFi)\niPad4,2:iPad Air (GSM+CDMA)\niPad4,3:1st Gen iPad Air (China)\niPad4,4:iPad mini Retina (WiFi)\niPad4,5:iPad mini Retina (GSM+CDMA)\niPad4,6:iPad mini Retina (China)\niPad4,7:iPad mini 3 (WiFi)\niPad4,8:iPad mini 3 (GSM+CDMA)\niPad4,9:iPad Mini 3 (China)\niPad5,1:iPad mini 4 (WiFi)\niPad5,2:4th Gen iPad mini (WiFi+Cellular)\niPad5,3:iPad Air 2 (WiFi)\niPad5,4:iPad Air 2 (Cellular)\niPad6,3:iPad Pro (9.7 inch, WiFi)\niPad6,4:iPad Pro (9.7 inch, WiFi+LTE)\niPad6,7:iPad Pro (12.9 inch, WiFi)\niPad6,8:iPad Pro (12.9 inch, WiFi+LTE)\niPad6,11:iPad (2017)\niPad6,12:iPad (2017)\niPad7,1:iPad Pro 2nd Gen (WiFi)\niPad7,2:iPad Pro 2nd Gen (WiFi+Cellular)\niPad7,3:iPad Pro 10.5-inch\niPad7,4:iPad Pro 10.5-inch\niPad7,5:iPad 6th Gen (WiFi)\niPad7,6:iPad 6th Gen (WiFi+Cellular)\niPad7,11:iPad 7th Gen 10.2-inch (WiFi)\niPad7,12:iPad 7th Gen 10.2-inch (WiFi+Cellular)\niPad8,1:iPad Pro 3rd Gen (11 inch, WiFi)\niPad8,2:iPad Pro 3rd Gen (11 inch, 1TB, WiFi)\niPad8,3:iPad Pro 3rd Gen (11 inch, WiFi+Cellular)\niPad8,4:iPad Pro 3rd Gen (11 inch, 1TB, WiFi+Cellular)\niPad8,5:iPad Pro 3rd Gen (12.9 inch, WiFi)\niPad8,6:iPad Pro 3rd Gen (12.9 inch, 1TB, WiFi)\niPad8,7:iPad Pro 3rd Gen (12.9 inch, WiFi+Cellular)\niPad8,8:iPad Pro 3rd Gen (12.9 inch, 1TB, WiFi+Cellular)\niPad11,1:iPad mini 5th Gen (WiFi)\niPad11,2:iPad mini 5th Gen\niPad11,3:iPad Air 3rd Gen (WiFi)\niPad11,4:iPad Air 3rd Gen\nWatch1,1:Apple Watch 38mm case\nWatch1,2:Apple Watch 42mm case\nWatch2,6:Apple Watch Series 1 38mm case\nWatch2,7:Apple Watch Series 1 42mm case\nWatch2,3:Apple Watch Series 2 38mm case\nWatch2,4:Apple Watch Series 2 42mm case\nWatch3,1:Apple Watch Series 3 38mm case (GPS+Cellular)\nWatch3,2:Apple Watch Series 3 42mm case (GPS+Cellular)\nWatch3,3:Apple Watch Series 3 38mm case (GPS)\nWatch3,4:Apple Watch Series 3 42mm case (GPS)\nWatch4,1:Apple Watch Series 4 40mm case (GPS)\nWatch4,2:Apple Watch Series 4 44mm case (GPS)\nWatch4,3:Apple Watch Series 4 40mm case (GPS+Cellular)\nWatch4,4:Apple Watch Series 4 44mm case (GPS+Cellular)\nWatch5,1:Apple Watch Series 5 40mm case (GPS)\nWatch5,2:Apple Watch Series 5 44mm case (GPS)\nWatch5,3:Apple Watch Series 5 40mm case (GPS+Cellular)\nWatch5,4:Apple Watch Series 5 44mm case (GPS+Cellular)";
}

@end
