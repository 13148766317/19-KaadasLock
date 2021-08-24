//
//  NSDate+KDS.h
//  lock
//
//  Created by zhaowz on 2018/8/1.
//  Copyright © 2018年 zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (KDS)
/**fm:yyyy-mm-dd HH:mm:ss.SS*/
+(NSString*)GetStringWithDate:(NSDate*)date Formate:(NSString*)fm;
/**,从某个时间点，加一个时间戳后，得到新的时间字符串 fm:yyyy-mm-dd HH:mm:ss.SS*/
+(NSString*)GetDateStringFromBeiginDate:(NSString*)dateStr TimeInterval:(NSTimeInterval)time Formate:(NSString*)fm;
/**得到两个时间之间的时间差,date2传nil表示当前时间*/
+(int)GetTimeIntervalFromDateStr:(NSString*)dateStr1 toDateStr:(NSString*)dateStr2 Formate:(NSString*)fm;
- (NSString *) stringWithFormat: (NSString *) format;
@end
