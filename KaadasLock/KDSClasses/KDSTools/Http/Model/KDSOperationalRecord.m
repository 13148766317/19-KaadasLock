//
//  KDSOperationalRecord.m
//  xiaokaizhineng
//
//  Created by zhaona on 2019/7/30.
//  Copyright © 2019 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSOperationalRecord.h"

@implementation KDSOperationalRecord

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    //key为模型属性值
    return @{
             @"lockName":@"devName",
             @"open_type":@"eventCode",
             @"open_time":@"eventTime",
             @"user_num":@"userNum",
             };
}
- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) return NO;
    if (object == self) return YES;
    KDSOperationalRecord *obj = (KDSOperationalRecord *)object;
    return [self.user_num isEqualToString:obj.user_num] && [self.open_time isEqualToString:obj.open_time] && [self.open_type isEqualToString:obj.open_type];
}

@end
