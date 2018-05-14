//
//  HRSimpleAnimation.m
//  HRCocoaTools
//
//  Created by zhangheng1 on 2018/5/14.
//

#import "HRSimpleAnimation.h"
#import <pop/pop.h>

@implementation HRSimpleAnimation

+ (void)addTouchAnimation:(UIButton *)targetButton {
    [targetButton addTarget:self action:@selector(touchDownAction:) forControlEvents:UIControlEventTouchDown];
    [targetButton addTarget:self action:@selector(touchUpAction:) forControlEvents:UIControlEventTouchUpInside];
    [targetButton addTarget:self action:@selector(touchUpAction:) forControlEvents:UIControlEventTouchUpOutside];
}

+ (void)touchDownAction:(UIButton *)button{
    POPSpringAnimation *popAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    popAnimation.springBounciness = 12;
    popAnimation.springSpeed = 20;
    popAnimation.fromValue = [NSValue valueWithCGSize:CGSizeMake(1, 1)];
    popAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(0.9, 0.9)];
    
    [button.layer pop_addAnimation:popAnimation forKey:@"showBunddle"];
}

+ (void)touchUpAction:(UIButton *)button {
    POPSpringAnimation *popAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    popAnimation.springBounciness = 12;
    popAnimation.springSpeed = 20;
    popAnimation.fromValue = [NSValue valueWithCGSize:CGSizeMake(0.9, 0.9)];
    popAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1, 1)];
    
    [button.layer pop_addAnimation:popAnimation forKey:@"showBunddle"];
}


@end
