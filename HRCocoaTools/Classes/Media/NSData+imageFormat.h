//
//  NSData+imageFormat.h
//
//  Created by zhangheng on 16/8/9.
//  Copyright © 2016年 ZhangHeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (imageFormat)

//简单的png和jpg,tiff等格式的判断
-(NSString *)contentTypeForImage;

//多种复杂图片的取值
-(NSString *)fullFormatTypeForImage;

@end
