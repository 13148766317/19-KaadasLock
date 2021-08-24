//
//  KDSViewController.h
//  xiaokaizhineng
//
//  Created by orange on 2019/1/15.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+Color.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *@abstract 这个类可以用作控制器的基类，进行一些基本的公共设置，例如添加导航栏返回按钮和一些提示界面之类。
 */
@interface KDSViewController : UIViewController 

/**
 *@abstract 导航栏(如果有的话)返回按钮点击事件，默认为返回上一个控制器。子类可以重载以实现不同功能，不用调用super实现。
 *@param sender 返回按钮。
 */
//- (void)navigationBarBackButtonAction:(UIButton *)sender;

//导航栏标题
@property(nonatomic,strong) UILabel * navigationTitleLabel;
//导航栏右按钮（图片）
@property(nonatomic,strong) UIButton * rightButton;
//导航栏右按钮（文字）
@property(nonatomic,strong) UIButton * rightTextButton;
//为了灵活的满足不同的ViewController，将set方法放到.h文件，供子类调用
-(void)setupNavigationItem;
-(void)setRightButton;
-(void)setRightTextButton;
//返回按钮和右按钮点击方法，如果需要实现不同的方法，子类可以重新该方法
-(void)navRightClick;
-(void)navRightTextClick;

@end

NS_ASSUME_NONNULL_END
