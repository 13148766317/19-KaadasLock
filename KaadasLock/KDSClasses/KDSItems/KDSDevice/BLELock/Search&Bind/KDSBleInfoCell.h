//
//  KDSBleInfoCell.h
//  xiaokaizhineng
//
//  Created by orange on 2019/2/12.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *@abstract 搜索蓝牙绑定时显示蓝牙信息的cell。
 */
@interface KDSBleInfoCell : UITableViewCell

///蓝牙名称。
@property (nonatomic, strong) NSString *bleName;
///是否已绑定。
@property (nonatomic, assign) BOOL hasBinded;
///是否隐藏cell底部的横线，默认否。
@property (nonatomic, assign) BOOL underlineHidden;
///绑定按钮点击执行的回调。
@property (nonatomic, copy, nullable) void(^bindBtnDidClickBlock) (UIButton *sender);

@end

NS_ASSUME_NONNULL_END
