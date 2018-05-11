//
//  HRNetworkStatus.m
//  KeyboardTest
//
//  Created by ZhangHeng on 15/4/27.
//  Copyright (c) 2015年 ZhangHeng. All rights reserved.
//

#import "HRNetworkStatus.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "Reachability.h"

@implementation HRNetworkStatus

+(HRNetworkType)currentNetworkStatus{
    HRNetworkType retstatus;
    NetworkStatus   status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    switch (status) {
        case NotReachable:
            retstatus = HRNetworkStatusNone;
            break;
        case ReachableViaWiFi:
            retstatus = HRNetworkStatusWifi;
            break;
        case ReachableViaWWAN:{
            CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
            if([telephonyInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE])
                retstatus = HRNetworkStatus4G;
            else if([telephonyInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS] || [telephonyInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] || [telephonyInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD]){
                retstatus = HRNetworkStatus2G;
            }else{
                retstatus = HRNetworkStatus3G;
            }
           
            [NSNotificationCenter.defaultCenter addObserverForName:CTRadioAccessTechnologyDidChangeNotification
                                                            object:nil
                                                             queue:nil
                                                        usingBlock:^(NSNotification *note)
             {
                 //网络状态变化时的监听,需要时进行并发送通知
                 NSLog(@"New Radio Access Technology: %@", telephonyInfo.currentRadioAccessTechnology);
             }];
        }
            break;
        default:
            break;
    }

    return retstatus;
}
@end
