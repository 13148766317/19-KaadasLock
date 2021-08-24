//
//  SYAlertView.h
//  zhangshaoyu
//
//  Created by zhangshaoyu on 2018/6/4.
//  Copyright © 2018年 VSTECS. All rights reserved.
//  https://github.com/potato512/SYAlertView

#import <UIKit/UIKit.h>

@interface SYAlertView : UIView

- (instancetype)init;

/// 子视图容器（设置具体UI。如已设置showContainerView则无需设置此属性的frame及添加子视图，避免重复）
@property (nonatomic, strong) UIView * addDevicecontainerView;
/// 子视图容器（设置具体UI。默认nil，设置后默认居中显示，且无需设置containerView的frame及添加子视图，避免重复）
@property (nonatomic, strong) UIView *showContainerView;

/// 默认无动画（设置后默认放大缩小）
@property (nonatomic, assign) BOOL isAnimation;
/// 动画设置（默认放大缩小）
@property (nonatomic, strong) CAAnimation *animation;


/// 显示（显示之前需要设置containerView的子视图，及其frame）
- (void)show;
/// 隐藏（隐藏后，会自动删除containerView的子视图）
- (void)hide;

@end

/*
 使用示例
 1、导入头文件
 #import "SYAlertView.h"
 
 2、实例化
 AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
 UIView *view = delegate.window;
 SYAlertView *alertView = [[SYAlertView alloc] initWithView:view];
 alertView.isAnimation = YES;
 alertView.timeAnimation = 0.6;
 
 3、子视图设置
 // 自定义的子视图
 UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0f, 110.0f)];
 UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 20.0f, 160.0f, 40.0f)];
 message.text = @"弹窗信息";
 [view addSubview:message];
 UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20.0f, 70.0f, 160.0f, 30.0f)];
 [button setTitle:@"知道了" forState:UIControlStateNormal];
 [button addTarget:self action:@selector(closeClick:) forControlEvents:UIControlEventTouchUpInside]
 [view addSubview:button];
 
 （1）方法1
 alertView.showContainerView = view;
 （2）方法2
 alertView.containerView.frame = CGRectMake(20.0f, (alertView.frame.size.height - view.frame.size.height) / 2, view.frame.size.width, view.frame.size.height);
 [alertView.containerView addSubview:view];
 
 4、方法调用
 （1）显示
 [alertView show];
 （2）隐藏
 [alertView hide];
 
*/
