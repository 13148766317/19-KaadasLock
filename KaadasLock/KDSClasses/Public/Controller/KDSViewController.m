//
//  KDSViewController.m
//  xiaokaizhineng
//
//  Created by orange on 2019/1/15.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSViewController.h"

///iOS11后让导航栏返回按钮往左偏移使用。
@interface UIBarButton : UIButton

@end
@implementation UIBarButton

- (UIEdgeInsets)alignmentRectInsets
{
    if ([UIDevice currentDevice].systemVersion.floatValue < 11.0)
    {
        return [super alignmentRectInsets];
    }
    return UIEdgeInsetsMake(0, 14, 0, -6);
}

@end

@interface KDSViewController () <UIGestureRecognizerDelegate>

@end

@implementation KDSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = KDSRGBColor(242, 242, 242);

//    self.view.backgroundColor = UIColor.whiteColor;
    if (self.navigationController)
    {
        //[[UINavigationBar appearance] setTranslucent:NO];
        //[self setNavigationBarBackButton];
        [self setNavigationTitleLabel];
        //self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        self.navigationController.navigationBar.tintColor = UIColor.blackColor;
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:UIColor.blackColor, NSFontAttributeName:[UIFont systemFontOfSize:17]};
        self.navigationController.navigationBar.topItem.title = @"";
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //这儿禁了首个控制器或其父控制器是导航控制器跟控制器时的侧滑返回手势。
    //BOOL _is_ = self.navigationController.viewControllers.count > 1;
    //self.navigationController.interactivePopGestureRecognizer.delegate = _is_ ? nil : self;
}

- (void)setNavigationBarBackButton
{
    UIBarButton *backBtn = [[UIBarButton alloc] init];
    [backBtn addTarget:self action:@selector(navigationBarBackButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[[UIImage imageNamed:@"title-left"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    if ([UIDevice currentDevice].systemVersion.floatValue < 11.0)
    {
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        backBtn.bounds = CGRectMake(0, 0, 30, kNavBarHeight);
        space.width = -20;
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        self.navigationItem.leftBarButtonItems = @[space, backItem];
    }
    else
    {
        [backBtn.widthAnchor constraintEqualToConstant:25].active = YES;
        [backBtn.heightAnchor constraintEqualToConstant:kNavBarHeight].active = YES;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    }
}

-(void)setupNavigationItem{
    //导航栏背景
    UIImage * image = [[UIImage imageNamed:@"img_navigationbar_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(-1, 0, 0, 0) resizingMode:UIImageResizingModeStretch];
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
}
-(void)setRightButton{
    //设置右按钮（图片）
    UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
}
-(void)setRightTextButton{
    //设置右按钮（文字）
    UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.rightTextButton];
    self.navigationItem.rightBarButtonItems = @[[self getNavigationSpacerWithSpacer:0],rightBarButton];
    
}

-(void)setNavigationTitleLabel{
    //设置标题
    self.navigationItem.titleView = self.navigationTitleLabel;
    
}

-(UIBarButtonItem *)getNavigationSpacerWithSpacer:(CGFloat)spacer{
    //设置导航栏左右按钮的偏移距离
    UIBarButtonItem *navgationButtonSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    navgationButtonSpacer.width = spacer; return navgationButtonSpacer;
    
}
#pragma mark - lazy 各控件的初始化方法
-(UIButton *)rightButton{
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.frame = CGRectMake(0, 0, 40, 40);
        [_rightButton addTarget:self action:@selector(navRightClick) forControlEvents:UIControlEventTouchUpInside];
    } return _rightButton;
}
-(UIButton *)rightTextButton{
    if (!_rightTextButton) {
        _rightTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightTextButton.frame = CGRectMake(0, 0, 60, 40);
        _rightTextButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_rightTextButton addTarget:self action:@selector(navRightTextClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightTextButton;
}
-(UILabel *)navigationTitleLabel{
    if (!_navigationTitleLabel) {
        _navigationTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 150, 30)];
        _navigationTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
        _navigationTitleLabel.textColor = [UIColor blackColor];
        _navigationTitleLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    return _navigationTitleLabel;
}
#pragma mark - click 导航栏按钮点击方法，右按钮点击方法都需要子类来实现
- (void)navigationBarBackButtonAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)navRightClick{
    
}
-(void)navRightTextClick{
    
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.navigationController.interactivePopGestureRecognizer)
    {
        return self.navigationController.viewControllers.count > 1;
    }
    return YES;
}

@end
