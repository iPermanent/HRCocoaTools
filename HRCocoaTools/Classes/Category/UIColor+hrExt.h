//
//  UIColor+hrExt.h
//  HRCocoaTools
//
//  Created by zhangheng1 on 2018/5/14.
//

#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue,A) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:A]

@interface UIColor (hrExt)

/**
 *  @author Henry
 *
 *  通过#RRGGBBAA这样的格式获取颜色,AA为空则默认为1
 *
 *  @param colorString #RRGGBBAA
 *
 *  @return UIColor
 */
+(UIColor *)getColorFromString:(NSString *)colorString;

/**
 取色值
 
 @param hex 0xffffff 格式
 @return 颜色
 */
+ (UIColor *)colorWithHex:(NSUInteger )hex;
+ (UIColor *)colorWithHex:(NSUInteger )hex alpha:(CGFloat )alpha;

@end
