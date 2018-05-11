//
//  HRUtil.h
//  HRCocoaTools
//
//  Created by ZhangHeng on 15/3/6.
//  Copyright (c) 2015年 ZhangHeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue,A) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:A]

@interface HRMediaUtil : NSObject

typedef void(^SaveVideoCompleted)(NSString *filePath);
typedef void(^SaveVideoFailed)(NSError *error);

typedef NS_ENUM(NSUInteger, HRMaskImageLocation) {
    HRMaskImageLocationTopLeft = 0,
    HRMaskImageLocationTopRight,
    HRMaskImageLocationBottomLeft,
    HRMaskImageLocationBottomRight
};

/**
 *  @author Henry
 *
 *  将图片数组合成一段视频，图片数量必须在2个及以上。否则全成会失败
 *
 *  @param paths       路径的数组
 *  @param completed   完成的回调
 *  @param failedBlock 失败的回调
 */
+(void)saveImagesToVideoWithImages:(NSArray *)paths
                         completed:(SaveVideoCompleted)completed
                         andFailed:(SaveVideoFailed)failedBlock;

/**
 *  @author Henry
 *
 *  将图片和声音合成一段视频
 *
 *  @param paths       保存图片路径的数组
 *  @param audioPath   声音的路径
 *  @param completed   完成的回调
 *  @param failedBlock 失败的回调
 */
+(void)saveImagesToVideoWithImages:(NSArray *)paths
                      andAudioPath:(NSString *)audioPath
                         completed:(SaveVideoCompleted)completed
                         andFailed:(SaveVideoFailed)failedBlock;

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
 *  @author Henry
 *
 *  通过#RRGGBBAA这样的格式获取颜色
 *
 *  @param colorString #RRGGBBAA
 *
 *  @return UIColor
 */
+(UIColor *)getColorFromString:(NSString *)colorString;

/**
 *  @author Henry
 *
 *  将竖着的视频裁剪为正方形区域显示
 *
 *  @param videoPath  原视频路径
 *  @param outputPath 输出视频路径
 *  @param type       裁剪方式  0:裁剪取上半部分  1.裁剪后取中间部分  2.裁剪后取下部分
 *
 *  @param completion 完成回调
 */
+(void)converVideoDimissionWithFilePath:(NSString *)videoPath
                          andOutputPath:(NSString *)outputPath
                                cutType:(int)type
                         withCompletion:(void(^)(void))completion;


/**
 向指定路径的视频添加水印

 @param image 水印图片
 @param imageSize 水印图片大小
 @param videoPath 视频路径
 @param completion 完成回调
 */
+(void)addMaskImage:(UIImage *)image
               size:(CGSize )imageSize
           location:(HRMaskImageLocation)location
            toVideo:(NSString *)videoPath
     withCompletion:(void(^)(void))completion;


/**
通过URL获取图片尺寸

 @param url 图片地址
 @return 图片尺寸
 */
+(CGSize)imageSizeFromUrl:(NSString *)url;

@end
