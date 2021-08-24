//
//  KDSLockPwdInfo.m
//  xiaokaizhineng
//
//  Created by orange on 2019/1/29.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSLockPwdInfo.h"
//#import "MJExtension.h"

@implementation KDSLockPwdInfo

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"number":@"num", @"nickname":@"numNickname", @"jurisdiction":@"open_purview", @"beginDate":@"datestart", @"endDate":@"dateend"};
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]])
    {
        return NO;
    }
    if (self == object) return YES;
    return  [self.number isEqualToString:((KDSLockPwdInfo *)object).number];
}

- (NSUInteger)hash
{
    return self.number.hash;
}

@end
