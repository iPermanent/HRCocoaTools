//
//  HRViewController.m
//  HRCocoaTools
//
//  Created by zhangheng on 03/29/2019.
//  Copyright (c) 2019 zhangheng. All rights reserved.
//

#import "HRViewController.h"
#import <HRCocoaTools/UIImage+hrExt.h>

@interface HRViewController ()

@end

@implementation HRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *testImg = [[UIImageView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [self.view addSubview:testImg];
//    testImg.image = [UIImage replaceColorToTransparent:[UIColor whiteColor] image:[UIImage imageNamed:@"test.png"]];
//    testImg.image =  [self replaceImage:[UIImage imageNamed:@"test.png"]
//                             originalColor:[UIColor whiteColor]
//                                   toColor:[UIColor redColor]];
    
    testImg.image = [[UIImage imageNamed:@"test.png"] imageByReplacingColor:[UIColor whiteColor] withColor:[UIColor redColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
