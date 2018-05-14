//
//  NSFileManager+hrExt.m
//  HRCocoaTools
//
//  Created by ZhangHeng on 2018/1/28.
//

#import "NSFileManager+hrExt.h"

@implementation NSFileManager (hrExt)

- (NSString *)documentDir {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}

- (NSString *)cacheDir {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
}

- (NSString *)tempDir {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
}

@end
