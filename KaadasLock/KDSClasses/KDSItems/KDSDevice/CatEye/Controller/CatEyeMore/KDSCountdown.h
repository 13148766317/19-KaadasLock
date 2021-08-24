//
//  KDSCountdown.h
//  lock
//
//  Created by Frank Hu on 2018/11/23.
//  Copyright © 2018 zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSCountdown : NSObject
/**
 * 获取当前时间  格式 yyyy-MM-dd hh:mm:ss
 */
- (NSString *) getNowTimeString;
/**
 * 时间转时间戳
 */
- (long) timeStampWithDate:(NSDate *) timeDate;
/**
 * 时间戳转时间
 */
- (NSString *) dateWithTimeStamp:(long) longValue;
/**
 * 用时间戳倒计时
 * starTimeStamp 开始的时间戳
 * finishTimeStamp 结束的时间戳
 */
-(void)countDownWithStratTimeStamp:(long)starTimeStamp finishTimeStamp:(long)finishTimeStamp completeBlock:(void (^)(NSInteger day,NSInteger hour,NSInteger minute,NSInteger second))completeBlock;
/**
 * 每秒走一次，回调block
 */
-(void)countDownWithPER_SECBlock:(void (^)())PER_SECBlock;
/**
 * 销毁倒计时
 */
-(void)destoryTimer;
/**
 *
 *时间字符串转化成date
 */
- (NSDate *)dateWithStringMuitiform:(NSString *)str;
/**
 *
 *两个时间字符串的时间差:结束时间为当前时间，只需要传开始时间即可
 *
 */
-(int)timeDifferenceWithStartTime:(NSString *)startTimeStr endTime:(NSString *)endTime;

@end

NS_ASSUME_NONNULL_END
