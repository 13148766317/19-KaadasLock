//
//  KDSBleRecord.h
//  KaadasLock
//
//  Created by orange on 2019/6/27.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSCodingObject.h"

NS_ASSUME_NONNULL_BEGIN

///记录类型的基类。
@interface KDSBleRecord : KDSCodingObject

/**
 *@abstract 便利初始化方法。新模块date属性需要用到NSDateFormatter比较消耗性能，因此该属性在此方法中不提取，由外部赋值。
 *@note 基类实现默认返回nil，子类必须重载来实现各自的功能。
 *@param data 蓝牙模块返回的操作记录数据。
 *@return instance。
 */
- (nullable instancetype)initWithData:(NSData *)data;

/**
 *@abstract 便利初始化方法，方便使用保存的16进制字符串创建对象后，使用isEqual:判断2个对象是否相等。date属性不会设置。
 *@note 基类实现默认返回nil，子类必须重载来实现各自的功能。
 *@param string 蓝牙模块返回的操作记录数据转换成的长度为40的16进制字符串。
 *@return instance。
 */
- (nullable instancetype)initWithHexString:(nullable NSString *)string;

///总记录条数，如果没有记录，此值为0.
@property (nonatomic, readonly) int total;
///当前记录的编号，从0开始，编号越小，记录产生时间越晚。
@property (nonatomic, readonly) int current;
///记录产生时间，格式yyyy-MM-dd HH:mm:ss，如果为空，则表明蓝牙返回值是0xFFFFFFFF。此属性一般由外部赋值。
@property (nonatomic, strong) NSString *date;
///蓝牙返回的记录二进制数据的16进制字符串。
@property (nonatomic, readonly) NSString *hexString;

@end

NS_ASSUME_NONNULL_END
