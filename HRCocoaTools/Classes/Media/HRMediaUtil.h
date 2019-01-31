//
//  HRUtil.h
//  HRCocoaTools
//
//  Created by ZhangHeng on 15/3/6.
//  Copyright (c) 2015年 ZhangHeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HRMediaUtil : NSObject

typedef void(^SaveVideoCompleted)(NSString *filePath);
typedef void(^SaveVideoFailed)(NSError *error);

typedef NS_ENUM(NSUInteger, HRMaskImageLocation) {
    HRMaskImageLocationTopLeft = 0,
    HRMaskImageLocationTopRight,
    HRMaskImageLocationBottomLeft,
    HRMaskImageLocationBottomRight
};

//左右暂未做支持
typedef NS_ENUM(NSUInteger, HRVideoCutRectType){
    HRVideoCutRectTypeTop,
//    HRVideoCutRectTypeLeft,
    HRVideoCutRectTypeCenter,
//    HRVideoCutRectTypeRight,
    HRVideoCutRectTypeBottom
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
 *  将竖着的视频裁剪为正方形区域显示
 *
 *  @param videoPath  原视频路径
 *  @param outputPath 输出视频路径
 *  @param cutType       裁剪方式
 *
 *  @param completion 完成回调
 */
+(void)converVideoDimissionWithFilePath:(NSString *)videoPath
                          andOutputPath:(NSString *)outputPath
                                cutType:(HRVideoCutRectType) cutType
                         withCompletion:(void(^)(NSError *error))completion;


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

@end
