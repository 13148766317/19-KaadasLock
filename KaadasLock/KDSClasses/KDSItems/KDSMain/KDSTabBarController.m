//
//  KDSTabBarController.m
//  xiaokaizhineng
//
//  Created by orange on 2019/1/15.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSTabBarController.h"
#import "KDSNavigationController.h"
#import "KDSHomeViewController.h"
#import "KDSDeviceViewController.h"
#import "KDSMineViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface KDSTabBarController ()

@property (nonatomic, strong) CLLocation *location;

@end

@implementation KDSTabBarController

#pragma mark - 生命周期方法
+ (void)initialize
{
    
    /*
    // 通过appearance统一设置所有UITabBarItem的文字属性
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    attrs[NSForegroundColorAttributeName] = KDSRGBColor(0xa3, 0xa3, 0xa3);
    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    selectedAttrs[NSFontAttributeName] = attrs[NSFontAttributeName];
    selectedAttrs[NSForegroundColorAttributeName] = KDSRGBColor(0x2d, 0xd9, 0xba);
    UITabBarItem *item = [UITabBarItem appearance];
    [item setTitleTextAttributes:attrs forState:UIControlStateNormal];
    [item setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];
    */
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //设置隐藏tabar上方的灰线
//    [self.tabBarController.tabBar setBackgroundImage:[UIImage new]];
//    [self.tabBarController.tabBar setShadowImage:[UIImage new]];
    [self addChildViewControllers];
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeLanguageDidChange:) name:KDSLocaleLanguageDidChangeNotification object:nil];

}

- (void)addChildViewControllers
{
    KDSHomeViewController *homepageVC = [KDSHomeViewController new];
    KDSNavigationController *homepageNav = [self configTabBarItemController:homepageVC title:Localized(@"homepage") image:@"tabBarHomepage" selectedImage:@"tabBarHomepageSelected"];
    KDSDeviceViewController *deviceVC = [KDSDeviceViewController new];
    KDSNavigationController *deviceNav = [self configTabBarItemController:deviceVC title:Localized(@"device") image:@"tabBarDevice" selectedImage:@"tabBarDeviceSelected"];
    
    KDSMineViewController *meVC = [KDSMineViewController new];
    KDSNavigationController *meNav = [self configTabBarItemController:meVC title:Localized(@"mine") image:@"tabBarMe" selectedImage:@"tabBarMeSelected"];
    
    /*商城
    KDSHomeController *mallVC = [KDSHomeController new];
    KDSNavigationController *mallNav = [self configTabBarItemController:mallVC title:Localized(@"mall") image:@"商城2" selectedImage:@"商城1"];
     */
    
    self.viewControllers = @[homepageNav, deviceNav, meNav];

//    self.viewControllers = @[homepageNav, deviceNav, mallNav, meNav];
}

/**
 *配置标签控制器下的各个子控制器，返回一个以子控制器为根的导航控制器。这个方法会统一设置导航控制器导航栏的背景色。
 *@param childVc 需配置的子控制器。
 *@param title 子控制器的标签项标题。
 *@param image 子控制器标签项图片。
 *@param selectedImage 子控制器标签项选中图片。
 *@return 以子控制器为根的导航控制器。
 */
- (KDSNavigationController *)configTabBarItemController:(UIViewController *)childVc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage{
    // 设置子控制器的文字
    childVc.tabBarItem.title = title;
//    childVc.view.backgroundColor = [UIColor whiteColor];
    // 设置子控制器的图片
    childVc.tabBarItem.image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childVc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    KDSNavigationController *nav = [[KDSNavigationController alloc] initWithRootViewController:childVc];
    //set NavigationBar 背景颜色&title 颜色
//    [childVc.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [childVc.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    return nav;
}

///收到更改了本地语言的通知，重新设置tab bar标签文字。
- (void)localeLanguageDidChange:(NSNotification *)noti
{
    self.viewControllers[0].tabBarItem.title = Localized(@"homepage");
    self.viewControllers[1].tabBarItem.title = Localized(@"device");
    self.viewControllers[2].tabBarItem.title = Localized(@"mine");
}


- (void)dealloc{
    [KDSNotificationCenter removeObserver:self];
    KDSLog(@"tabbar销毁了")
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
