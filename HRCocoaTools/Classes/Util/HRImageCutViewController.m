//
//  HRImageCutViewController.m
//  HRImageClipper
//
//  Created by zhangheng1 on 2018/5/9.
//  Copyright © 2018年 NetEase. All rights reserved.
//

#import "HRImageCutViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface HRImageCutViewController ()

@property(nonatomic,strong)UIScrollView *imageContentScrollView;
@property(nonatomic,strong)UIImageView  *imageContentView;
@property(nonatomic,strong)CALayer      *fillLayer;

@end

@implementation HRImageCutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.cutScale.x == 0 || self.cutScale.y == 0){
        self.cutScale = CGPointMake(1, 1);
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
    [self setUpMaskViews];
    [self setUpButtonsView];
}

- (void)setUpButtonsView {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmEditing)];
}

- (void)confirmEditing {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if(self.dealCompletionBlock){
            CGFloat offsetX = self.imageContentScrollView.contentOffset.x;
            CGFloat offsetY = self.imageContentScrollView.contentOffset.y;
            CGSize imageSize = self.origalImage.size;
            
            CGRect dealRect = CGRectMake(offsetX / self.imageContentScrollView.contentSize.width * imageSize.width, offsetY / self.imageContentScrollView.contentSize.height * imageSize.height, imageSize.width * self.imageContentScrollView.frame.size.width / self.imageContentScrollView.contentSize.width, imageSize.height * self.imageContentScrollView.frame.size.height / self.imageContentScrollView.contentSize.height);
            
            CGImageRef dealImage = CGImageCreateWithImageInRect([self.origalImage CGImage], dealRect);
            UIImage *ediedImage = [UIImage imageWithCGImage:dealImage];
            self.dealCompletionBlock(ediedImage);
        }
    }];
    
}

- (void)cancelEditing {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setUpMaskViews {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    //中间透明遮罩图层
    CGRect centerRect;
    if(self.cutScale.x < self.cutScale.y){
        centerRect = CGRectMake(0, 0, screenWidth - 100, (screenWidth - 100.0)*(self.cutScale.y / self.cutScale.x) );
    }else{
        centerRect = CGRectMake(0, 0, screenHeight / 2.0, (screenHeight / 2.0)*(self.cutScale.x / self.cutScale.y) );
    }
    centerRect.origin.x = (screenWidth - centerRect.size.width) / 2.0;
    centerRect.origin.y = (screenHeight - centerRect.size.height) / 2.0;
    
    UIImageOrientation orientation = self.origalImage.imageOrientation;
    //修复方向问题
    if(orientation != UIImageOrientationUp){
        CGSize size = self.origalImage.size;
        UIGraphicsBeginImageContextWithOptions(size, false, self.origalImage.scale);
        [self.origalImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.origalImage = image;
    }
    
    self.origalImage = [UIImage imageWithCGImage:self.origalImage.CGImage scale:1 orientation:UIImageOrientationUp];
    
    //imageView
    CGSize imageSize = self.origalImage.size;
    
    _imageContentScrollView = [[UIScrollView alloc] initWithFrame:centerRect];
    _imageContentScrollView.layer.borderColor = [UIColor whiteColor].CGColor;
    _imageContentScrollView.layer.borderWidth = 1;
    _imageContentScrollView.clipsToBounds = NO;
    _imageContentScrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:_imageContentScrollView];
    
    CGRect imageRect;
    if(imageSize.width/self.cutScale.x > imageSize.height/self.cutScale.y){
        //横图
        imageRect = CGRectMake(0, 0, centerRect.size.height * imageSize.width / imageSize.height, centerRect.size.height);
    }else{
        //竖图
        imageRect = CGRectMake(0, 0, centerRect.size.width, centerRect.size.width * imageSize.height / imageSize.width);
    }
    
    _imageContentView = [[UIImageView alloc] initWithFrame:imageRect];
    _imageContentView.image = _origalImage;
    _imageContentView.contentMode = UIViewContentModeScaleAspectFit;
    [_imageContentScrollView addSubview:_imageContentView];
    _imageContentScrollView.contentSize = imageRect.size;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, screenWidth, screenHeight) cornerRadius:0];
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:centerRect cornerRadius:0];
    
    [path appendPath:circlePath];
    [path setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule =kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor blackColor].CGColor;
    fillLayer.opacity =0.5;
    [self.view.layer addSublayer:fillLayer];
    
    CGRect firstVisibleRect = CGRectMake((_imageContentScrollView.contentSize.width - _imageContentScrollView.frame.size.width) / 2, (_imageContentScrollView.contentSize.height - _imageContentScrollView.frame.size.height) / 2, _imageContentScrollView.frame.size.width, _imageContentScrollView.frame.size.height);
    
    [_imageContentScrollView scrollRectToVisible:firstVisibleRect animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
