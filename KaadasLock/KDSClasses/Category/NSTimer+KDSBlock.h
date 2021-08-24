//
//  NSTimer+KDSBlock.h
//  lock
//
//  Created by orange on 2018/12/24.
//  Copyright © 2018年 zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (KDSBlock)

/**
 *@abstract 创建一个支持block的NSTimer。
 *@param interval 定时时间间隔，秒。
 *@param repeats 是否重复。
 *@param block 定时执行的代码块，参数timer是该方法返回的对象。
 *@return 定时器对象。
 */
+ (NSTimer *)kdsScheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block;

@end

NS_ASSUME_NONNULL_END
