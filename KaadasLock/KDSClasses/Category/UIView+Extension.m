//
//  UIView+Extension.m
//  lock
//
//  Created by zhao on 17/1/19.
//  Copyright © 2017年 zhao. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)
- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)trimTextToLength:(NSInteger)length
{
    if (!([self isKindOfClass:UITextField.class] || [self isKindOfClass:UITextView.class]))
    {
        return;
    }
    if (length == 0)
    {
        ((UITextField *)self).text = nil;
        return;
    }
    id view = self;
    if ([view markedTextRange].start) return;
    NSString *string = [([view text] ?: @"") stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger maxLength = length<0 ? 50 : length;
    const char* utf8 = string.UTF8String;
    length = strlen(utf8);
    if (length <= maxLength)
    {
        ((UITextField *)self).text = string;
        return;
    }
    NSInteger i = 0;
    for (; i < length ;)
    {
        NSInteger temp = i;
        for (int j = 7; j >= 0; --j)
        {
            if (((utf8[i] >> j) & 0x1) == 0)
            {
                i += (j==7 ? 1 : 7 - j);
                break;
            }
        }
        if (i >= maxLength)
        {
            i = i>maxLength ? temp : i;
            break;
        }
    }
    char dest[i + 1];
    strncpy(dest, utf8, i);
    dest[i] = 0;
    ((UITextField *)self).text = @(dest);
}

@end
