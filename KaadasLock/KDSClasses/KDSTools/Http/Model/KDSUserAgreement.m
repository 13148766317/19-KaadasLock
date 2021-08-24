//
//  KDSUserAgreement.m
//  xiaokaizhineng
//
//  Created by orange on 2019/2/25.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSUserAgreement.h"

@implementation KDSUserAgreement

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self._id forKey:@"_id"];
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.version forKey:@"version"];
    [aCoder encodeObject:self.tag forKey:@"tag"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self._id = [aDecoder decodeObjectForKey:@"_id"];
    self.content = [aDecoder decodeObjectForKey:@"content"];
    self.version = [aDecoder decodeObjectForKey:@"version"];
    self.tag = [aDecoder decodeObjectForKey:@"tag"];
    return self;
}

@end
