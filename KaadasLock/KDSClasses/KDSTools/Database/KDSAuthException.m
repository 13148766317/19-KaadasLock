//
//  KDSAuthException.m
//  xiaokaizhineng
//
//  Created by orange on 2019/2/25.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSAuthException.h"

@implementation KDSAuthException

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.bleName forKey:@"bleName"];
    [aCoder encodeObject:self.nickname forKey:@"nickname"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeInt:self.code forKey:@"code"];
    [aCoder encodeObject:self.dateString forKey:@"dateString"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self.bleName = [aDecoder decodeObjectForKey:@"bleName"];
    self.nickname = [aDecoder decodeObjectForKey:@"nickname"];
    self.date = [aDecoder decodeObjectForKey:@"date"];
    self.code = [aDecoder decodeIntForKey:@"code"];
    self.dateString = [aDecoder decodeObjectForKey:@"dateString"];
    return self;
}

@end
