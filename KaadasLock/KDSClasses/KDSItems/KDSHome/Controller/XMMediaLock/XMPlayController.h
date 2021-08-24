//
//  XMPlayController.h
//  XMDemo
//
//  Created by TixXie on 2020/8/31.
//  Copyright © 2020 xmitech. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, XMPlayType) {
    /// 实时流
    XMPlayTypeLive      = 0,
    /// 回放流
    XMPlayTypeReplay    = 1,
};

@interface XMPlayController : KDSBaseViewController

@property (nonatomic, assign) XMPlayType type;
///关联的锁。
@property (nonatomic, strong) KDSLock *lock;
///是否主动行为（被动的话有选择按钮，主动只有取消按钮）
@property (nonatomic, assign) BOOL isActive;

- (instancetype)initWithType:(XMPlayType)type;

@end

NS_ASSUME_NONNULL_END
