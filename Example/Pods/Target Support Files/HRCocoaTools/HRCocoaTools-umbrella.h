#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "HRSimpleAnimation.h"
#import "NSDate+hrExt.h"
#import "NSFileManager+hrExt.h"
#import "NSString+Util.h"
#import "NSURL+hrExt.h"
#import "UIColor+hrExt.h"
#import "UIImage+hrExt.h"
#import "UIView+roundType.h"
#import "HRMediaUtil.h"
#import "NSData+imageFormat.h"
#import "HRBaseModel.h"
#import "HRDevice.h"
#import "HRImageCutViewController.h"
#import "HRMonitorView.h"
#import "HRNetworkStatus.h"

FOUNDATION_EXPORT double HRCocoaToolsVersionNumber;
FOUNDATION_EXPORT const unsigned char HRCocoaToolsVersionString[];

