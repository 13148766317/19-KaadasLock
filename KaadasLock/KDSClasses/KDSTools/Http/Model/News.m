//
//  News.m
//  kaadas
//
//  Created by ise on 16/10/8.
//  Copyright © 2016年 ise. All rights reserved.
//

#import "News.h"

@implementation News

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) return NO;
    if (object == self) return YES;
    News *obj = (News *)object;
    return [self.user_num isEqualToString:obj.user_num] && [self.open_time isEqualToString:obj.open_time] && [self.open_type isEqualToString:obj.open_type] && [self.nickName isEqualToString:obj.nickName];
}

@end
