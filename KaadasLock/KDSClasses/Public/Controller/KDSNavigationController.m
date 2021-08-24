//
//  KDSNavigationController.m
//  xiaokaizhineng
//
//  Created by orange on 2019/1/15.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSNavigationController.h"
#import "KDSDeviceViewController.h"
#import "KDSMineViewController.h"
#import "KDSHomeViewController.h"

@interface KDSNavigationController () <UINavigationControllerDelegate>

@end

@implementation KDSNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self)
    {
        self.hideNavigationBarOnRootViewController = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    BOOL hidden;
    if ([viewController isKindOfClass:[KDSDeviceViewController class]] || [viewController isKindOfClass:[KDSHomeViewController class]] || [viewController isKindOfClass:[KDSMineViewController class]] || viewController == navigationController.viewControllers.firstObject) {
        hidden = YES;
    }else{
        hidden = NO;
    }
    hidden = hidden && self.hideNavigationBarOnRootViewController;
    [navigationController setNavigationBarHidden:hidden animated:YES];//!iOS 9
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
    [self setNavigationBarHidden:NO animated:YES];
}
@end
