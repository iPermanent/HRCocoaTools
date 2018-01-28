//
//  NSURL+hrExt.h
//  AFNetworking
//
//  Created by ZhangHeng on 2018/1/28.
//

#import <Foundation/Foundation.h>

@interface NSURL (hrExt)


/**
 解析get url里的参数 域名以及地址

 @param completion 回block
 */
- (void)parseUrl:(void(^)(NSString *domain,NSString *path,NSDictionary *params))completion;

@end
