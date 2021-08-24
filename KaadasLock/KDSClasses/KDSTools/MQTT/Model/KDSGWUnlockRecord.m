//
//  KDSGWUnlockRecord.m
//  KaadasLock
//
//  Created by orange on 2019/4/15.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSGWUnlockRecord.h"

@implementation KDSGWUnlockRecord

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) return NO;
    if (object == self) return YES;
    KDSGWUnlockRecord *rec = object;
    return [self.lockName isEqualToString:rec.lockName] && (self.user_num.intValue == rec.user_num.intValue) && (self.open_type.intValue == rec.open_type.intValue) && (self.open_time == rec.open_time);
}

- (NSUInteger)hash
{
    NSString *combine = [NSString stringWithFormat:@"%@%d%d%.6lf", self.lockName, self.user_num.intValue, self.open_type.intValue, self.open_time];
    return combine.hash;
}

@end
