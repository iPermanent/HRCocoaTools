//
//  HRApiClient.h
//  KeyboardTest
//
//  Created by ZhangHeng on 15/5/22.
//  Copyright (c) 2015年 ZhangHeng. All rights reserved.
//

#import "AFHTTPSessionManager.h"

typedef void(^ApiCompletion)(NSURLSessionDataTask *task, NSDictionary *aResponse, NSError* anError);

@interface HRApiClient : AFHTTPSessionManager

+(id)sharedClient;

/*
 基本post方法
 */
-(NSURLSessionDataTask *)postPath:(NSString *)aPath parameters:(id)parameters completion:(ApiCompletion)aCompletion;

/*
 带上传内容的post接口
 */
-(NSURLSessionDataTask *)postPath:(NSString *)aPath parameters:(id)parameters data:(NSData *)data completion:(ApiCompletion)aCompletion;

@end
