//
//  UIView+roundType.m
//  AFNetworking
//
//  Created by zhangheng1 on 2018/5/11.
//

#import "UIView+roundType.h"

@implementation UIView (roundType)

- (void)addRoundRectType:(HRRoundType)roudType withRadius:(CGFloat)radius{
    self.layer.mask = nil;
    UIRectCorner   corners;
    switch (roudType) {
        case HRRoundTypeLeft:
            corners = UIRectCornerBottomLeft | UIRectCornerTopLeft;
            break;
        case HRRoundTypeRight:
            corners = UIRectCornerBottomRight | UIRectCornerTopRight;
            break;
        case HRRoundTypeBottom:
            corners = UIRectCornerBottomLeft | UIRectCornerBottomRight;
            break;
        case HRRoundTypeTop:
            corners = UIRectCornerTopRight | UIRectCornerTopLeft;
            break;
        case HRRoundTypeNone:
            corners = UIRectCornerBottomLeft & UIRectCornerBottomRight;
            break;
        case HRRoundTypeTopLeft:
            corners = UIRectCornerTopLeft;
            break;
        case HRRoundTypeTopRight:
            corners = UIRectCornerTopRight;
            break;
        case HRRoundTypeLeftBottom:
            corners = UIRectCornerBottomLeft;
            break;
        case HRRoundTypeAll:
            corners = UIRectCornerAllCorners;
            break;
        case HRRoundTypeRightBottom:
            corners = UIRectCornerBottomRight;
            break;
            
        default:
            break;
    }
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame         = self.bounds;
    maskLayer.path          = maskPath.CGPath;
    self.layer.mask         = maskLayer;
}

@end
