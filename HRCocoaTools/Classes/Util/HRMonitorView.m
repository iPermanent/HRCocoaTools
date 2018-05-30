//
//  EMMonitorView.m
//  MintLive
//
//  Created by zhangheng on 2018/5/30.
//  Copyright © 2018年 NetEase. All rights reserved.
//

#import "HRMonitorView.h"
#import <mach/mach.h>
#import <assert.h>

static HRMonitorView *_monitorView = nil;

@interface HRMonitorView() {
    UILabel     *cpuLabel;
    UILabel     *memoryLabel;
    UILabel     *fpsLabel;
    UILabel     *versionLabel;
}
@property(nonatomic,strong)UIView   *roundBgView;
@property(nonatomic,strong)CADisplayLink *displayLink;

@property (nonatomic) int screenUpdatesCount;

@property (nonatomic) CFTimeInterval screenUpdatesBeginTime;

@property (nonatomic) CFTimeInterval averageScreenUpdatesTime;

@end

@implementation HRMonitorView

+ (instancetype)shareMonitor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _monitorView = [HRMonitorView new];
    });
    
    return _monitorView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(20, 100, 80, 80)];
    if(self){
        [self configMonitorView];
    }
    return self;
}

- (void)setBgColor:(UIColor *)bgColor {
    _roundBgView.backgroundColor = bgColor;
}

- (void)setTintColor:(UIColor *)tintColor {
    memoryLabel.textColor = tintColor;
    cpuLabel.textColor = tintColor;
    fpsLabel.textColor = tintColor;
    versionLabel.textColor = tintColor;
}

- (void)showMonitorDetail {
    if(self.tapAction){
        self.tapAction();
    }
}

- (void)configLableWithDefault:(UILabel *)label {
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:12];
}

- (void)configMonitorView {
    self.backgroundColor = [UIColor clearColor];
    
    self.screenUpdatesCount = 0;
    self.screenUpdatesBeginTime = 0.0f;
    self.averageScreenUpdatesTime = 0.017f;
    
    UIView *containerView = [[UIView alloc] initWithFrame:self.bounds];
    containerView.backgroundColor = [UIColor darkGrayColor];
    containerView.layer.cornerRadius = 40;
    containerView.clipsToBounds = YES;
    [self addSubview:containerView];
    _roundBgView = containerView;
    
    cpuLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height / 2 - 14, self.bounds.size.width, 14)];
    [self configLableWithDefault:cpuLabel];
    [self addSubview:cpuLabel];
    
    memoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.bounds.size.height / 2 - 30, self.bounds.size.width - 10, 14)];
    [self configLableWithDefault:memoryLabel];
    [self addSubview:memoryLabel];
    
    fpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.bounds.size.height / 2 + 1, self.bounds.size.width - 10, 14)];
    [self configLableWithDefault:fpsLabel];
    [self addSubview:fpsLabel];
    
    versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height / 2 + 16, self.bounds.size.width, 14)];
    [self configLableWithDefault:versionLabel];
    [self addSubview:versionLabel];
    versionLabel.text = [NSString stringWithFormat:@"iOS %@",[[UIDevice currentDevice] systemVersion]];
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateShowUsage)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMonitorDetail)];
    [self addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *dragGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragedMoved:)];
    [self addGestureRecognizer:dragGes];
    
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowRadius = 10.0;
}

- (void)dragedMoved:(UIPanGestureRecognizer *)panGes {
    if(panGes.state == UIGestureRecognizerStateBegan){
        
    }else if(panGes.state == UIGestureRecognizerStateChanged){
        CGPoint currentPoint = [panGes locationInView:self.superview];
        [self setCenter:currentPoint];
    }else if(panGes.state == UIGestureRecognizerStateEnded){
        CGRect frame = self.superview.frame;
        //拉出界面外的情况下  弹回来
        if(!CGRectContainsRect(frame, self.frame)){
            CGRect finalRect = self.frame;
            if(self.frame.origin.x < 20){
                finalRect = CGRectMake(20, finalRect.origin.y, finalRect.size.width, finalRect.size.height);
            }
            if(self.frame.origin.x > self.superview.bounds.size.width - self.bounds.size.width){
                finalRect = CGRectMake(self.superview.bounds.size.width - self.bounds.size.width, finalRect.origin.y, finalRect.size.width, finalRect.size.height);
            }
            if(self.frame.origin.y > self.superview.bounds.size.height - self.bounds.size.height){
                finalRect = CGRectMake(finalRect.origin.x, self.superview.bounds.size.height - self.bounds.size.height, finalRect.size.width, finalRect.size.height);
            }
            if(self.frame.origin.y < 20){
                finalRect = CGRectMake(finalRect.origin.x, 20, finalRect.size.width, finalRect.size.height);
            }
            
            [UIView animateWithDuration:0.2 animations:^{
                self.frame = finalRect;
            }];
        }
    }
}

- (void)updateShowUsage {
    if (self.screenUpdatesBeginTime == 0.0f) {
        self.screenUpdatesBeginTime = _displayLink.timestamp;
    } else {
        self.screenUpdatesCount += 1;
        
        CFTimeInterval screenUpdatesTime = self.displayLink.timestamp - self.screenUpdatesBeginTime;
        
        if (screenUpdatesTime >= 1.0) {
            CFTimeInterval updatesOverSecond = screenUpdatesTime - 1.0f;
            int framesOverSecond = updatesOverSecond / self.averageScreenUpdatesTime;
            
            self.screenUpdatesCount -= framesOverSecond;
            if (self.screenUpdatesCount < 0) {
                self.screenUpdatesCount = 0;
            }
            
            if(self.superview && !self.hidden){
                fpsLabel.text = [NSString stringWithFormat:@"fps %d",self.screenUpdatesCount];
                cpuLabel.text = [NSString stringWithFormat:@"cpu:%.2f%%",cpu_usage()];
                memoryLabel.text = [NSString stringWithFormat:@"%.1fM",getMemoryUsage()];
            }
            self.screenUpdatesCount = 0;
            self.screenUpdatesBeginTime = 0.0f;
        }
    }
}

 float getMemoryUsage() {
     kern_return_t status;
     mach_msg_type_number_t infoCount;
     
     struct task_basic_info basicInfo;
     infoCount = TASK_BASIC_INFO_COUNT;
     status = task_info(current_task(),
                        TASK_BASIC_INFO,
                        (task_info_t)&basicInfo,
                        &infoCount);
     if (status != KERN_SUCCESS) {
         return 0.0f;
     }
     
     return basicInfo.resident_size/1000000.0;
}

float cpu_usage() {
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < (int)thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    }
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

- (void)showView {
    if(!self.superview || self.superview == [UIApplication sharedApplication].keyWindow){
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }else{
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self];
    }
}

@end
