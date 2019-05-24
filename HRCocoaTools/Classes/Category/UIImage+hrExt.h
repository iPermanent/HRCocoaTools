//
//  UIImage+hrExt.h
//  HRCocoaTools
//
//  Created by zhangheng1 on 2018/5/14.
//

#import <UIKit/UIKit.h>

@interface UIImage (hrExt)

/**
 *  @author Henry
 *
 *  压缩图片到适合上传的大小,默认为150K左右
 *
 *  @param image 图片对象
 *
 *  @return 压缩后的图片二进制数据
 */
+(NSData *)dataFromImageForUpload:(UIImage *)image;

/**
 *  @author Henry
 *
 *  转换图片的大小size
 *
 *  @param image   UIImage原图对象
 *  @param newSize 新的大小size
 *
 *  @return 处理后的UIImage对象
 */
+(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

/**
 通过指定颜色和大小方向获取一张渐变图片

 @param colors 渐变色数组
 @param imageSize 图片大小
 @param vertical 是否为垂直渐变，否则为水平渐变
 @return 生成的图片
 */
+ (UIImage *)imageFromColors:(NSArray <UIColor *> *)colors
                        size:(CGSize )imageSize
           directionVertical:(BOOL)vertical;

/**
 通过URL获取图片尺寸
 
 @param url 图片地址
 @return 图片尺寸
 */
+(CGSize)imageSizeFromUrl:(NSString *)url;

/**
 获取一个颜色的RGB值  以255为单位返回

 @param components 传入CGFloat components[3] 这样的数组，用数组接收值
 @param color 需要分析的color
 */
+ (void)getRGBComponents:(int [3])components forColor:(UIColor *)color;

/**
 将某张图中指定的颜色替换为透明背景

 @param color 需要替换的颜色
 @param image 需要处理的图片
 @return 处理后的透明图片
 */
+ (UIImage *)replaceColorToTransparent:(UIColor *)color image:(UIImage *)image;




/**
 将一张图中指定的颜色替换为另一种颜色
 
 @param sourceColor 需要被替换的颜色
 @param destinationColor 目标颜色
 @return 处理完成的图
 */
- (UIImage*)imageByReplacingColor:(UIColor*)sourceColor withColor:(UIColor*)destinationColor;

@end
