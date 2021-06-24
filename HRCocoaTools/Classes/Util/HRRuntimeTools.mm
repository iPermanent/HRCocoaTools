//
//  HRRuntimeTools.m
//  HRCocoaTools
//
//  Created by Henry Zhang on 2021/6/22.
//

#import "HRRuntimeTools.h"
#import <objc/runtime.h>
#import <dlfcn.h>
#import <mach-o/ldsyms.h>
#include <mach-o/dyld.h>
#include  <mach-o/ldsyms.h>

@implementation HRRuntimeTools

+ (NSArray<NSString *> *)getLoadedClassesNameHasLoadMethod {
    NSMutableArray *classNamesArray = [NSMutableArray new];
    
    int numClasses;
    Class * classes = NULL;

    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);

    if (numClasses > 0 ){
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; i++) {
            Class cls = classes[i];
            
            //有任意筛选条件即进入条件判断
            if(classHasLoadMethod(cls)){
                NSString *className = [NSString stringWithUTF8String:class_getName(cls)];
                [classNamesArray addObject:className];
            }
            
        }
        free(classes);
    }
    
    return classNamesArray.copy;
}

+ (NSArray<NSString *> *)getCustomClassesConformsToProtocol:(Protocol *)protocol {
    NSMutableArray *classNamesArray = [NSMutableArray new];
    
    unsigned int count;
    const char **classes;
    Dl_info info;
    
    //1.获取app的路径
    dladdr(&_MH_EXECUTE_SYM, &info);
    
    //2.返回当前运行的app的所有类的名字，并传出个数
    //classes：二维数组 存放所有类的列表名称
    //count：所有的类的个数
    classes = objc_copyClassNamesForImage(info.dli_fname, &count);
    
    for (int i = 0; i < count; i++) {
        //3.遍历并打印，转换Objective-C的字符串
        NSString *className = [NSString stringWithCString:classes[i] encoding:NSUTF8StringEncoding];
        [classNamesArray addObject:className];
    }
    
    return classNamesArray.copy;
}

+ (NSArray <NSString *>*)loadedClassNames:(Class _Nullable)superClass
                        conformsToProtocol:(Protocol* _Nullable)protocol {
    
    NSMutableArray *classNames = [NSMutableArray new];
    
    int numClasses;
    Class * classes = NULL;

    classes = NULL;
    numClasses = objc_getClassList(NULL, 0);

    if (numClasses > 0 ){
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; i++) {
            Class cls = classes[i];
            
            //有任意筛选条件即进入条件判断
            if((superClass && !isMemberClass(superClass,cls)) || (protocol && !containsProtocol(protocol, cls))){
                //有条件但是并没有满足条件时，下一轮循环
                continue;
            }
            
            NSString *className = [NSString stringWithUTF8String:class_getName(cls)];
            [classNames addObject:className];
            
        }
        free(classes);
    }
    
    return classNames.copy;
}


/// 判断是否为指定类的父类
/// @param superClass 父类
/// @param targetClass 传入的类
bool isMemberClass(Class superClass,Class targetClass) {
    Class nextSuperClass = class_getSuperclass(targetClass);
    if(targetClass == superClass) return true;
    while (class_getSuperclass(nextSuperClass) != nil) {
        nextSuperClass = class_getSuperclass(nextSuperClass);
        if(nextSuperClass == superClass) return true;
    }
    
    return false;
}


/// 判断是否响应了对应的protocol，无法使用confomsToProtocol，
/// 因为获取到的所有类不一定是NSObject的子类，不一定有这个方法，还需要做消息转发比较复杂
/// @param protocol 对应的protocol
/// @param cls class
bool containsProtocol(Protocol* protocol,Class cls){
    unsigned count;
    Protocol * __unsafe_unretained *pl = class_copyProtocolList(cls, &count);

    for (unsigned i = 0; i < count; i++) {
        NSString *protocolName = [NSString stringWithUTF8String:protocol_getName(pl[i])];
        NSString *inputPlName = [NSString stringWithUTF8String:protocol_getName(protocol)];
        
        if([protocolName isEqualToString:inputPlName]){
            return true;
        }
    }
    
    free(pl);
    
    return false;
}

bool classHasLoadMethod(Class cls){
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(cls, & methodCount);
    if(methods){
        for(int j = 0; j < methodCount; ++j){
            Method method = *(methods + j);
            SEL name = method_getName(method);
            NSString *methodName = NSStringFromSelector(name);
            if([methodName isEqualToString:@"load"]){
                return true;
            }
        }
    }
    return false;
}

@end
