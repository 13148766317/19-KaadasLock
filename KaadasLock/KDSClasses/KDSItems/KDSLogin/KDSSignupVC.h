//
//  KDSSignupVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/3/25.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"


typedef enum : NSUInteger {
    RegisteredTypeByTel,
    RegisteredTypeByEmail,
    RegisteredTypeForgetPwd,
} RegisteredType;

NS_ASSUME_NONNULL_BEGIN

typedef  void(^RegisteredSuccess)(NSString *userName,NSString *code,NSString *passWord);
@interface KDSSignupVC : KDSBaseViewController

@property (nonatomic, assign) RegisteredType registerType;
@property (nonatomic,strong)NSString * countryCodeString;
@property (nonatomic,strong)NSString * countryName;
///标示从安全设置修改密码过来的,目的是修改完之后重新登录
@property (nonatomic,strong)NSString * markSecuritySetting;
@property (nonatomic, copy) RegisteredSuccess registeredSucessBlock;

///验证码倒计时秒数。初始化时为59
@property (nonatomic, assign) NSInteger countdown;

@end

NS_ASSUME_NONNULL_END
