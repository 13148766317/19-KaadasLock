//
//  KDSFAQ.m
//  xiaokaizhineng
//
//  Created by orange on 2019/3/7.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSFAQ.h"

@implementation KDSFAQ

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self._id forKey:@"_id"];
    [aCoder encodeObject:self.question forKey:@"question"];
    [aCoder encodeObject:self.answer forKey:@"answer"];
    [aCoder encodeInt:self.sortNum forKey:@"sortNum"];
    [aCoder encodeDouble:self.createTime forKey:@"createTime"];
    [aCoder encodeInt:self.language forKey:@"language"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self._id = [aDecoder decodeObjectForKey:@"_id"];
    self.question = [aDecoder decodeObjectForKey:@"question"];
    self.answer = [aDecoder decodeObjectForKey:@"answer"];
    self.sortNum = [aDecoder decodeIntForKey:@"sortNum"];
    self.createTime = [aDecoder decodeDoubleForKey:@"createTime"];
    self.language = [aDecoder decodeIntForKey:@"language"];
    return self;
}

- (NSString *)question
{
    return _question ?: @"";
}

- (NSString *)answer
{
    return _answer ?: @"";
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) return NO;
    if (object == self) return YES;
    return [self._id isEqualToString:((KDSFAQ *)object)._id];
}

- (NSUInteger)hash
{
    return self._id.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@%@%@%d%lf", self._id, self.question, self.answer, self.sortNum, self.createTime];
}

@end
