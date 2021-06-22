//
//  HRViewController.m
//  HRCocoaTools
//
//  Created by zhangheng on 03/29/2019.
//  Copyright (c) 2019 zhangheng. All rights reserved.
//

#import "HRViewController.h"
#import <HRCocoaTools/UIImage+hrExt.h>
#import <HRCocoaTools/HRRuntimeTools.h>
#import <HRCocoaTools/UIColor+hrExt.h>

@interface HRViewController ()

@property (nonatomic, weak) IBOutlet    UISlider   *redSlider;
@property (nonatomic, weak) IBOutlet    UISlider    *greenSlider;
@property (nonatomic, weak) IBOutlet    UISlider    *blueSlider;

@property (nonatomic, strong) UIImageView *bgImgView;

@end

@implementation HRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *testImg = [[UIImageView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [self.view insertSubview:testImg atIndex:0];
    self.bgImgView = testImg;
    
    testImg.image = [[UIImage imageNamed:@"test.png"] imageByReplacingColor:[UIColor blackColor] withColor:[UIColor redColor]];
    
    NSArray *classNames = [HRRuntimeTools loadedClassNames:nil conformsToProtocol:nil];
    NSLog(@"%@",classNames);
    
    
}

- (IBAction)sendercolorSliderChanged:(UISlider *)slider {
    CGFloat redValue = self.redSlider.value / 255.0;
    CGFloat greenValue = self.greenSlider.value / 255.0;
    CGFloat blueValue = self.blueSlider.value / 255.0;
    
    UIColor *targetColor = [UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:1];
    
    self.bgImgView.image = [[UIImage imageNamed:@"test.png"] imageByReplacingColor:[UIColor blackColor] withColor:targetColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
