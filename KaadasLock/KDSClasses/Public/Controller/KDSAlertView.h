//
//  KDSAlertView.h
//  KaadasLock
//
//  Created by zhaoxueping on 2020/10/26.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSAlertView : UIView

+ (instancetype)alertControllerWithTitle:(nullable NSString *)title;
///参考UIAlertController title
@property (nullable, nonatomic, copy) NSString *title;
///title的文字颜色。
@property (nonatomic, strong, null_resettable) UIColor *titleColor;

@end

NS_ASSUME_NONNULL_END
