//
//  KDSBleAssistant.h
//  KaadasLock
//
//  Created by orange on 2019/6/27.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///与蓝牙核心功能无关的功能放到这里实现。比如数制转换、提取数据等。
@interface KDSBleAssistant : NSObject

/**
 *@brief 从蓝牙广播名称中提取系统ID。实际是从Mac地址提取，广播名称后12位必须包含蓝牙的Mac地址，否则返回0长度的对象。
 *@param advName 蓝牙广播名称。
 *@return 从蓝牙Mac地址中提取的系统ID。如果参数正确，返回的数据长度应该为8个字节。
 */
+ (NSData *)extractSystemIDFromAdvName:(NSString *)advName;

/**data转16进制字符串*/
+ (NSString*)convertDataToHexStr:(NSData *)data;

/**
 *@abstract 16进制字符串转换为NSData对象。
 *@param str 16进制字符串，例如"b0f33a6"。
 *@return NSData呈现，例如"b0f33a6" -> <0b0f33a6>。参数不是字符串或者长度为0返回长度为0的对象。
 */
+ (NSData *)convertHexStrToData:(NSString *)str;
/**
 *@abstract 普通字符串转十六进制字符串。
 */
+ (NSString *)hexStringFromString:(NSString *)string;

/**
 *@abstract 将顺序包含yyyyMMddHHmmss(例如2019年01月17日13:27:30)信息的字符串提取为统一的格式。如果缺省会默认为字符'0'。
 *@param date 要提取的日期字符串。
 *@return 格式为yyyyMMddHHmmss的日期字符串。
 */
+ (NSString *)extractDateString:(NSString *)date;

/**
 *@brief 对NSData对象逐字节(无符号类型)求和。
 *@param data 求和的对象。
 *@return 字节和。如果data为nil或者空数据，返回0.
 */
+ (int)sumOfDataThroughoutBytes:(NSData *)data;
///转化无效data数据
+(NSString *)convertToNSString:(NSData *)data;
///data转成ip地址
+ (NSString *) NSDataToIP:(NSData *)ip;
///NSData转uint16_t
+ (uint16_t) dataToUInt16:(NSData *)data;


@end

NS_ASSUME_NONNULL_END
