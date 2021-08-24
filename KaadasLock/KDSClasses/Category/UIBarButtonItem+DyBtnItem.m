//
//  UIBarButtonItem+DyBtnItem.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/17.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "UIBarButtonItem+DyBtnItem.h"

@implementation UIBarButtonItem (DyBtnItem)

+ (instancetype)itemWithNorImage:(NSString *)image highImage:(NSString *)highImage target:(id)target action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:highImage] forState:UIControlStateHighlighted];
    [btn sizeToFit];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIView *containVew = [[UIView alloc] initWithFrame:btn.bounds];
    [containVew addSubview:btn];
    return [[UIBarButtonItem alloc]initWithCustomView:containVew];
}


@end
