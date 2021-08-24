//
//  KDSGWLockSchedule.m
//  KaadasLock
//
//  Created by orange on 2019/4/16.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSGWLockSchedule.h"
#import <MJExtension/MJExtension.h>

@implementation KDSGWLockSchedule

+ (NSArray *)mj_ignoredPropertyNames
{
    return @[@"status", @"scheduleStatus"];
}

//+ (NSDictionary *)mj_replacedKeyFromPropertyName
//{
//    return @{@"mask":@"daysMask", @"beginH":@"startHour", @"beginMin":@"startMinute", @"endH":@"endHour", @"endMin":@"endMinute", @"beginTime":@"zigBeeLocalStartTime", @"endTime":@"zigBeeLocalEndTime"};
//}

@end
