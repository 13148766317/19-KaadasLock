//
//  KDSNavigationController.h
//  xiaokaizhineng
//
//  Created by orange on 2019/1/15.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *@abstract 控制导航控制器是否显示导航栏。
 */
@interface KDSNavigationController : UINavigationController

///默认是导航根控制器是会隐藏导航栏，如果不希望隐藏，请将此变量设置为NO，默认YES。
@property (nonatomic, assign) BOOL hideNavigationBarOnRootViewController;

@end

NS_ASSUME_NONNULL_END
