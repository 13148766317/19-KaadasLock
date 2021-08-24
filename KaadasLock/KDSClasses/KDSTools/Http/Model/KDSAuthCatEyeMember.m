//
//  KDSAuthCatEyeMember.m
//  KaadasLock
//
//  Created by zhaona on 2019/7/1.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSAuthCatEyeMember.h"

@implementation KDSAuthCatEyeMember

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self._id forKey:@"_id"];
    [aCoder encodeObject:self.adminuid forKey:@"adminuid"];
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.userNickname forKey:@"userNickname"];
    [aCoder encodeObject:self.time forKey:@"time"];

}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self._id = [aDecoder decodeObjectForKey:@"_id"];
    self.adminuid = [aDecoder decodeObjectForKey:@"adminuid"];
    self.userNickname = [aDecoder decodeObjectForKey:@"userNickname"];
    self.username = [aDecoder decodeObjectForKey:@"username"];
    self.time = [aDecoder decodeObjectForKey:@"time"];
    return self;
}
@end
