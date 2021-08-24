//
//  KDSGesturePwdVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/1.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSGesturePwdVC.h"
#import "KDSGesturePwdView.h"
#import "KDSDBManager.h"
#import "Masonry.h"
#import "KDSClearGesturePwdVC.h"
#import "ZQAlterField.h"
#import "ZQUtil.h"
#import "KDSSignupVC.h"

@interface KDSGesturePwdVC () <KDSGesturePwdViewDelegate>


///顶部的小九宫格视图数组。
@property (nonatomic, strong) NSMutableArray<UIView *> *views;
///手势密码设置、验证过程的提示标签。
@property (nonatomic, strong) UILabel *tipsLabel;
///手势密码绘制视图。
@property (nonatomic, weak) KDSGesturePwdView *gestureView;
///第一次绘制的密码。
@property (nonatomic, strong) NSString *firstPwd;
///允许验证手势密码失败的次数，验证时(type=1)使用。
@property (nonatomic, assign) int maxFailureTimes;
///忘记手势密码按钮。
@property (nonatomic, strong) UIButton *forgotBtn;

@end

@implementation KDSGesturePwdVC

- (UIButton *)forgotBtn
{
    if (!_forgotBtn)
    {
        UIFont *font = [UIFont systemFontOfSize:15];
//        NSString *title = Localized(@"forgotGesturePassword?");
        _forgotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_forgotBtn setTitle:Localized(@"more") forState:UIControlStateNormal];
        [_forgotBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
        _forgotBtn.titleLabel.font = font;
        [_forgotBtn addTarget:self action:@selector(forgotBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_forgotBtn];
        [_forgotBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(kScreenHeight>=812 ? -50 : -35);
            make.width.mas_equalTo(ceil([Localized(@"more") sizeWithAttributes:@{NSFontAttributeName : font}].width));
            make.height.mas_equalTo(30);
        }];
    }
    return _forgotBtn;
}

#pragma mark - 生命周期、UI方法。
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.type = 0;
        self.maxFailureTimes = [[KDSDBManager sharedManager] queryUserAuthTimes];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationTitleLabel.text = Localized(@"securitySetting");
//     self.navigationController.navigationBar.barTintColor = KDSRGBColor(242, 242, 242);
    
    self.views = [NSMutableArray arrayWithCapacity:9];
    CGFloat y = 42;
    CGFloat x = (kScreenWidth - 31) / 2.0;
    for (int i = 0; i < 9; ++i)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x + i%3 * 12, y + i/3 *12, 7, 7)];
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = 3.5;
        view.backgroundColor = KDSRGBColor(0xf8, 0xf8, 0xf8);
        [self.views addObject:view];
//        [self.view addSubview:view];
    }
    
    self.tipsLabel = [[UILabel alloc] init];
    self.tipsLabel.textColor = KDSRGBColor(0x14, 0x14, 0x14);
    self.tipsLabel.font = [UIFont systemFontOfSize:18];
    self.tipsLabel.textAlignment = NSTextAlignmentCenter;
    self.tipsLabel.numberOfLines = 0;
    self.tipsLabel.text = Localized(self.type==1 ? @"verifyGesturePwd" : @"drawGesturePwd");
    [self.view addSubview:self.tipsLabel];
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(73);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.height.mas_lessThanOrEqualTo(ceil([self.tipsLabel.text sizeWithAttributes:@{NSFontAttributeName : self.tipsLabel.font}].height) * 2);
    }];
    
    KDSGesturePwdView *gesView = [[KDSGesturePwdView alloc] initWithFrame:CGRectMake((kScreenWidth - outerRingDiameter*3 - marginLeftAndRight*2 - 20) / 2.0, 160, outerRingDiameter*3 + marginLeftAndRight*2 + 20, outerRingDiameter*3 + marginLeftAndRight*2 + 20)];
    gesView.backgroundColor = [UIColor clearColor];
    gesView.delegate = self;
    [self.view addSubview:gesView];
    self.gestureView = gesView;
//    if (self.maxFailureTimes < 3)
//    {
//        [self forgotBtn];
//    }
    if ([self.clickEvents isEqualToString:@"changeClickEvents"]) {
         [self forgotBtn];
    }
   
}

///点击忘记手势密码，跳转清除手势密码。\点击更多
- (void)forgotBtnAction:(UIButton *)sender
{
    [self authentication];
//    KDSClearGesturePwdVC *vc = [KDSClearGesturePwdVC new];
//    [self.navigationController pushViewController:vc animated:YES];
}

-(void)authentication
{
    ZQAlterField *alertView = [ZQAlterField alertView];
    alertView.title = @"请输入账户登录密码";
    alertView.detailLabel.text = [NSString stringWithFormat:@"当前账户%@",[KDSUserManager sharedManager].user.name];
    alertView.Maxlength = 16;
    alertView.intervalNum = 5;
    alertView.intervalStr = @"";
    [alertView ensureClickBlock:^(NSString *inputString) {
        NSString *newNickname = inputString;
        if (![newNickname isEqualToString:[KDSTool getDefaultLoginPassWord]]) {
            
            ///弹出提示框，进行下一步操作
            [self tipsShow];
        }else{
             self.tipsLabel.text = Localized(@"drawNewGesturePwd");
        }
    }];
    [alertView show];
}

-(void)tipsShow
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"账户密码输入错误" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"修改密码" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //修改密码
        [self changePwd];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"重新输入" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //重新输入
        [self authentication];
    }];
    [cancelAction setValue:[UIColor blackColor] forKey:@"titleTextColor"];
    [okAction setValue:KDSRGBColor(31, 150, 247) forKey:@"titleTextColor"];
    [ac addAction:cancelAction];
    [ac addAction:okAction];
    [self presentViewController:ac animated:YES completion:nil];
}

-(void)changePwd
{
    KDSSignupVC *forgetVC = [KDSSignupVC new];
    forgetVC.registerType = RegisteredTypeForgetPwd;
    forgetVC.markSecuritySetting = @"KDSGesturePwdVC";
    [self presentViewController:forgetVC animated:YES completion:nil];
}

#pragma mark - KDSGesturePwdViewDelegate
- (void)gesturePwdViewDidFail:(KDSGesturePwdView *)view passwords:(NSArray<NSNumber *> *)passwords
{
    for (NSNumber *num in passwords)
    {
        self.views[num.intValue - 1].backgroundColor = KDSRGBColor(0xdb, 0x39, 0x2b);
    }
    NSString *text = self.tipsLabel.text;
    self.tipsLabel.text = Localized(@"gesturePwdMustMoreThan3");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.tipsLabel.text = text;
    });
}

- (void)gesturePwdViewDidComplete:(KDSGesturePwdView *)view passwords:(NSArray<NSNumber *> *)passwords
{
    NSString * pwd = @"";
    for (NSNumber *num in passwords)
    {
        self.views[num.intValue - 1].backgroundColor = KDSRGBColor(0x2d, 0xd9, 0xba);
        pwd = [pwd stringByAppendingString:num.stringValue];
    }
    if (self.type == 0)
    {
        [self setGesturePwd:pwd];
    }
    else
    {
        [self verifyAndModifyGesturePwd:pwd];
    }
}

- (void)gesturePwdViewDidEnd:(KDSGesturePwdView *)view
{
    for (UIView *view in self.views)
    {
        view.backgroundColor = KDSRGBColor(0xf8, 0xf8, 0xf8);
    }
}

//MARK:根据获取到的手势密码更新数据库状态，并处理后续逻辑。
- (void)setGesturePwd:(NSString *)pwd
{
    if (!self.firstPwd)
    {
        self.firstPwd = pwd;
        self.tipsLabel.text = Localized(@"drawGesturePwdAgain");
    }
    else
    {
        if (![pwd isEqualToString:self.firstPwd])
        {
            self.tipsLabel.text = Localized(@"gesturePwdDifferentBetweenTwiceInput");
            for (NSUInteger i = 0; i < pwd.length; ++i)
            {
                self.views[[pwd substringWithRange:NSMakeRange(i, 1)].intValue - 1].backgroundColor = KDSRGBColor(0xdb, 0x39, 0x2b);
            }
            self.gestureView.isWrongPwd = YES;
        }
        else
        {
            //如果数据库更新失败，重新开始流程，否则退出控制器。
            KDSDBManager *dbMgr = [KDSDBManager sharedManager];
            BOOL res = [dbMgr updateUserGesturePwdState:YES] && [dbMgr updateUserGesturePwd:pwd];
            self.tipsLabel.text = Localized(res ? @"gesturePwdSetSuccess" : @"gesturePwdSetFailed");
            if (!res)
            {
                for (NSUInteger i = 0; i < pwd.length; ++i)
                {
                    self.views[[pwd substringWithRange:NSMakeRange(i, 1)].intValue - 1].backgroundColor = KDSRGBColor(0xdb, 0x39, 0x2b);
                }
            }
            self.gestureView.isWrongPwd = !res;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (res)
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    self.tipsLabel.text = Localized(@"drawGesturePwd");
                    self.firstPwd = nil;
                }
            });
        }
    }
}

///验证和(或)修改手势密码。根据获取到的手势密码更新数据库状态，并处理后续逻辑。
- (void)verifyAndModifyGesturePwd:(NSString *)pwd
{
    KDSDBManager *manager = [KDSDBManager sharedManager];
    //验证旧密码
    if ([self.tipsLabel.text isEqualToString:Localized(@"verifyGesturePwd")] || self.type==2)
    {
        NSString *pwdInDB = [manager queryUserGesturePwd];
        if (![pwd isEqualToString:pwdInDB])
        {
            self.maxFailureTimes--;
            self.tipsLabel.text = [NSString stringWithFormat:Localized(self.type==1 ? @"oldGesturePwdIncorrect" : @"gesturePwdIncorrect"), self.maxFailureTimes];
            [[KDSDBManager sharedManager] updateUserAuthTimes:self.maxFailureTimes];
            for (NSUInteger i = 0; i < pwd.length; ++i)
            {
                self.views[[pwd substringWithRange:NSMakeRange(i, 1)].intValue - 1].backgroundColor = KDSRGBColor(0xdb, 0x39, 0x2b);
            }
            self.gestureView.isWrongPwd = YES;
            if (self.maxFailureTimes == 0)//验证次数超限，返回登录界面。
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:KDSLogoutNotification object:nil userInfo:nil];
                return;
            }
            self.maxFailureTimes < 3 ? (void)[self forgotBtn] : nil;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.tipsLabel.text = Localized(self.type==1 ? @"verifyGesturePwd" : @"drawGesturePwd");
            });
            return;
        }
        [manager updateUserAuthTimes:5];
        if (self.type == 1)
        {
            self.tipsLabel.text = Localized(@"drawNewGesturePwd");
        }
        else//验证手势密码成功，改变手势密码开关状态。
        {
            [manager updateUserGesturePwdState:!manager.queryUserGesturePwdState];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else//验证旧密码成功后，输入新密码
    {
        if (!self.firstPwd)//首次输入新密码
        {
            NSString *pwdInDB = [[KDSDBManager sharedManager] queryUserGesturePwd];
            if ([pwdInDB isEqualToString:pwd])
            {
                for (NSUInteger i = 0; i < pwd.length; ++i)
                {
                    self.views[[pwd substringWithRange:NSMakeRange(i, 1)].intValue - 1].backgroundColor = KDSRGBColor(0xdb, 0x39, 0x2b);
                }
                self.gestureView.isWrongPwd = YES;
                NSString *text = self.tipsLabel.text;
                self.tipsLabel.text = Localized(@"pwdSameBetweenOldAndNew");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.tipsLabel.text = text;
                });
                return;
            }
            self.firstPwd = pwd;
            self.tipsLabel.text = Localized(@"drawGesturePwdAgain");
        }
        else//再次输入新密码
        {
            if (![pwd isEqualToString:self.firstPwd])//2次输入的新密码不一样。
            {
                for (NSUInteger i = 0; i < pwd.length; ++i)
                {
                    self.views[[pwd substringWithRange:NSMakeRange(i, 1)].intValue - 1].backgroundColor = KDSRGBColor(0xdb, 0x39, 0x2b);
                }
                self.tipsLabel.text = Localized(@"gesturePwdDifferentBetweenTwiceInput");
                self.gestureView.isWrongPwd = YES;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.tipsLabel.text = Localized(@"drawGesturePwdAgain");
                });
            }
            else
            {
                //如果数据库更新失败，重新开始流程，否则退出控制器。
                BOOL res = [[KDSDBManager sharedManager] updateUserGesturePwd:pwd];
                self.tipsLabel.text = Localized(res ? @"gesturePwdModifySuccess" : @"gesturePwdModifyFailed");
                if (!res)
                {
                    for (NSUInteger i = 0; i < pwd.length; ++i)
                    {
                        self.views[[pwd substringWithRange:NSMakeRange(i, 1)].intValue - 1].backgroundColor = KDSRGBColor(0xdb, 0x39, 0x2b);
                    }
                }
                self.gestureView.isWrongPwd = !res;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (res)
                    {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    else
                    {
                        self.tipsLabel.text = Localized(@"drawNewGesturePwd");
                        self.firstPwd = nil;
                    }
                });
            }
        }
    }
}



@end
