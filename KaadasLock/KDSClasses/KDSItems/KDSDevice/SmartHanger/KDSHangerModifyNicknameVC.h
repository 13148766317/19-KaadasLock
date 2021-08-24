//
//  KDSHangerModifyNicknameVC.h
//  KaadasLock
//
//  Created by Apple on 2021/4/15.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSHangerModifyNicknameVC : KDSBaseViewController
@property(nonatomic, strong) NSString *nickName;
@property(nonatomic, strong) NSString *navTitle;
@property(nonatomic, strong) NSString *placeholder;
@property(nonatomic, copy) void (^saveBlock)(NSString *nickName);
@end

NS_ASSUME_NONNULL_END
