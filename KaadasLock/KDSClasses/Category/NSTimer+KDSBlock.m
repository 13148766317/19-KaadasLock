//
//  NSTimer+KDSBlock.m
//  lock
//
//  Created by orange on 2018/12/24.
//  Copyright © 2018年 zhao. All rights reserved.
//

#import "NSTimer+KDSBlock.h"

@implementation NSTimer (KDSBlock)

+ (NSTimer *)kdsScheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer * _Nonnull))block
{
    if (@available(iOS 10.0, *))
    {
        return [NSTimer scheduledTimerWithTimeInterval:interval repeats:repeats block:block];
    }
    else
    {
        return [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(timerAction:) userInfo:[block copy] repeats:repeats];
    }
}

+ (void)timerAction:(NSTimer *)timer
{
    void (^block)(NSTimer *timer) = timer.userInfo;
    !block ?: block(timer);
}

@end
