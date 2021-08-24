//
//  KDSAlertController.h
//  KaadasLock
//
//  Created by orange on 2019/3/28.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSAlertController : UIViewController

///仿UIAlertController，但是暂时没有action。title不换行显示，文字长度限制230，因此不要太长。message换行显示。
+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message;
///参考UIAlertController title
@property (nullable, nonatomic, copy) NSString *title;
///title的文字颜色。
@property (nonatomic, strong, null_resettable) UIColor *titleColor;
///参考UIAlertController message
@property (nullable, nonatomic, copy) NSString *message;
///message的文字颜色
@property (nonatomic, strong, null_resettable) UIColor *messageColor;


@end

NS_ASSUME_NONNULL_END
