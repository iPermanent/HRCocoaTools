//
//  HRNetworkStatusType.m
//  KeyboardTest
//
//  Created by ZhangHeng on 15/4/27.
//  Copyright (c) 2015年 ZhangHeng. All rights reserved.
//

#import "HRNetworkStatus.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "Reachability.h"

static HRNetworkStatus *_status = nil;

@implementation HRNetworkStatus

+(HRNetworkStatus *)shareStatus {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _status = [HRNetworkStatus new];
    });
    
    return _status;
}

- (instancetype)init {
    self = [super init];
    if(self){
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    __weak typeof (HRNetworkStatus *) weakSelf = self;
    [NSNotificationCenter.defaultCenter addObserverForName:CTRadioAccessTechnologyDidChangeNotification
                                                    object:nil
                                                     queue:nil
                                                usingBlock:^(NSNotification *note){
                                                    //网络状态变化时的监听,需要时进行并发送通知
//                                                    CTTelephonyNetworkInfo *telephonyInfo = note.object;
                                                    HRNetworkStatusType status = [weakSelf currentNetworkStatus];
                                                    if(weakSelf.networkChangeBlock){
                                                        weakSelf.networkChangeBlock(status);
                                                    }
                                                }];
}

-(HRNetworkStatusType)currentNetworkStatus{
    HRNetworkStatusType retstatus;
    NetworkStatus   status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    switch (status) {
        case NotReachable:
            retstatus = HRNetworkStatusTypeNone;
            break;
        case ReachableViaWiFi:
            retstatus = HRNetworkStatusTypeWifi;
            break;
        case ReachableViaWWAN:{
            CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
            if([telephonyInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE])
                retstatus = HRNetworkStatusType4G;
            else if([telephonyInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS] || [telephonyInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] || [telephonyInfo.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD]){
                retstatus = HRNetworkStatusType2G;
            }else{
                retstatus = HRNetworkStatusType3G;
            }
        }
            break;
        default:
            break;
    }

    return retstatus;
}
@end
