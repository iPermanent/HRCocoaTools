//
//  HRBaseModel.m
//  HRCocoaTools
//
//  Created by zhangheng on 2019/3/28.
//

#import "HRBaseModel.h"

#import <objc/message.h>
#import <objc/runtime.h>

@interface HRBaseModel()

//属性名与对应的类型关系映射字典
@property (nonatomic, strong)NSDictionary *allPropertiesNameTypeMaps;

//生成jsonDic时排除自带的属性列表
@property (nonatomic, strong)NSArray *excludeProperties;

//反转自定义的映射表，生成jsonDic时使用
@property (nonatomic, strong)NSDictionary *reversePropertiesDic;

@end

@implementation HRBaseModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if(self){
        for(NSString *key in [dictionary allKeys]){
            id obj = [dictionary objectForKey:key];
            if(!obj || [obj isKindOfClass:[NSNull class]]){
                NSLog(@"%@ is null",key);
                obj = @"";
            }
            if([obj isKindOfClass:[NSDictionary class]]){
                [self configDicValue:obj withKey:key];
            }else if([obj isKindOfClass:[NSArray class]]){
                [self configArrayValue:obj withKey:key];
            }else{
                [self configValue:obj keyName:key];
            }
        }
    }
    return self;
}


/**
 根据对应参数设置值

 @param obj 字典里的object
 @param key 字典对应key
 */
-(void)configDicValue:(id)obj withKey:(NSString *)key{
    //获取json的key对应在内部属性名
    NSString *propertyName = [[self mapsDictionary] valueForKey:key];
    if(!propertyName){
        propertyName = key;
    }
    
    //获取runtime指定属性类型格式
    NSString *propertyTypeString = [self.allPropertiesNameTypeMaps valueForKey:propertyName];
    if([propertyTypeString hasPrefix:@"T@\""]){
        //自定义类型
        NSString *className = [propertyTypeString componentsSeparatedByString:@"\""][1];
        Class objClass = NSClassFromString(className);
        
        HRBaseModel *targetModel = [(HRBaseModel *)[objClass alloc] initWithDictionary:obj];
        
        [self setValue:targetModel forKey:propertyName];
    }else{
        NSLog(@"unknown type is %@",propertyTypeString);
    }
}

- (void)configValue:(id)value keyName:(NSString *)jsonKeyName {
    //获取json的key对应在内部属性名
    NSString *propertyName = [[self mapsDictionary] valueForKey:jsonKeyName];
    if(!propertyName){
        propertyName = jsonKeyName;
    }
    
    //获取runtime指定属性类型格式
    NSString *propertyTypeString = [self.allPropertiesNameTypeMaps valueForKey:propertyName];
    
    /*
     理论上number类型和所有基本类型的都可以直接setValue forKey
     */
    if([propertyTypeString hasPrefix:@"T@\"NSString\""]){
        [self setValue:value forKey:propertyName];
    }else if([propertyTypeString hasPrefix:@"T@\"NSNumber\""]){
        //number类型
        [self setValue:value forKey:propertyName];
    }else if([propertyTypeString hasPrefix:@"TB"]){
        //BOOL
        [self setValue:@([(NSString *)value boolValue]) forKey:propertyName];
    }else if([propertyTypeString hasPrefix:@"Td"]){
        //double
        [self setValue:@([(NSString *)value doubleValue]) forKey:propertyName];
    }else if ([propertyTypeString hasPrefix:@"Ti"]){
        //int
        [self setValue:@([(NSString *)value intValue]) forKey:propertyName];
    }else if ([propertyTypeString hasPrefix:@"Tq"]){
        [self setValue:value forKey:propertyName];
    }else{
        [self setValue:value forKey:propertyName];
    }
}

- (NSDictionary *)allPropertiesNameTypeMaps {
    if(!_allPropertiesNameTypeMaps){
        NSMutableDictionary *maps = [NSMutableDictionary new];
        unsigned int count;
        objc_property_t* props = class_copyPropertyList([self class], &count);
        for (int i = 0; i < count; i++) {
            objc_property_t property = props[i];
            const char * name = property_getName(property);
            NSString *propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            const char * type = property_getAttributes(property);
            NSString *attr = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
            
            [maps setObject:attr forKey:propertyName];
        }
        free(props);
        _allPropertiesNameTypeMaps = maps.copy;
    }
    
    return _allPropertiesNameTypeMaps;
}

//解析数组型数据
-(void)configArrayValue:(NSArray *)array withKey:(NSString *)key{
    //获取json的key对应在内部属性名
    NSString *propertyName = [[self mapsDictionary] valueForKey:key];
    if(!propertyName){
        propertyName = key;
    }
    
    NSString *arrayClassName = [[self arrayClassDictiony] valueForKey:propertyName];
    if(!arrayClassName){
        NSLog(@"class %@ 属性%@ 对应的array类未指定",NSStringFromClass([self class]),propertyName);
        return;
    }
    
    Class clazz = NSClassFromString(arrayClassName);
    if(!clazz){
        NSLog(@"%@ class undeclare",key);
    }else{
        NSMutableArray *arrayObj = [NSMutableArray new];
        for(NSDictionary *dic in array){
            id item = [[clazz alloc] initWithDictionary:dic];
            [arrayObj addObject:item];
        }
        [self setValue:arrayObj forKeyPath:key];
    }
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    NSLog(@"class:%@ key:%@ not exist",NSStringFromClass([self class]),key);
}

- (NSDictionary *)mapsDictionary {
    return @{};
}

- (NSDictionary *)arrayClassDictiony {
    return @{};
}

- (NSDictionary *)jsonDic {
    NSMutableDictionary *mutDic = [NSMutableDictionary new];
    
    unsigned int count;
    objc_property_t* props = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
        objc_property_t property = props[i];
        const char * name = property_getName(property);
        NSString *propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        if([[self excludeProperties] containsObject:propertyName]){
            //系统自带属性不需要生成
            continue;
        }
        
        id obj = [self valueForKey:propertyName];
        //设置的时候需要找json中的字段设置，以和解析统一
        if([self.reversePropertiesDic valueForKey:propertyName]){
            propertyName = [self.reversePropertiesDic objectForKey:propertyName];
        }
        if([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]){
            [mutDic setValue:obj forKey:propertyName];
        }else if([obj isKindOfClass:[NSArray class]]){
            NSMutableArray *dicArray = [NSMutableArray new];
            for(HRBaseModel *element in obj){
                [dicArray addObject:[element jsonDic]];
            }
            [mutDic setValue:dicArray.copy forKey:propertyName];
        }else{
            [mutDic setValue:[(HRBaseModel *)obj jsonDic] forKey:propertyName];
        }
    }
    free(props);
    
    return mutDic.copy;
}

- (NSArray *)excludeProperties {
    if(!_excludeProperties){
        _excludeProperties = @[@"superclass",@"hash",@"debugDescription",@"description"];
    }
    return _excludeProperties;
}

- (NSDictionary *)reversePropertiesDic {
    if(!_reversePropertiesDic){
        NSMutableDictionary *dic = [NSMutableDictionary new];
        for(NSString *jsonKey in self.mapsDictionary){
            NSString *propertyName = [self.mapsDictionary objectForKey:jsonKey];
            [dic setObject:propertyName forKey:jsonKey];
        }
        _reversePropertiesDic = dic.copy;
    }
    return _reversePropertiesDic;
}

@end
