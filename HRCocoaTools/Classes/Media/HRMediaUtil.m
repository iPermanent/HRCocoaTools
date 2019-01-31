//
//  HRUtil.m
//  HRCocoaTools
//
//  Created by ZhangHeng on 15/3/6.
//  Copyright (c) 2015年 ZhangHeng. All rights reserved.
//

#import "HRMediaUtil.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <MobileCoreServices/MobileCoreServices.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

static OSType pixelFormatType = kCVPixelFormatType_32ARGB;

@implementation HRMediaUtil

+(void)saveImagesToVideoWithImages:(NSArray *)paths completed:(SaveVideoCompleted)completed andFailed:(SaveVideoFailed)failedBlock{
    [self saveImagesToVideoWithImages:paths
                         andAudioPath:nil
                            completed:completed
                            andFailed:failedBlock];
}

+(void)saveImagesToVideoWithImages:(NSArray *)paths
                      andAudioPath:(NSString *)audioPath
                         completed:(SaveVideoCompleted)completed
                         andFailed:(SaveVideoFailed)failedBlock{
    //数据为空就不需要了
    if(!paths && paths.count == 0)
        return;
    
    long long timeString = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"video%llu.mp4",timeString];
    NSString    *videoPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:fileName];
    unlink([videoPath UTF8String]);
    
    __block    NSError     *error = nil;
    
    NSString *firstImage = [paths firstObject];
    //如果传的是相对的路径
    if(![firstImage hasPrefix:NSHomeDirectory()]){
        //自己处理，依据情况不同
    }
    UIImage *first = [UIImage imageWithContentsOfFile:firstImage];
    CGSize frameSize = first.size;
    
    AVAssetWriter *videoWriter =[[AVAssetWriter alloc]initWithURL:[NSURL fileURLWithPath:videoPath]
                                                         fileType:AVFileTypeQuickTimeMovie
                                                            error:&error];
    NSParameterAssert(videoWriter);
    if(error)
        NSLog(@"error =%@", [error localizedDescription]);
    
    NSDictionary *videoSettings =[NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264,AVVideoCodecKey,
                                  [NSNumber numberWithInt:frameSize.width],AVVideoWidthKey,
                                  [NSNumber numberWithInt:frameSize.height],AVVideoHeightKey,nil];
    AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSDictionary*sourcePixelBufferAttributesDictionary =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB],kCVPixelBufferPixelFormatTypeKey,nil];
    
    AVAssetWriterInputPixelBufferAdaptor __block *adaptor =[AVAssetWriterInputPixelBufferAdaptor
                                                            assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    
    if ([videoWriter canAddInput:writerInput])
        [videoWriter addInput:writerInput];
    else
        NSLog(@"failed add input");
    
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    //开始合成图片
    dispatch_queue_t dispatchQueue =dispatch_queue_create("mediaInputQueue",NULL);
    int __block frame =0;
    
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        while([writerInput isReadyForMoreMediaData]){
            if(++frame >= [paths count] ){
                [writerInput markAsFinished];
                [videoWriter finishWritingWithCompletionHandler:^{
                    [self addAudioToFileAtPath:videoPath andAudioPath:audioPath Success:^(NSString *filePath) {
                        if(completed){
                            completed(filePath);
                        }
                    } failed:^(NSError *error) {
                        if(failedBlock)
                            failedBlock(error);
                    }];
                }];
                break;
            }
            
            UIImage *info = [UIImage imageWithContentsOfFile:[paths objectAtIndex:frame]];
            CVPixelBufferRef buffer = [self pixelBufferFromCGImage:info.CGImage size:frameSize];
            if (buffer){
                if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame,24)]){
                    if(failedBlock)
                        failedBlock(error);
                    CFRelease(buffer);
                }
                CFRelease(buffer);
            }
            else{
                CFRelease(buffer);
            }
        }
    }];
}

+(CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size{
    CGSize frameSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             @YES, kCVPixelBufferCGImageCompatibilityKey,
                             @YES, kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          frameSize.width,
                                          frameSize.height,
                                          pixelFormatType,
                                          (__bridge CFDictionaryRef)options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaNoneSkipFirst & kCGBitmapAlphaInfoMask;
    
    //NSUInteger bytesPerRow = 4 * frameSize.width;
    NSUInteger bitsPerComponent = 8;
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pxbuffer);
    
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 frameSize.width,
                                                 frameSize.height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 rgbColorSpace,
                                                 bitmapInfo);
    
    CGContextDrawImage(context, CGRectMake(0, 0, frameSize.width, frameSize.height), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}


//向无声视频文件中加入声音
+(void)addAudioToFileAtPath:(NSString *)vidoPath andAudioPath:(NSString *)audioPath Success:(SaveVideoCompleted)successBlock failed:(SaveVideoFailed)failedBlock{
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    NSURL* audio_inputFileUrl = [NSURL fileURLWithPath:audioPath];
    NSURL* video_inputFileUrl = [NSURL fileURLWithPath:vidoPath];
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *outputFilePath =[[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",@"testPlay"]];
    NSURL* outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath])
        [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
    
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    if ([videoAsset tracksWithMediaType:AVMediaTypeVideo].count != 0) {
        [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    }
    
    audioAsset = nil;
    videoAsset = nil;
    
    AVAssetExportSession __block *  _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    _assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    _assetExport.outputURL = outputFileUrl;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:^(void ){
        switch (_assetExport.status){
            case AVAssetExportSessionStatusCompleted:{
                if(successBlock)
                    successBlock(outputFilePath);
                break;
            }
            case AVAssetExportSessionStatusFailed:{
                if(failedBlock)
                    failedBlock(_assetExport.error);
                break;
            }
            case AVAssetExportSessionStatusCancelled:{
                
                break;
            }
            case AVAssetExportSessionStatusExporting:{
            }
                break;
            case AVAssetExportSessionStatusUnknown:{
            }
                break;
            case AVAssetExportSessionStatusWaiting:{
            }
                break;
        }
        
        _assetExport=nil;
    }];
    
}

+(void)convertVideoToGifWithVideo:(NSString *)videoPath completed:(SaveVideoCompleted)completed andFailed:(SaveVideoFailed)failedBlock{
    NSString    *dealPath = @"";
    __block    NSError     *error = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //暂未实现方法
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error && completed) {
                completed(dealPath);
            }
            
            if(error && failedBlock){
                failedBlock(error);
            }
        });
    });
}



+(void)converVideoDimissionWithFilePath:(NSString *)videoPath
                          andOutputPath:(NSString *)outputPath
                                cutType:(HRVideoCutRectType )cutType
                         withCompletion:(void (^)(NSError *error))completion{
    //获取原视频
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
    
    //创建视频轨道信息
    AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    //创建视频分辨率等一些设置
    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, 30);
    //设置渲染的宽高分辨率,均为视频的自然高度
    videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.height);
    
    //创建视频的构造信息
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30));
    
    AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:clipVideoTrack];
    
    CGAffineTransform t1;
    switch (cutType) {
        case HRVideoCutRectTypeTop:{
            t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, 0 );
        }
            break;
        case HRVideoCutRectTypeCenter:{
            t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, -(clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height) /2 );
        }
            break;
        case HRVideoCutRectTypeBottom:{
            t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, (clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height) /2);
        }
            break;
        default:{
            //将裁剪后保留的区域设置为视频中间部分
            t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, -(clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height) /2 );
        }
            break;
    }
    
    //保证视频为垂直正确的方向
    CGAffineTransform t2 = CGAffineTransformRotate(t1, M_PI_2);
    
    CGAffineTransform finalTransform = t2;
    [transformer setTransform:finalTransform atTime:kCMTimeZero];
    
    //先添加tranform层的构造信息，再添加分辨率信息
    instruction.layerInstructions = [NSArray arrayWithObject:transformer];
    videoComposition.instructions = [NSArray arrayWithObject: instruction];
    
    //移除掉之前所存在的视频文件
    [[NSFileManager defaultManager]  removeItemAtURL:[NSURL fileURLWithPath:outputPath] error:nil];
    
    //开始进行导出视频
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality] ;
    exporter.videoComposition = videoComposition;
    exporter.outputURL = [NSURL fileURLWithPath:outputPath];
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (exporter.status) {
                case AVAssetExportSessionStatusCompleted:{
                    //导出完成后执行回调
                    if(completion)
                        completion(nil);
                    }
                    break;
                case AVAssetExportSessionStatusFailed:{
                    //导出完成后执行回调
                    if(completion)
                        completion(exporter.error);
                }
                    break;
                case AVAssetExportSessionStatusCancelled:{
                    //导出完成后执行回调
                    NSError *error = [[NSError alloc] initWithDomain:@"com.henry.hrcocoatool" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"用户取消"}];
                    if(completion)
                        completion(error);
                }break;
                default:
                    break;
            }
        });
    }];
}

+(void)convertMp3File:(NSString *)mp3Path
           outPutPath:(NSString *)rintonePath
        WithStartTime:(CGFloat)start_time
             end_time:(CGFloat)end_time
       withCompletion:(void (^)(void))completion
               failed:(SaveVideoFailed)failed{
    float vocalStartMarker = start_time > 0 ? start_time : 0;
    float vocalEndMarker = end_time - start_time > 40 ? start_time + 40 : end_time;
    
    NSURL *audioFileInput = [NSURL fileURLWithPath:mp3Path];
    NSURL *audioFileOutput = [NSURL fileURLWithPath:rintonePath];
    
    if (!audioFileInput || !audioFileOutput){
        if(failed){
            NSError *error = [[NSError alloc] initWithDomain:@"输入输出路径不正确" code:-1 userInfo:nil];
            failed(error);
        }
        return ;
    }
    
    [[NSFileManager defaultManager] removeItemAtURL:audioFileOutput error:NULL];
    AVAsset *asset = [AVAsset assetWithURL:audioFileInput];
    
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset
                                                                            presetName:AVAssetExportPresetAppleM4A];
    if (exportSession == nil){
        if(failed){
            NSError *error = [[NSError alloc] initWithDomain:@"输入格式不正确" code:-1 userInfo:nil];
            failed(error);
        }
        return;
    }
    
    CMTime startTime = CMTimeMake((int)(floor(vocalStartMarker * 100)), 100);
    CMTime stopTime = CMTimeMake((int)(ceil(vocalEndMarker * 100)), 100);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    
    exportSession.outputURL = audioFileOutput;
    exportSession.outputFileType = AVFileTypeAppleM4A;
    exportSession.timeRange = exportTimeRange;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        if (AVAssetExportSessionStatusCompleted == exportSession.status){
            // It worked!
            if(completion){
                completion();
            }
        }
        else if (AVAssetExportSessionStatusFailed == exportSession.status){
            // It failed...
            if(failed){
                failed(exportSession.error);
            }
        }
    }];
}

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
     withCompletion:(void(^)(void))completion{
    NSAssert(videoPath, @"视频路径不能为空");
    AVURLAsset* videoAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoPath] options:nil];
    AVURLAsset * audioAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoPath] options:nil];
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    CMTime startTime = CMTimeMakeWithSeconds(0.2, 600);
    CMTime endTime = CMTimeMakeWithSeconds(videoAsset.duration.value/videoAsset.duration.timescale-0.2, videoAsset.duration.timescale);
    
    AVMutableCompositionTrack* compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo  preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVAssetTrack* clipVideoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                   ofTrack:clipVideoTrack
                                    atTime:kCMTimeZero error:nil];
    
    [compositionVideoTrack setPreferredTransform:[[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] preferredTransform]];
    
    //音频通道
    AVMutableCompositionTrack * audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    //音频采集通道
    AVAssetTrack * audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    [audioTrack insertTimeRange:CMTimeRangeMake(startTime, endTime) ofTrack:audioAssetTrack atTime:kCMTimeZero error:nil];
    
    //通过水印图片创建layer
    CALayer* aLayer = [CALayer layer];
    aLayer.contents = (id)image.CGImage;
    aLayer.frame = CGRectMake(50, 100, imageSize.width, imageSize.height);
    aLayer.opacity = 0.9;
    
    //按正确顺序排列layer
    AVAssetTrack* videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize videoSize = [videoTrack naturalSize];
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:aLayer];
    
    //    switch (location) {
    //        case HRMaskImageLocationTopLeft:
    //            parentLayer.frame = CGRectMake(20, 20, videoSize.width, videoSize.height);
    //            break;
    //        case HRMaskImageLocationTopRight:
    //            parentLayer.frame = CGRectMake(videoSize.width - 20 - videoSize.width, 20, videoSize.width, videoSize.height);
    //            break;
    //        case HRMaskImageLocationBottomRight:
    //            parentLayer.frame = CGRectMake(videoSize.width - 20 - imageSize.width, videoPath.accessibilityFrame.size.height - 20 - imageSize.height, imageSize.width, imageSize.height);
    //            break;
    //        case HRMaskImageLocationBottomLeft:
    //            parentLayer.frame = CGRectMake(20, videoPath.accessibilityFrame.size.height - 20 - imageSize.height, imageSize.width, imageSize.height);
    //            break;
    //        default:
    //            parentLayer.frame = CGRectMake(20, 20, imageSize.width, imageSize.height);
    //            break;
    //    }
    
    //文本区域layer
    CATextLayer* titleLayer = [CATextLayer layer];
    titleLayer.backgroundColor = [UIColor clearColor].CGColor;
    titleLayer.string = @"test";
    titleLayer.font = CFBridgingRetain(@"Helvetica");
    titleLayer.fontSize = 28;
    titleLayer.shadowOpacity = 0.5;
    titleLayer.alignmentMode = kCAAlignmentCenter;
    titleLayer.frame = CGRectMake(0, 50, videoSize.width, videoSize.height / 6);
    [parentLayer addSublayer:titleLayer];
    
    //create the composition and add the instructions to insert the layer:
    AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
    videoComp.renderSize = videoSize;
    videoComp.frameDuration = CMTimeMake(1, 30);
    videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    //构造视频信息
    AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
    AVAssetTrack* mixVideoTrack = [[mixComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mixVideoTrack];
    BOOL isVideoAssetPortrait_  = NO;
    CGAffineTransform videoTransform = videoTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        isVideoAssetPortrait_ = YES;
    }
    
    CGSize naturalSize;
    if(isVideoAssetPortrait_){
        naturalSize = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.width);
    } else {
        naturalSize = videoTrack.naturalSize;
    }
    
    float renderWidth, renderHeight;
    renderWidth = naturalSize.width;
    renderHeight = naturalSize.height;
//    videoComp.renderSize = naturalSize;
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    videoComp.instructions = [NSArray arrayWithObject: instruction];
    
    //导出视频
    AVAssetExportSession *_assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    _assetExport.videoComposition = videoComp;
    
    NSString* videoName = [[[videoPath lastPathComponent] stringByDeletingPathExtension] stringByAppendingString:@"_addMask.mp4"];
    NSString* exportPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:videoName];
    NSURL* exportUrl = [NSURL fileURLWithPath:exportPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    
    _assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    _assetExport.outputURL = exportUrl;
    _assetExport.shouldOptimizeForNetworkUse = YES;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:^(void ) {
        switch (_assetExport.status){
            case AVAssetExportSessionStatusUnknown:
                NSLog(@"Unknown");
                break;
            case AVAssetExportSessionStatusWaiting:
                NSLog(@"Waiting");
                break;
            case AVAssetExportSessionStatusExporting:
                NSLog(@"Exporting");
                break;
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"Created new water mark image");
                break;
            case AVAssetExportSessionStatusFailed:
                break;
            case AVAssetExportSessionStatusCancelled:
                break;
        }
        if(completion){
            completion();
        }
    }];
}

@end



