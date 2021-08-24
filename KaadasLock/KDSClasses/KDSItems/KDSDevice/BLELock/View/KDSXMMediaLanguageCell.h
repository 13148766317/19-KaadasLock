//
//  KDSXMMediaLanguageCell.h
//  KaadasLock
//
//  Created by zhaoxueping on 2020/10/27.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSXMMediaLanguageCell : UITableViewCell
///cell的ID
@property (nonatomic,readonly,copy,class)NSString * ID;
///语言描述：中文/英文
@property (nonatomic,strong)UILabel * titleNameLb;
///复选框
@property (nonatomic,strong)UIButton * selectBtn;
///语言的图标
@property (nonatomic,strong)UIImageView * languaImagIcon;
///是否隐藏分割线，默认否。
@property (nonatomic, assign) BOOL hideSeparator;

@end

NS_ASSUME_NONNULL_END
