//
//  NSURL+hrExt.m
//  AFNetworking
//
//  Created by ZhangHeng on 2018/1/28.
//

#import "NSURL+hrExt.h"

@implementation NSURL (hrExt)

- (void)parseUrl:(void (^)(NSString *domain, NSString *path, NSDictionary *params))completion{
    NSString    *domain = self.host;
    NSString    *fullPath = [[self.absoluteString stringByDeletingLastPathComponent] stringByReplacingOccurrencesOfString:domain withString:@""];
    
    NSMutableDictionary *param = @{}.mutableCopy;
    NSString *last = [self.absoluteString lastPathComponent];
    NSArray *array = [last componentsSeparatedByString:@"&"];
    [array enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *keyValue = [obj componentsSeparatedByString:@"="];
        if(keyValue.count == 2){
            [param setValue:keyValue[1] forKey:keyValue[0]];
        }
    }];
    
    if(completion){
        completion(domain,fullPath,param);
    }
}

@end
