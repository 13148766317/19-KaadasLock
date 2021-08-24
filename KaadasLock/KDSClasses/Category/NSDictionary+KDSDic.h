//
//  NSDictionary+KDSDic.h
//  KaadasLock
//
//  Created by zhaona on 2020/4/29.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (KDSDic)
//model转化为字典
- (NSDictionary *)dicFromObject:(NSObject *)object;

/**
 从字典里取NSInteger(内带判空)

 @param key 字典Key值
 @return NSInteger
 */
- (NSInteger)integerValueForKey:(id)key;

/**
 从字典里取int(内带判空)
 
 @param key 字典Key值
 @return int
 */
- (int)intValueForKey:(id)key;

/**
 从字典里取long long(内带判空)
 
 @param key 字典Key值
 @return long long
 */
- (long long)longlongValueForKey:(id)key;

/**
 从字典里取BOOL(内带判空)
 
 @param key 字典Key值
 @return BOOL
 */
- (BOOL)boolValueForKey:(id)key;

/**
 从字典里取float(内带判空)
 
 @param key 字典Key值
 @return float
 */
- (float)floatValueForKey:(id)key;

/**
 从字典里取字符串(内带判空)
 
 @param key 字典Key值
 @return NSString
 */
- (NSString *)stringValueForKey:(id)key;

/**
 从字典里取数组(内带判空)
 
 @param key 字典Key值
 @return NSArray
 */
- (NSArray *)arrayValueForKey:(id)key;

/**
 从字典里取可变数组(内带判空)
 
 @param key 字典Key值
 @return NSMutableArray
 */
- (NSMutableArray *)mutableArrayValueForKey:(NSString *)key;

/**
 从字典里取字典(内带判空)
 
 @param key 字典Key值
 @return NSDictionary
 */
- (NSDictionary *)dictionaryValueForKey:(id)key;


@end

NS_ASSUME_NONNULL_END
