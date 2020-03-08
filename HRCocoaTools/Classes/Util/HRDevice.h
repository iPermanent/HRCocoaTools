//
//  HRDevice.h
//  HRCocoaTools
//
//  Created by ZhangHeng on 15/3/16.
//  Copyright (c) 2015年 ZhangHeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HRDevice : NSObject

//获取本机IP地址局域网内
+(NSString *)getLocalIPAddress;
+(NSString *)deviceName;
+(CGSize)getScreenSize;
+(CGFloat)getSystemFloatVersion;
+(NSString *)getSystemStringVersion;

@end
