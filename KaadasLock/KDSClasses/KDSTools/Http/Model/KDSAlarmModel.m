//
//  KDSAlarmModel.m
//  xiaokaizhineng
//
//  Created by orange on 2019/2/27.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSAlarmModel.h"

@implementation KDSAlarmModel

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) return NO;
    if (object == self) return YES;
    KDSAlarmModel *model = object;
    return [self.devName isEqualToString:model.devName] && self.warningType==model.warningType && self.warningTime==model.warningTime;
}

- (NSUInteger)hash
{
    NSString *combine = [NSString stringWithFormat:@"%d%.6lf", self.warningType, self.warningTime];
    NSUInteger hash = [self.devName stringByAppendingString:combine].hash;
    return hash;
}

@end
