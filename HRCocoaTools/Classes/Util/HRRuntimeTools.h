//
//  HRRuntimeTools.h
//  HRCocoaTools
//
//  Created by Henry Zhang on 2021/6/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HRRuntimeTools : NSObject
 

/// 获取加载到的所有类，通过父类和协议筛选
/// @param superClass 指定的父类
/// @param protocol 需要实现协议
+ (NSArray <NSString *>*)loadedClassNames:(Class _Nullable)superClass
                        conformsToProtocol:(Protocol* _Nullable)protocol;

@end

NS_ASSUME_NONNULL_END
