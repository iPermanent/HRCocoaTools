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

//static HRDevice     *instance = nil;
@implementation HRDevice

+(HRDeviceType)getCurrentDeviceType{
    NSString *platForm = [self deviceModel];
    
    if([platForm isEqualToString:@"iPhone1,1"]){
        return HRDeviceTypeiPhone;
    }else if([platForm isEqualToString:@"iPhone1,2"]){
        return HRDeviceTypeiPhone3G;
    }else if([platForm isEqualToString:@"iPhone2,1"]){
        return HRDeviceTypeiPhone3GS;
    }else if([platForm hasPrefix:@"iPhone3"]){
        //3.3 is Version iPhone that support CDMA
        return HRDeviceTypeiPhone4;
    }else if([platForm isEqualToString:@"iPhone4,1"]){
        return HRDeviceTypeiPhone4S;
    }else if([platForm isEqualToString:@"iPhone5,1"] || [platForm isEqualToString:@"iPhone5,2"]){
        //5,2 is CDMA version
        return HRDeviceTypeiPhone5;
    }else if([platForm isEqualToString:@"iPhone5,3"] || [platForm isEqualToString:@"iPhone5,4"]){
        //5,3 CDMA & WCDMA,  5,4 is TD
        return HRDeviceTypeiPhone5c;
    }else if([platForm hasPrefix:@"iPhone6"]){
        //6,1 is CDMA and 6,2 is global
        return HRDeviceTypeiPhone5S;
    }else if([platForm isEqualToString:@"iPhone7,2"]){
        return HRDeviceTypeiPhone6;
    }else if([platForm isEqualToString:@"iPhone7,1"]){
        return HRDeviceTypeiPhone6Plus;
    }else if([platForm isEqualToString:@"iPhone8,1"]){
        return HRDeviceTypeiPhone6s;
    }else if([platForm isEqualToString:@"iPhone8,2"]){
        return HRDeviceTypeiPhone6sPlus;
    }else if([platForm isEqualToString:@"iPad1,1"]){
        return HRDeviceTypeiPad1;
    }else if([platForm isEqualToString:@"iPad2,1"] || [platForm isEqualToString:@"iPad2,2"] || [platForm isEqualToString:@"iPad2,3"]){
        //2,2 is GSM and 2,1 is CDMA
        return HRDeviceTypeiPad2;
    }else if([platForm isEqualToString:@"iPad3,1"] || [platForm isEqualToString:@"iPad3,2"] || [platForm isEqualToString:@"iPad3,3"]){
        return HRDeviceTypeiPad3;
    }else if([platForm isEqualToString:@"iPad3,4"] || [platForm isEqualToString:@"iPad3,5"] || [platForm isEqualToString:@"iPad3,6"]){
        return HRDeviceTypeiPad4;
    }else if([platForm isEqualToString:@"iPad2,5"] || [platForm isEqualToString:@"iPad2,6"] || [platForm isEqualToString:@"iPad2,7"]){
        return HRDeviceTypeiPadMini;
    }else if([platForm isEqualToString:@"iPad4,4"] || [platForm isEqualToString:@"iPad4,5"] || [platForm isEqualToString:@"iPad4,6"]){
        return HRDeviceTypeiPadMini2;
    }else if([platForm isEqualToString:@"iPad4,7"] || [platForm isEqualToString:@"iPad4,8"] || [platForm isEqualToString:@"iPad4,9"]){
        return HRDeviceTypeiPadMini3;
    }else if([platForm isEqualToString:@"iPad4,1"] || [platForm isEqualToString:@"iPad4,2"] || [platForm isEqualToString:@"iPad4,3"]){
        return HRDeviceTypeiPadAir;
    }else if([platForm isEqualToString:@"iPad5,1"] || [platForm isEqualToString:@"iPad5,2"] || [platForm isEqualToString:@"iPad5,3"]){
        return HRDeviceTypeiPadAir2;
    }else if ([platForm hasPrefix:@"iPod"]){
        return HRDeviceTypeiPod;
    }else{
        //Xcode 6及以后模拟器为x86_64，之前版本为iPhone simulator之类
        if([platForm isEqualToString:@"x86_64"]){
            return HRDeviceTypeSimulator;
        }
    }
    
    return HRDeviceTypeiPhone;
}

+ (NSString *)deviceName {
    return [[self nameEnumDic] valueForKey:@([self getCurrentDeviceType]).stringValue];
}

+(NSDictionary *)nameEnumDic{
    NSMutableDictionary *enumDic = [NSMutableDictionary new];
    NSArray *nameArray = @[@"iPhone",@"iPhone 3G",@"iPhone 3GS",@"iPhone 4",@"iPhone 4S",@"iPhone 5",@"iPhone 5c",@"iPhone 5s",@"iPhone 6",@"iPhone 6 Plus",@"iPhone 6s",@"iPhone 6s Plus",@"iPad 1",@"iPad 2",@"iPad 3",@"iPad 4",@"iPad Air",@"iPad Air2",@"iPad mini",@"iPad mini2",@"iPad mini3",@"iPod",@"iPhone Simulator"];
    for(int i=0;i<22;i++){
        [enumDic setObject:nameArray[i] forKey:@(i).stringValue];
    }

    return enumDic;
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

@end
