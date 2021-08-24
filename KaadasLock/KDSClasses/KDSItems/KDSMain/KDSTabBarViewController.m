//
//  KDSTabBarViewController.m
//  KaadasLock
//
//  Created by wzr on 2019/1/15.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSTabBarViewController.h"
#import "KDSHomeViewController.h"
#import "KDSDeviceViewController.h"
#import "KDSMineViewController.h"

@interface KDSTabBarViewController ()


@end

@implementation KDSTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tabBarController.tabBar setShadowImage:[UIImage new]];
    [self addChildViewControllers];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeLanguageDidChange:) name:KDSLocaleLanguageDidChangeNotification object:nil];
}

- (void)addChildViewControllers
{
    KDSHomeViewController *homepageVC = [KDSHomeViewController new];
    UINavigationController *homepageNav = [self configTabBarItemController:homepageVC title:@"首页" image:@"tabBarHomepage" selectedImage:@"tabBarHomepageSelected"];
    KDSDeviceViewController *deviceVC = [KDSDeviceViewController new];
    UINavigationController *deviceNav = [self configTabBarItemController:deviceVC title:@"设备" image:@"tabBarDevice" selectedImage:@"tabBarDeviceSelected"];
    
    KDSMineViewController *meVC = [KDSMineViewController new];
    UINavigationController *meNav = [self configTabBarItemController:meVC title:@"我的" image:@"tabBarMe" selectedImage:@"tabBarMeSelected"];
    
    self.viewControllers = @[homepageNav, deviceNav, meNav];
}

/**
 *配置标签控制器下的各个子控制器，返回一个以子控制器为根的导航控制器。这个方法会统一设置导航控制器导航栏的背景色。
 *@param childVc 需配置的子控制器。
 *@param title 子控制器的标签项标题。
 *@param image 子控制器标签项图片。
 *@param selectedImage 子控制器标签项选中图片。
 *@return 以子控制器为根的导航控制器。
 */
- (UINavigationController *)configTabBarItemController:(UIViewController *)childVc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage{
    // 设置子控制器的文字
    childVc.tabBarItem.title = title;
    //    childVc.view.backgroundColor = [UIColor whiteColor];
    // 设置子控制器的图片
    childVc.tabBarItem.image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childVc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:childVc];
    //set NavigationBar 背景颜色&title 颜色
    //    [childVc.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [childVc.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    return nav;
}



@end
