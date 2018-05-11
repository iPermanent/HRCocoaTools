//
//  HRImageCutViewController.h
//  HRImageClipper
//
//  Created by zhangheng1 on 2018/5/9.
//  Copyright © 2018年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRImageCutViewController : UIViewController

//x,y分别对应长宽的比例,可为整也可不为整,如果不设置默认比例1：1正方形
@property(nonatomic,assign)CGPoint  cutScale;
//需要裁剪的原图
@property(nonatomic,strong)UIImage  *origalImage;
//处理完成的回调
@property(nonatomic,copy)void(^dealCompletionBlock)(UIImage *editedImage);

@end
