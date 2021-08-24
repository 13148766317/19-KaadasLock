//
//  KDSPwdListModel.m
//  xiaokaizhineng
//
//  Created by wzr on 2019/2/21.
//  Copyright © 2019 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSPwdListModel.h"

@implementation KDSPwdListModel

+(NSDictionary*)mj_replacedKeyFromPropertyName{
    return @{@"user_num" :@"num",
             @"open_time":@"createTime"
             };
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self._id forKey:@"_id"];
    [aCoder encodeObject:self.nickName forKey:@"nickName"];
    [aCoder encodeObject:self.num forKey:@"num"];
    [aCoder encodeDouble:self.createTime forKey:@"createTime"];
    [aCoder encodeInteger:(NSInteger)self.pwdType forKey:@"pwdType"];
    [aCoder encodeObject:self.scheduleID forKey:@"scheduleID"];
    [aCoder encodeObject:self.pwd forKey:@"pwd"];
    [aCoder encodeObject:self.open_purview forKey:@"open_purview"];
    [aCoder encodeObject:self.items forKey:@"items"];
    [aCoder encodeObject:self.startTime forKey:@"startTime"];
    [aCoder encodeObject:self.endTime forKey:@"endTime"];
    [aCoder encodeInteger:self.type forKey:@"type"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self._id = [aDecoder decodeObjectForKey:@"_id"];
    self.nickName = [aDecoder decodeObjectForKey:@"nickName"];
    self.num = [aDecoder decodeObjectForKey:@"num"];
    self.createTime = [aDecoder decodeDoubleForKey:@"createTime"];
    self.pwdType = (KDSServerKeyTpye)[aDecoder decodeIntegerForKey:@"pwdType"];
    self.scheduleID = [aDecoder decodeObjectForKey:@"scheduleID"];
    self.pwd = [aDecoder decodeObjectForKey:@"pwd"];
    self.open_purview = [aDecoder decodeObjectForKey:@"open_purview"];
    self.items = [aDecoder decodeObjectForKey:@"items"];
    self.startTime = [aDecoder decodeObjectForKey:@"startTime"];
    self.endTime = [aDecoder decodeObjectForKey:@"endTime"];
    self.type = (KDSServerCycleTpye)[aDecoder decodeIntegerForKey:@"type"];
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]])
    {
        return NO;
    }
    if (object == self) return YES;
    KDSPwdListModel *m = (KDSPwdListModel *)object;
    return  self.num.intValue == m.num.intValue && self.pwdType == m.pwdType;
}

- (NSUInteger)hash
{
    return [NSString stringWithFormat:@"%02d", self.num.intValue].hash + (NSInteger)self.pwdType;
}

@end
