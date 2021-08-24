//
//  NSDate+KDS.m
//  lock
//
//  Created by zhaowz on 2018/8/1.
//  Copyright © 2018年 zhao. All rights reserved.
//

#import "NSDate+KDS.h"

@implementation NSDate (KDS)
+(NSString*)GetStringWithDate:(NSDate*)date Formate:(NSString*)fm{
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    formatter.dateFormat=fm;
   NSString*returnStr= [formatter stringFromDate:date];
    if (date&&!returnStr) {
        NSLog(@"warning：传人的时间格式：[%@]可能不正确，请检查",fm);
    }
    return returnStr;
}
/**,从某个时间点，加一个时间戳后，得到新的时间字符串 fm:yyyy-mm-dd HH:mm:ss.SS*/
+(NSString*)GetDateStringFromBeiginDate:(NSString*)dateStr TimeInterval:(NSTimeInterval)time Formate:(NSString*)fm{
    NSDateFormatter*formatter=[[NSDateFormatter alloc]init];
    formatter.dateFormat=fm;
    NSDate*date=[formatter dateFromString:dateStr];
    NSDate*returndate =[NSDate  dateWithTimeInterval:time sinceDate:date];
    NSString *dStr=[formatter stringFromDate:returndate];
    if ((dateStr&&!date)||(returndate&&!dStr)) {
        NSLog(@"warning：传人的时间格式：[%@]可能不正确，请检查",fm);
    }

    return dStr;
}
/**得到两个时间之间的时间差*/
+(int)GetTimeIntervalFromDateStr:(NSString*)dateStr1 toDateStr:(NSString*)dateStr2 Formate:(NSString*)fm{
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    formatter.dateFormat=fm;
    NSDate*date1=[formatter dateFromString:dateStr1];
    NSDate*date2=nil;
    if (!dateStr2) {
        date2=[NSDate date];
    }else{
     date2=[formatter dateFromString:dateStr2];
    }
    if ((dateStr1&&!date1)||(dateStr2&&!date2)) {
        NSLog(@"warning：传人的时间格式：[%@]可能不正确，请检查",fm);
    }
  return (int)[date2 timeIntervalSinceDate:date1];
}
#pragma mark - String Properties
- (NSString *) stringWithFormat: (NSString *) format
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    //    formatter.locale = [NSLocale currentLocale]; // Necessary?
    formatter.dateFormat = format;
    return [formatter stringFromDate:self];
}

@end
