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

//获取一个颜色的RGB值  以255为单位返回
+ (void)getRGBComponents:(int [3])components forColor:(UIColor *)color {
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel,
                                                 1,
                                                 1,
                                                 8,
                                                 4,
                                                 rgbColorSpace,
                                                 kCGImageAlphaNoneSkipLast);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    
    for (int component = 0; component < 3; component++) {
        components[component] = resultingPixel[component];
    }
}

+ (UIImage *)replaceColorToTransparent:(UIColor *)color image:(UIImage *)image{
    // 分配内存
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    
    // 创建context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    
    int R, G, B;
    int components[3];
    [self getRGBComponents:components forColor:color];
    R = components[0];
    G = components[1];
    B = components[2];
    
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        //将像素点转成子节数组来表示---第一个表示透明度即ARGB这种表示方式。ptr[0]:透明度,ptr[1]:R,ptr[2]:G,ptr[3]:B
        //分别取出RGB值后。进行判断需不需要设成透明。
        uint8_t* ptr = (uint8_t*)pCurPtr;
        // NSLog(@"1是%d,2是%d,3是%d",ptr[1],ptr[2],ptr[3]);
        if(ptr[1] == R && ptr[2] == G && ptr[3] == B){
            ptr[0] = 0;
        }
    }
    
    // 将内存转成image
    CGDataProviderRef dataProvider =CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, nil);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight,8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast |kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true,kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // 释放
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return resultUIImage;
}

-(UIImage*) imageByReplacingColor:(UIColor*)sourceColor withColor:(UIColor*)destinationColor {
    
    //分段原颜色
    const CGFloat* sourceComponents = CGColorGetComponents(sourceColor.CGColor);
    UInt8* source255Components = malloc(sizeof(UInt8)*4);
    for (int i = 0; i < 4; i++) source255Components[i] = (UInt8)round(sourceComponents[i]*255.0);
    
    //分段目标颜色
    const CGFloat* destinationComponents = CGColorGetComponents(destinationColor.CGColor);
    UInt8* destination255Components = malloc(sizeof(UInt8)*4);
    for (int i = 0; i < 4; i++) destination255Components[i] = (UInt8)round(destinationComponents[i]*255.0);
    
    CGImageRef rawImage = self.CGImage;
    
    size_t width = CGImageGetWidth(rawImage);
    size_t height = CGImageGetHeight(rawImage);
    CGRect rect = {CGPointZero, {width, height}};
    
    // bitmap format
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = width*4;
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    
    // data pointer
    UInt8* data = calloc(bytesPerRow, height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create bitmap context
    CGContextRef ctx = CGBitmapContextCreate(data, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
    CGContextDrawImage(ctx, rect, rawImage);
    
    //循环遍历每个像素
    for (int byte = 0; byte < bytesPerRow*height; byte += 4) {
        
        UInt8 r = data[byte];
        UInt8 g = data[byte+1];
        UInt8 b = data[byte+2];
        
        // delta components
        UInt8 dr = abs(r-source255Components[0]);
        UInt8 dg = abs(g-source255Components[1]);
        UInt8 db = abs(b-source255Components[2]);
        
        // ratio of 'how far away' each component is from the source color
        CGFloat ratio = (dr+dg+db)/(255.0*3.0);
        
        // blend color components
        data[byte] = (UInt8)round(ratio*r)+(UInt8)round((1.0-ratio)*destination255Components[0]);
        data[byte+1] = (UInt8)round(ratio*g)+(UInt8)round((1.0-ratio)*destination255Components[1]);
        data[byte+2] = (UInt8)round(ratio*b)+(UInt8)round((1.0-ratio)*destination255Components[2]);
        
    }
    
    CGImageRef img = CGBitmapContextCreateImage(ctx);
    
    //清理
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(data);
    free(source255Components);
    free(destination255Components);
    
    UIImage* returnImage = [UIImage imageWithCGImage:img];
    CGImageRelease(img);
    
    return returnImage;
}

@end
