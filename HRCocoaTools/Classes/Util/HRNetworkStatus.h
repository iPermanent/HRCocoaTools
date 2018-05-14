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
    HRNetworkStatusTypeWifi  =   0,
    HRNetworkStatusType2G,
    HRNetworkStatusType3G,
    HRNetworkStatusType4G,
    HRNetworkStatusTypeNone
}HRNetworkStatusType;

@interface HRNetworkStatus : NSObject

@property(nonatomic,copy)void(^networkChangeBlock)(HRNetworkStatusType status);

+(HRNetworkStatus *)shareStatus;

-(HRNetworkStatusType)currentNetworkStatus;

@end
