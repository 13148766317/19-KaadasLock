//
//  KDSGesturePwdVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/1.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

///我的->安全设置->手势密码
@interface KDSGesturePwdVC : KDSBaseViewController

///手势密码功能类型，0设置手势密码，1修改手势密码，2验证手势密码。默认0.
@property (nonatomic, assign) int type;
///点击事件：开启手势密码、更改手势密码
@property (nonatomic,strong)NSString * clickEvents;

@end

NS_ASSUME_NONNULL_END
