//
//  KDSSearchSmartHangerCell.h
//  KaadasLock
//
//  Created by Frank Hu on 2021/1/7.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 *@abstract 搜索蓝牙绑定时显示蓝牙信息的cell。
 */
@interface KDSSearchSmartHangerCell : UITableViewCell

///蓝牙名称。
@property (nonatomic, strong) NSString *bleName;
///是否已绑定。
@property (nonatomic, assign) BOOL hasBinded;
///是否隐藏cell底部的横线，默认否。
@property (nonatomic, assign) BOOL underlineHidden;
///绑定按钮点击执行的回调。
@property (nonatomic, copy, nullable) void(^bindBtnDidClickBlock) (UIButton *sender);

///蓝牙名称标签。
@property (nonatomic, strong) UILabel *nameLabel;
///下划线。
@property (nonatomic, strong) UIView *underlineView;

@end

NS_ASSUME_NONNULL_END
