//
//  KDSUnlockAttr.m
//  xiaokaizhineng
//
//  Created by orange on 2019/3/12.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSUnlockAttr.h"

@implementation KDSUnlockAttr

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.bleName forKey:@"bleName"];
    [aCoder encodeObject:self.unlockType forKey:@"unlockType"];
    [aCoder encodeInt:self.number forKey:@"number"];
    [aCoder encodeObject:self.nickname forKey:@"nickname"];
    [aCoder encodeObject:self.type forKey:@"type"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self.bleName = [aDecoder decodeObjectForKey:@"bleName"];
    self.unlockType = [aDecoder decodeObjectForKey:@"unlockType"];
    self.number = [aDecoder decodeIntForKey:@"number"];
    self.nickname = [aDecoder decodeObjectForKey:@"nickname"];
    self.type = [aDecoder decodeObjectForKey:@"type"];
    return self;
}

- (NSString *)nickname
{
    if (!_nickname.length)
    {
        return [NSString stringWithFormat:@"%02d", self.number];
    }
    return _nickname;
}

- (NSString *)type
{
    return _unlockType.length ? _unlockType : @"";
}

@end
