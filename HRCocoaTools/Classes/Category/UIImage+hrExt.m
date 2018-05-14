//
//  UIImage+hrExt.m
//  HRCocoaTools
//
//  Created by zhangheng1 on 2018/5/14.
//

#import "UIImage+hrExt.h"
#import <ImageIO/ImageIO.h>

#define MEGA_BYTE 150*1024

@implementation UIImage (hrExt)

+ (UIImage *)imageFromColors:(NSArray <UIColor *> *)colors
                        size:(CGSize)imageSize
           directionVertical:(BOOL)vertical {
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    NSMutableArray *arr = [NSMutableArray new];
    for(int i = 0 ; i < colors.count ; i ++){
        UIColor *color = colors[i];
        [arr addObject:(__bridge id)color.CGColor];
    }
    layer.colors = arr.copy;
    
    if(vertical){
        layer.startPoint = CGPointMake(0.5, 0);
        layer.endPoint = CGPointMake(0.5, 1);
    }else{
        layer.startPoint = CGPointMake(0, 0.5);
        layer.endPoint = CGPointMake(1, 0.5);
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, 1, 0);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *retImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height/2.0, image.size.width/2.0, image.size.height/2.0, image.size.width/2.0) resizingMode:UIImageResizingModeStretch];
    
    return retImage;
}

/**
 通过URL获取图片尺寸
 
 @param url 图片地址
 @return 图片尺寸
 */
+(CGSize)imageSizeFromUrl:(NSString *)url {
    if(!url || url.length == 0 || ![url hasPrefix:@"http"]){
        NSLog(@"image url error");
        return CGSizeZero;
    }
    
    CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)[NSURL URLWithString:url], NULL);
    NSDictionary* imageHeader = (__bridge NSDictionary*) CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
    
    return CGSizeMake([imageHeader[@"PixelWidth"] floatValue], [imageHeader[@"PixelHeight"] floatValue]);
}

+(NSData *)dataFromImageForUpload:(UIImage *)image{
    NSData  *data = UIImageJPEGRepresentation(image, 1);
    double compressQuality = (double)MEGA_BYTE/(CGFloat)data.length;
    if(compressQuality < 0 ){
        data = UIImageJPEGRepresentation(image, compressQuality);
    }
    
    CGFloat screenWidth = 720;
    CGFloat imageWidth = MIN(image.size.width, image.size.height);
    CGFloat ratio = imageWidth / screenWidth;
    
    UIImage *dealImage = [UIImage imageWithData:data];
    if(ratio > 1){
        CGSize newSize = CGSizeMake(image.size.width / ratio, image.size.height / ratio);
        dealImage = [self imageWithImage:dealImage scaledToSize:newSize];
    }
    
    return UIImageJPEGRepresentation(dealImage, compressQuality>1?1:compressQuality*2);
}

+(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
