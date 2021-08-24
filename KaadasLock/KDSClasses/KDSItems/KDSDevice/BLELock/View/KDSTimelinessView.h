//
//  KDSTimelinessView.h
//  KaadasLock
//
//  Created by orange on 2019/4/1.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///密码时效图。
@interface KDSTimelinessView : UIView

/**
 *@brief 使用此方法创建添加时效密码时的生效时间图。创建时会固定好视图宽高，原点为{0, 0}。
 *@param title 标题。
 *@param date 生效日期。
 *@return instancetype。
 */
+ (instancetype)viewWithTitle:(NSString *)title date:(NSDate *)date;

///日期。时效模式设置此属性。
@property (nonatomic, strong) NSDate *date;
///内容。设置周期性密码时效框的内容。
@property (nonatomic, strong) NSString *content;
///点击日期视图时执行的回调。
@property (nonatomic, copy) void(^__nullable tapDateViewBlock) (UITapGestureRecognizer *sender);

@end

NS_ASSUME_NONNULL_END
