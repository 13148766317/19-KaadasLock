//
//  UIView+Extension.h
//  lock
//
//  Created by zhao on 17/1/19.
//  Copyright © 2017年 zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

/**
 *@brief 将消息接收者的文本去除首尾空格换行后修剪到指定的长度。该方法暂时只适用于UITextField和UITextView。
 *@param length 指定的文本长度，单位字节，UTF-8编码。如果消息接收者的文本小于此长度，则不作修剪；如果此值小于0，则默认长度为50.
 */
- (void)trimTextToLength:(NSInteger)length;

@end
