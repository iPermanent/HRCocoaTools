//
//  UIView+roundType.h
//  AFNetworking
//
//  Created by zhangheng1 on 2018/5/11.
//

#import <UIKit/UIKit.h>

typedef enum{
    HRRoundTypeTop     =   0,
    HRRoundTypeLeft,
    HRRoundTypeRight,
    HRRoundTypeBottom,
    HRRoundTypeAll,
    HRRoundTypeTopLeft,
    HRRoundTypeTopRight,
    HRRoundTypeLeftBottom,
    HRRoundTypeRightBottom,
    HRRoundTypeNone
}HRRoundType;

@interface UIView (roundType)

//指定方向圆角 
- (void)addRoundRectType:(HRRoundType)roudType withRadius:(CGFloat)radius;

@end
