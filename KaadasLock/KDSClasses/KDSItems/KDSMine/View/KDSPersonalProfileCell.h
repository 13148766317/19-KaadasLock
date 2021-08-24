//
//  KDSPersonalProfileCell.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/1.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSPersonalProfileCell : UITableViewCell

///标题。
@property (nonatomic, strong) NSString *title;
///图片，设置这个值会将昵称、手机号标签隐藏。
@property (nonatomic, strong) UIImage *image;
///昵称，设置这个值会将图片、手机号标签隐藏。
@property (nonatomic, strong, nullable) NSString *nickname;
///账号，设置这个值会将图片、昵称、箭头隐藏。
@property (nonatomic, strong, nullable) NSString *account;
///是否是密码cell，设置为YES会将图片、昵称、账号标签隐藏。getter没什么意义。
@property (nonatomic, assign) BOOL isPwdCell;
///是否隐藏分隔线，默认否。
@property (nonatomic, assign) BOOL hideSeparator;

@end

NS_ASSUME_NONNULL_END
