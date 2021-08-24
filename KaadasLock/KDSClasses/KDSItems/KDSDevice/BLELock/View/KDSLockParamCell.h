//
//  KDSLockParamCell.h
//  KaadasLock
//
//  Created by orange on 2019/4/9.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSLockParamCell : UITableViewCell

///参数标题。
@property (nonatomic, strong) NSString *title;
///参数内容。
@property (nonatomic, strong) NSString *content;
///是否隐藏分隔线。
@property (nonatomic, assign) BOOL hideSeparator;
///是否隐藏箭头，默认否。隐藏时会使得子标题右对齐到箭头右边。
@property (nonatomic, assign) BOOL hideArrow;

@end

NS_ASSUME_NONNULL_END
