//
//  KDSLockMoreSettingCell.h
//  xiaokaizhineng
//
//  Created by orange on 2019/2/14.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import <UIKit/UIKit.h>

///cell的圆角状态。
typedef NS_ENUM(NSUInteger, KDSCornerState) {
    ///没有圆角。
    KDSCornerStateNone,
    ///顶部圆角。
    KDSCornerStateTop,
    ///底部圆角。
    KDSCornerStateBottom,
};

NS_ASSUME_NONNULL_BEGIN

@interface KDSLockMoreSettingCell : UITableViewCell

///左边的标题。
@property (nonatomic, strong, nullable) NSString *title;
///右边的子标题。
@property (nonatomic, strong, nullable) NSString *subtitle;
///是否隐藏switch控件，默认隐藏。如果显示该控件，则会隐藏子标题和右边的箭头。
@property (nonatomic, assign) BOOL hideSwitch;
///如果switch控件没有隐藏，设置或获取switch控件的开关状态，YES开，NO关，否则不起作用。
@property (nonatomic, assign, getter=isSwitchOn) BOOL switchOn;
///如果switch控件没有隐藏，设置或获取switch控件的可用状态，YES开，NO关，否则不起作用。
@property (nonatomic, assign, getter=isSwitchOn) BOOL switchEnable;
///是否隐藏分割线，默认否。
@property (nonatomic, assign) BOOL hideSeparator;
///圆角状态，默认KDSCornerStateNone。
@property (nonatomic, assign) KDSCornerState cornerState;
///是否隐藏箭头，默认否。隐藏时会使得子标题右对齐到箭头右边。
@property (nonatomic, assign) BOOL hideArrow;
///开关状态改变执行的回调。
@property (nonatomic, copy, nullable) void(^switchStateDidChangeBlock) (UISwitch *sender);
///容器视图。
@property (nonatomic, strong) UIView *containerView;

@end

NS_ASSUME_NONNULL_END
