//
//  HRUtil.h
//  KeyboardTest
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


/**
 *  @author Henry
 *
 *  将图片数组合成一段视频
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
 *  将视频转换为gif格式
 *
 *  @param videoPath   视频文件路径
 *  @param completed   完成的回调
 *  @param failedBlock 失败的回调
 */

//#warning 暂未实现此方法
//+(void)convertVideoToGifWithVideo:(NSString *)videoPath
//                        completed:(SaveVideoCompleted)completed
//                        andFailed:(SaveVideoFailed)failedBlock;

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

//周均按周日第一天开始算，如果有需要自行添加一天到周一至周日
//获取本周第一天
+(NSDate *)getFirstDayOFcurrentWeek;

//获取本周最后一天
+(NSDate *)getLastDayOfCurrentWeek;

/**
 *  @author Henry
 *
 *  将视频裁剪为正方形区域显示
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
 将mp3转为m4r铃声格式，时间最多为40秒

 @param mp3Path mp3文件路径
 @param rintonePath 输出m4r路径
 @param start_time 开始时间
 @param end-time 结束时间
 @param completion 完成回调
 */
//+(void)convertMp3File:(NSString *)mp3Path
//           outPutPath:(NSString *)rintonePath
//        WithStartTime:(CGFloat)start_time
//              endTime:(CGFloat)end_time
//       withCompletion:(void(^)(void))completion
//               failed:(SaveVideoFailed)failed;

@end
