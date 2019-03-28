//
//  HRBaseModel.h
//  HRCocoaTools
//
//  Created by zhangheng on 2019/3/28.
//

#import <Foundation/Foundation.h>

@protocol HRBaseModelParseProtocol <NSObject>

/*
 字段映射关系
 jsonKey:propertyName
 */
- (NSDictionary  * _Nullable )mapsDictionary;

/**
 数组类映射关系字典
 propertyName：className
 返回对应关系
 @return  对应字典
 */
- (NSDictionary * _Nullable )arrayClassDictiony;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HRBaseModel : NSObject <HRBaseModelParseProtocol>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)jsonDic;

@end

NS_ASSUME_NONNULL_END
