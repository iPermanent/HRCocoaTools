//
//  HRDevice.h
//  HRCocoaTools
//
//  Created by ZhangHeng on 15/3/16.
//  Copyright (c) 2015年 ZhangHeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HRDeviceType){
    HRDeviceTypeiPhone  =   0,
    HRDeviceTypeiPhone3G,
    HRDeviceTypeiPhone3GS,
    HRDeviceTypeiPhone4,
    HRDeviceTypeiPhone4S,
    HRDeviceTypeiPhone5,
    HRDeviceTypeiPhone5c,
    HRDeviceTypeiPhone5S,
    HRDeviceTypeiPhone6,
    HRDeviceTypeiPhone6Plus,
    HRDeviceTypeiPhone6s,
    HRDeviceTypeiPhone6sPlus,
    HRDeviceTypeiPad1,
    HRDeviceTypeiPad2,
    HRDeviceTypeiPad3,
    HRDeviceTypeiPad4,
    HRDeviceTypeiPadAir,
    HRDeviceTypeiPadAir2,
    HRDeviceTypeiPadMini,
    HRDeviceTypeiPadMini2,
    HRDeviceTypeiPadMini3,
    HRDeviceTypeiPod,
    HRDeviceTypeSimulator
};

@interface HRDevice : NSObject

+(HRDeviceType)getCurrentDeviceType;
//获取本机IP地址局域网内
+(NSString *)getLocalIPAddress;
+(NSString *)deviceName;
+(CGSize)getScreenSize;
+(CGFloat)getSystemFloatVersion;
+(NSString *)getSystemStringVersion;

@end
