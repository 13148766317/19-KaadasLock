//
//  KDSSysMessage.m
//  xiaokaizhineng
//
//  Created by orange on 2019/3/7.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSSysMessage.h"

@implementation KDSSysMessage

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self._id forKey:@"_id"];
    [aCoder encodeInt:self.type forKey:@"type"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeDouble:self.createTime forKey:@"createTime"];
    [aCoder encodeBool:self.deleted forKey:@"deleted"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self._id = [aDecoder decodeObjectForKey:@"_id"];
    self.type = [aDecoder decodeIntForKey:@"type"];
    self.title = [aDecoder decodeObjectForKey:@"title"];
    self.content = [aDecoder decodeObjectForKey:@"content"];
    self.createTime = [aDecoder decodeDoubleForKey:@"createTime"];
    self.deleted = [aDecoder decodeBoolForKey:@"deleted"];
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) return NO;
    if (object == self) return YES;
    return [self._id isEqualToString:((KDSSysMessage *)object)._id];
}

- (NSUInteger)hash
{
    return self._id.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@%d%@%@%lf", self._id, self.type, self.title, self.content, self.createTime];
}

@end
