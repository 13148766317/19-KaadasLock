//
//  UIButton+Color.h
//  KaadasLock
//
//  Created by zhaona on 2019/3/29.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (Color)

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

+ (UIImage *)imageWithColor:(UIColor *)color ;

@end

NS_ASSUME_NONNULL_END
