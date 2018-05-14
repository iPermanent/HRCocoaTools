//
//  NSFileManager+hrExt.h
//  HRCocoaTools
//
//  Created by ZhangHeng on 2018/1/28.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (hrExt)

- (NSString *)documentDir;

- (NSString *)cacheDir;

- (NSString *)tempDir;

@end
