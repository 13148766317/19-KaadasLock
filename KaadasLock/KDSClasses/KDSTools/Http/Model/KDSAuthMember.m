//
//  KDSAuthMember.m
//  xiaokaizhineng
//
//  Created by orange on 2019/2/28.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSAuthMember.h"

@implementation KDSAuthMember

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"jurisdiction":@"open_purview", @"beginDate":@"datestart", @"endDate":@"dateend"};
}

- (NSArray<NSString *> *)items
{
    if (_items.count == 7) return _items;
    return @[@"0", @"0", @"0", @"0", @"0", @"0", @"0"];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self._id forKey:@"_id"];
    [aCoder encodeObject:self.adminname forKey:@"adminname"];
    [aCoder encodeObject:self.uname forKey:@"uname"];
    [aCoder encodeObject:self.unickname forKey:@"unickname"];
    [aCoder encodeObject:self.userNickname forKey:@"userNickname"];
    [aCoder encodeObject:self.jurisdiction forKey:@"jurisdiction"];
    [aCoder encodeObject:self.items forKey:@"items"];
    [aCoder encodeObject:self.beginDate forKey:@"beginDate"];
    [aCoder encodeObject:self.endDate forKey:@"endDate"];
    [aCoder encodeDouble:self.createTime forKey:@"createTime"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self._id = [aDecoder decodeObjectForKey:@"_id"];
    self.adminname = [aDecoder decodeObjectForKey:@"adminname"];
    self.uname = [aDecoder decodeObjectForKey:@"uname"];
    self.unickname = [aDecoder decodeObjectForKey:@"unickname"];
    self.userNickname =[aDecoder decodeObjectForKey:@"userNickname"];
    self.jurisdiction = [aDecoder decodeObjectForKey:@"jurisdiction"];
    self.items = [aDecoder decodeObjectForKey:@"items"];
    self.beginDate = [aDecoder decodeObjectForKey:@"beginDate"];
    self.endDate = [aDecoder decodeObjectForKey:@"endDate"];
    self.createTime = [aDecoder decodeDoubleForKey:@"createTime"];
    return self;
}

@end
