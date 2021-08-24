//
//  NSString+extension.h
//  xiaokaizhineng
//
//  Created by orange on 2019/1/24.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (extension)

///字符串的md5。
@property (nonatomic, strong, readonly) NSString *md5;
///调用系统的接口生成一个UUID字符串。
@property (nonatomic, strong, class, readonly) NSString *uuid;
///SHA256加密
+ (NSString*)sha256HashFor:(NSString *)input;
///byte数组转成int类型
+(long long int)bytesToIntWithBytes:(Byte[_Nullable])byte offset:(int)offset;
/// NSData转int
+ (int)data2Int:(NSData *)data;
///10进制转16进制
+(NSString *)ToHex:(long long int)tmpid;
///去掉字符串两端的空格以及回车
+(NSString *)removeSpaceAndNewline:(NSString *)str;
///时间的秒数转换成时分秒
+ (NSString *)timeFormatted:(int)totalSeconds;
///根据周期数组转成字符串
+ (NSString *)getWeekStrWithWeekDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
