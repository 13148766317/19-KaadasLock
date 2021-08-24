//
//  KDSMediaSettingCell.h
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/17.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSMediaSettingCell : UITableViewCell

///左边的标题。
@property (nonatomic, strong, nullable) NSString *title;
///右边的子标题。
@property (nonatomic, strong, nullable) NSString *subtitle;
///左边下方说明标题。
@property (nonatomic, strong, nullable) NSString *explain;
///是否隐藏switch控件，默认隐藏。如果显示该控件，则会隐藏子标题和右边的箭头。
@property (nonatomic, assign) BOOL hideSwitch;
///如果switch控件没有隐藏，设置或获取switch控件的开关状态，YES开，NO关，否则不起作用。
@property (nonatomic, assign, getter=isSwitchOn) BOOL switchOn;
///如果switch控件没有隐藏，设置或获取switch控件的可用状态，YES开，NO关，否则不起作用。
@property (nonatomic, assign, getter=isSwitchOn) BOOL switchEnable;
///是否隐藏分割线，默认否。
@property (nonatomic, assign) BOOL hideSeparator;
///是否隐藏箭头，默认否。隐藏时会使得子标题右对齐到箭头右边。
@property (nonatomic, assign) BOOL hideArrow;
///开关状态改变执行的回调。
@property (nonatomic, copy, nullable) void(^switchXMStateDidChangeBlock) (UISwitch *sender);
///容器视图。
@property (nonatomic, strong) UIView *containerView;

@end

NS_ASSUME_NONNULL_END
