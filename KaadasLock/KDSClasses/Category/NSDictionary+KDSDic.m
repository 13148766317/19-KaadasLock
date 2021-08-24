//
//  NSDictionary+KDSDic.m
//  KaadasLock
//
//  Created by zhaona on 2020/4/29.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "NSDictionary+KDSDic.h"
#import <objc/runtime.h>

@implementation NSDictionary (KDSDic)

+ (void)load {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        id obj = [[self alloc] init];
        [obj swizzleMethod:@selector(setObject:forKey:)withMethod:@selector(safe_setObject:forKey:)];
    });
}

- (void)swizzleMethod:(SEL)origSelector withMethod:(SEL)newSelector
{
    //
    Class class = [self class];
    
    /** 得到类的实例方法 class_getInstanceMethod(Class  _Nullable __unsafe_unretained cls, SEL  _Nonnull name)
     _Nullable __unsafe_unretained cls  那个类
     _Nonnull name 按个方法
     
     补充: class_getClassMethod 得到类的 类方法
     */
    // 必须两个Method都要拿到
    Method originalMethod = class_getInstanceMethod(class, origSelector);
    Method swizzledMethod = class_getInstanceMethod(class, newSelector);

    /** 动态添加方法 class_addMethod(Class  _Nullable __unsafe_unretained cls, SEL  _Nonnull name, IMP  _Nonnull imp, const char * _Nullable types)
        class_addMethod  是相对于实现来的说的，将本来不存在于被操作的Class里的newMethod的实现添加在被操作的Class里，并使用origSel作为其选择子
     _Nonnull name  原方法选择子，
     _Nonnull imp 新方法选择子，
     
     */
    // 如果发现方法已经存在，会失败返回，也可以用来做检查用,我们这里是为了避免源方法没有实现的情况;如果方法没有存在,我们则先尝试添加被替换的方法的实现
    BOOL didAddMethod = class_addMethod(class,origSelector,method_getImplementation(swizzledMethod),method_getTypeEncoding(swizzledMethod));
    
    // 如果返回成功:则说明被替换方法没有存在.也就是被替换的方法没有被实现,我们需要先把这个方法实现,然后再执行我们想要的效果,用我们自定义的方法去替换被替换的方法. 这里使用到的是class_replaceMethod这个方法. class_replaceMethod本身会尝试调用class_addMethod和method_setImplementation，所以直接调用class_replaceMethod就可以了)
    if (didAddMethod) {
        class_replaceMethod(class,newSelector,method_getImplementation(originalMethod),method_getTypeEncoding(originalMethod));
        
    } else { // 如果返回失败:则说明被替换方法已经存在.直接将两个方法的实现交换即
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}



- (void)safe_setObject:(id)value forKey:(NSString *)key {
    
    if (value) {
        [self safe_setObject:value forKey:key];
     }else {
    
         NSLog(@"[NSMutableDictionarysetObject: forKey:], Object cannot be nil");
     }
}



- (NSDictionary *)dicFromObject:(NSObject *)object
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
      unsigned int count;
      objc_property_t *propertyList = class_copyPropertyList([object class], &count);
      
      for (int i = 0; i < count; i++) {
          objc_property_t property = propertyList[i];
          const char *cName = property_getName(property);
          NSString *name = [NSString stringWithUTF8String:cName];
          NSObject *value = [object valueForKey:name];//valueForKey返回的数字和字符串都是对象
          if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
              //string , bool, int ,NSinteger
              [dic setObject:value forKey:name];
          } else if ([value isKindOfClass:[NSArray class]]) {
              //数组或字典
              [dic setObject:[self arrayWithObject:value] forKey:name];
          } else if ([value isKindOfClass:[NSDictionary class]]) {
              //数组或字典
              [dic setObject:[self dicWithObject:value] forKey:name];
          } else if (value == nil) {
              //null
              //[dic setObject:[NSNull null] forKey:name];//这行可以注释掉?????
          } else {
              //model
              [dic setObject:[self dicFromObject:value] forKey:name];
          }
      }
      
      return [dic copy];
}

- (NSArray *)arrayWithObject:(id)object {
    //数组
    NSMutableArray *array = [NSMutableArray array];
    NSArray *originArr = (NSArray *)object;
    if ([originArr isKindOfClass:[NSArray class]]) {
        for (NSObject *object in originArr) {
            if ([object isKindOfClass:[NSString class]]||[object isKindOfClass:[NSNumber class]]) {
                //string , bool, int ,NSinteger
                [array addObject:object];
            } else if ([object isKindOfClass:[NSArray class]]) {
                //数组或字典
                [array addObject:[self arrayWithObject:object]];
            } else if ([object isKindOfClass:[NSDictionary class]]) {
                //数组或字典
                [array addObject:[self dicWithObject:object]];
            } else {
                //model
                [array addObject:[self dicFromObject:object]];
            }
        }
        return [array copy];
    }
    return array.copy;
}

- (NSDictionary *)dicWithObject:(id)object {
    //字典
    NSDictionary *originDic = (NSDictionary *)object;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if ([object isKindOfClass:[NSDictionary class]]) {
        for (NSString *key in originDic.allKeys) {
            id object = [originDic objectForKey:key];
            if ([object isKindOfClass:[NSString class]]||[object isKindOfClass:[NSNumber class]]) {
                //string , bool, int ,NSinteger
                [dic setObject:object forKey:key];
            } else if ([object isKindOfClass:[NSArray class]]) {
                //数组或字典
                [dic setObject:[self arrayWithObject:object] forKey:key];
            } else if ([object isKindOfClass:[NSDictionary class]]) {
                //数组或字典
                [dic setObject:[self dicWithObject:object] forKey:key];
            } else {
                //model
                [dic setObject:[self dicFromObject:object] forKey:key];
            }
        }
        return [dic copy];
    }
    return dic.copy;
}

- (NSInteger)integerValueForKey:(id)key {
    id value = [self notNullValueForKey:key];
    return value == nil ? 0 : [value integerValue];
}

- (int)intValueForKey:(id)key {
    id value = [self notNullValueForKey:key];
    return value == nil ? 0 : [value intValue];
}


- (long long)longlongValueForKey:(id)key {
    id value = [self notNullValueForKey:key];
    return value == nil ? 0 : [value longLongValue];
}

- (BOOL)boolValueForKey:(id)key {
    id value = [self notNullValueForKey:key];
    return value == nil ? NO : [value boolValue];
}

- (float)floatValueForKey:(id)key {
    id value = [self notNullValueForKey:key];
    return value == nil ? NO : [value floatValue];
}

- (NSString *)stringValueForKey:(id)key {
    return [self notNullValueForKey:key];
}

- (NSArray *)arrayValueForKey:(id)key {
    id value = [self notNullValueForKey:key];
    if(![value isKindOfClass:[NSArray class]]) {
        return nil;
    }
    return value;
}

- (NSMutableArray*)mutableArrayValueForKey:(NSString *)key {
    id value = [self notNullValueForKey:key];
    if(![value isKindOfClass:[NSMutableArray class]]) {
        return nil;
    }
    return value;
}

- (NSDictionary *)dictionaryValueForKey:(id)key {
    id value = [self notNullValueForKey:key];
    if(![value isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return value;
}

#pragma mark 判断是否null
- (BOOL)isNullValue:(id)value {
    return [value isEqual:[NSNull null]];
}

- (id)notNullValueForKey:(id)key {
    id value = [self objectForKey:key];
    if([self isNullValue:value]) {
        return nil;
    }
    return value;
}

@end
