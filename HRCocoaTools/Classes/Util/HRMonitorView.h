//
//  EMMonitorView.h
//  MintLive
//
//  Created by zhangheng on 2018/5/30.
//  Copyright © 2018年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRMonitorView : UIView

@property(nonatomic,strong)UIColor *bgColor;
@property(nonatomic,strong)UIColor *textColor;
@property(nonatomic,copy)void (^tapAction)(void);


+ (instancetype)shareMonitor;



- (void)showView;

@end
