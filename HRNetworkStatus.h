//
//  HRNetworkStatus.h
//  KeyboardTest
//
//  Created by ZhangHeng on 15/4/27.
//  Copyright (c) 2015年 ZhangHeng. All rights reserved.
//

/*
 需要依赖Reahability，并且导入coreTelephone框架
 仅支持7.0以上版本
 */
#import <Foundation/Foundation.h>

typedef enum{
    HRNetworkStatusWifi  =   0,
    HRNetworkStatus2G,
    HRNetworkStatus3G,
    HRNetworkStatus4G,
    HRNetworkStatusNone
}HRNetworkType;

@interface HRNetworkStatus : NSObject

+(HRNetworkStatus *)shareMonitor;

+(HRNetworkType)currentNetworkStatus;

@end
