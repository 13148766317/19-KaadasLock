//
//  AlarmMessageModel.m
//  lock
//
//  Created by wzr on 2018/8/9.
//  Copyright © 2018年 zhao. All rights reserved.
//

#import "AlarmMessageModel.h"

@implementation AlarmMessageModel


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.photoImg = [aDecoder decodeObjectForKey:@"pirPicArrayData"];
        self.timeStr = [aDecoder decodeObjectForKey:@"picDate"];
        self.isChecked = [aDecoder decodeObjectForKey:@"isChecked"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aDecoder
{
    [aDecoder encodeObject:self.photoImg forKey:@"pirPicArrayData"];
    [aDecoder encodeObject:self.timeStr forKey:@"picDate"];
    [aDecoder encodeObject:self.isChecked forKey:@"isChecked"];
}

@end
