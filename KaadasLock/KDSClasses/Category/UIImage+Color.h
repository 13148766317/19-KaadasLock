//
//  UIImage+Color.h
//  KaadasLock
//
//  Created by orange on 2019/3/27.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Color)

+ (UIImage *)imageWithSize:(CGSize)size color:(UIColor *)color;
+ (UIImage *)grayImage:(UIImage *)sourceImage;

@end

NS_ASSUME_NONNULL_END
