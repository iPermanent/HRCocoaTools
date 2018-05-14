//
//  UIColor+hrExt.m
//  HRCocoaTools
//
//  Created by zhangheng1 on 2018/5/14.
//

#import "UIColor+hrExt.h"

@implementation UIColor (hrExt)

+ (UIColor *)colorWithHex:(NSUInteger)hex {
    return [UIColor colorWithRed:((hex>>16)&0xff)/255.0 green:((hex>>8)&0xff)/255.0 blue:(hex&0xff)/255.0 alpha:1];
}

+ (UIColor *)colorWithHex:(NSUInteger)hex alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:((hex>>16)&0xff)/255.0 green:((hex>>8)&0xff)/255.0 blue:(hex&0xff)/255.0 alpha:alpha];
}

+(UIColor *)getColorFromString:(NSString *)colorString {
    long x;
    NSString *_str;
    //如果是八位
    if([colorString length] == 9){
        //取前两位alpha值
        NSString *alpha = [colorString substringToIndex:3];
        
        //取后面的几位颜色值
        NSString *color = [colorString substringFromIndex:3];
        const char *cStr = [color cStringUsingEncoding:NSASCIIStringEncoding];
        x = strtol(cStr+1, NULL, 16);
        //_str = [NSString stringWithFormat:@"#%@",color];
        
        return [self colorWithHex:(UInt32)x withAlpha:alpha];
    }
    //如果是6位的颜色
    else if([colorString length] == 7){
        const char *cStr = [colorString cStringUsingEncoding:NSASCIIStringEncoding];
        x = strtol(cStr+1, NULL, 16);
        _str = @"#FF";
    }
    //如果格式不对就直接返回黑色颜色
    else
        return [UIColor blackColor];
    return [self colorWithHex:(UInt32)x withAlpha:_str];
}

+(UIColor *)colorWithHex:(UInt32)col withAlpha:(NSString*)alphaStr {
    unsigned int r, g, b;
    b = col & 0xFF;
    g = (col >> 8) & 0xFF;
    r = (col >> 16) & 0xFF;
    
    const char* aStr = [alphaStr cStringUsingEncoding:NSASCIIStringEncoding];
    long value = strtol(aStr+1, NULL, 16);
    CGFloat _alpha = (float)(value & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:_alpha];
}


@end
