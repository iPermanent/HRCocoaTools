//
//  HRApiClient.m
//  KeyboardTest
//
//  Created by ZhangHeng on 15/5/22.
//  Copyright (c) 2015年 ZhangHeng. All rights reserved.
//

#import "HRApiClient.h"
#import "Reachability.h"

@implementation HRApiClient

static HRApiClient *_sharedClient = nil;

#define SERVER_URL @"http://www.yoursite.com/interface"

+(id)sharedClient{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[HRApiClient alloc] initWithBaseURL:[NSURL URLWithString: SERVER_URL]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        NSMutableSet *set = [NSMutableSet setWithSet:_sharedClient.responseSerializer.acceptableContentTypes];
        [set addObject:@"text/html"];
        _sharedClient.responseSerializer.acceptableContentTypes = set;
    });
    
    return _sharedClient;
}

/*
 基本post方法
 */
-(NSURLSessionDataTask *)postPath:(NSString *)aPath parameters:(id)parameters completion:(ApiCompletion)aCompletion {
    NSArray *keys = [(NSMutableDictionary *)parameters allKeys];
    
    for(id key in keys){
        if([[parameters objectForKey:key] isKindOfClass:[NSString class]])
            [parameters setObject:[self getEncodeString:[parameters objectForKey:key]] forKey:key];
    }
    
    NSURLSessionDataTask *task = [self POST:aPath parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dic = responseObject;
        for(NSString *key in [dic allKeys]){
            NSLog(@"%@=%@",key,[responseObject objectForKey:key]);
        }
        if (aCompletion) {
            if([[responseObject objectForKey:@"success"] intValue] == 1)
                aCompletion(task, responseObject, nil);
            else{
                NSError *error = [[NSError alloc] initWithDomain:SERVER_URL code:-1 userInfo:responseObject];
                aCompletion(task,nil,error);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        Reachability *reach = [Reachability reachabilityForInternetConnection];
        if (![reach isReachable]) {
            //[SVProgressHUD showErrorWithStatus:@"网络请求中断，请检查网络" duration:1.5];
        }
        
        if (aCompletion) {
            aCompletion(task, nil, error);
        }
    }];
    
    return task;
}

/*
 带上传内容的post接口
 */
-(NSURLSessionDataTask *)postPath:(NSString *)aPath parameters:(id)parameters data:(NSData *)data completion:(ApiCompletion)aCompletion{
    NSArray *keys = [(NSMutableDictionary *)parameters allKeys];
    for(id key in keys){
        if([[parameters objectForKey:key] isKindOfClass:[NSString class]])
            [parameters setObject:[self getEncodeString:[parameters objectForKey:key]] forKey:key];
    }
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:[cookieJar cookies]
                                                       forURL:[NSURL URLWithString:SERVER_URL]
                                              mainDocumentURL:[[NSURL URLWithString:SERVER_URL] baseURL]];
    
    NSURLSessionDataTask *task = [self POST:aPath parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:@"images" mimeType:@"image/jpeg"];
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        if([[responseObject objectForKey:@"success"] intValue] == 1){
            if(aCompletion)
                aCompletion(task,responseObject,nil);
        }else{
            if(aCompletion){
                NSDictionary    *errorDic   =   [NSDictionary dictionaryWithObjectsAndKeys:[responseObject objectForKey:@"msg"],@"msg", nil];
                NSError *error = [NSError errorWithDomain:SERVER_URL code:-1 userInfo:errorDic];
                aCompletion(task,nil,error);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if(aCompletion)
            aCompletion(task,nil,error);
    }];
    
    return task;
}


//对中文字符反编码处理
-(NSString *)getEncodeString:(NSString *)baseString{
    NSString *percentString = [baseString stringByReplacingOccurrencesOfString:@"%" withString:@"%25"];
    NSString *andString = [percentString stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    NSString *enterString = [andString stringByReplacingOccurrencesOfString:@"\n" withString:@"%5Cn"];
    return [enterString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
}

@end
