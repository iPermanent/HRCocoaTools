//
//  NSString+Util.h
//  HRCocoaTools
//
//  Created by ZhangHeng on 15/12/31.
//  Copyright © 2015年 ZhangHeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Util)

/**
 *  @author Henry
 *
 *  检查字符串是否包含中文字符
 *
 *  @return 是否包含中文
 */
-(BOOL)stringContainsChinesCharacters;


/**
 转换为拼音输出

 @return 拼音字符串
 */
- (NSString *)transformToPinyin;

/**
 *  @author Henry
 *
 *  获取中文字符串在字符串中的位置
 *
 *  @return 返回中文位置索引的数组,使用RangeMake()即可取到值
 */
-(NSArray *)getChineseCharacterRanges;

/**
 *  @author Henry
 *
 *  获取字符串中所有的中文字符
 *
 *  @return 中文字符数组
 */
-(NSArray *)getChineseCharactersContains;

/**
 *  @author Henry
 *
 *  检测文字内容是否含有emoji表情
 *
 *  @return 是否含有
 */
-(BOOL)stringContainsEmoji;

#pragma mark 加密部分
- (NSString *) md5;

- (NSString *) sha1;

- (NSString *) sha1_base64;

- (NSString *) md5_base64;

- (NSString *) base64;

- (NSString *) decodeBase64String;

- (NSString *) SHA256;

- (NSString *) hmacSHA256WithKey:(NSString *)key;

@end
