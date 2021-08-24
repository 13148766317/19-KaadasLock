//
//  KDSSecurityAuthenticationVC.m
//  xiaokaizhineng
//
//  Created by orange on 2019/3/7.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSSecurityAuthenticationVC.h"
#import "KDSDBManager.h"
#import "KDSGesturePwdView.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "Masonry.h"

@interface KDSSecurityAuthenticationVC () <KDSGesturePwdViewDelegate>

///头像。
@property (nonatomic, strong) UIImageView *avatarIV;
///指纹按钮。
@property (nonatomic, strong) UIButton *fpBtn;
///提示标签。
@property (nonatomic, strong) UILabel *tipsLabel;
///更多按钮，点击可切换验证方式或返回登录界面。
@property (nonatomic, strong) UIButton *moreBtn;
///手势密码验证时的小九宫格视图数组。
@property (nonatomic, strong) NSMutableArray<UIView *> *views;
///手势密码绘制视图。
@property (nonatomic, strong) KDSGesturePwdView *gestureView;
///允许验证手势密码失败的次数。
@property (nonatomic, assign) int maxFailureTimes;

@end

@implementation KDSSecurityAuthenticationVC

#pragma mark - 懒加载
- (UIButton *)fpBtn
{
    if (!_fpBtn)
    {
        _fpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fpBtn setImage:[UIImage imageNamed:@"bigFingerprint"] forState:UIControlStateNormal];
        [_fpBtn setImage:[UIImage imageNamed:@"bigFingerprint"] forState:UIControlStateSelected];
        _fpBtn.frame = CGRectMake((kScreenWidth - 50) / 2.0, (kScreenHeight - kStatusBarHeight - CGRectGetMaxY(self.avatarIV.frame) - 90) / 444.0 * 129 + CGRectGetMaxY(self.avatarIV.frame), 50, 50);
        [_fpBtn addTarget:self action:@selector(clickFingerprintBtnAuthenticateFingerprint:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_fpBtn];
    }
    return _fpBtn;
}

- (NSMutableArray<UIView *> *)views
{
    if (!_views)
    {
        
        _views = [NSMutableArray arrayWithCapacity:9];
        CGFloat y = CGRectGetMinY(self.gestureView.frame) - 20 - 15 - 20 - 31;
        CGFloat x = (kScreenWidth - 31) / 2.0;
        for (int i = 0; i < 9; ++i)
        {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x + i%3 * 12, y + i/3 *12, 7, 7)];
            view.layer.masksToBounds = YES;
            view.layer.cornerRadius = 3.5;
            view.backgroundColor = KDSRGBColor(0xf8, 0xf8, 0xf8);
            [_views addObject:view];
            [self.view addSubview:view];
        }
    }
    return _views;
}

- (KDSGesturePwdView *)gestureView
{
    if (!_gestureView)
    {
        //V:[-(51+statusBarHeight)-(avatarBtn68)-....-(31)-20-(15)-20-(267)-..-(30)-50-]
        CGFloat y = CGRectGetMaxY(self.avatarIV.frame) + 86 + (kScreenHeight - CGRectGetMaxY(self.avatarIV.frame) - 50 - 30 - 267 - 86) / 3.0 * 2;
        _gestureView = [[KDSGesturePwdView alloc] initWithFrame:CGRectMake((kScreenWidth - 51*3 - 47*2 - 20) / 2.0, y, 51*3 + 47*2 + 20, 51*3 + 47*2 + 20)];
        _gestureView.delegate = self;
        self.maxFailureTimes = [[KDSDBManager sharedManager] queryUserAuthTimes];
        [self.view addSubview:_gestureView];
    }
    return _gestureView;
}

- (UILabel *)tipsLabel
{
    if (!_tipsLabel)
    {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.textColor = KDSRGBColor(31,150 ,247);
        _tipsLabel.font = [UIFont systemFontOfSize:15];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.bounds = CGRectMake(0, 0, kScreenWidth - 20, 18);
        [self.view addSubview:_tipsLabel];
    }
    return _tipsLabel;
}

- (UIButton *)moreBtn
{
    if (!_moreBtn)
    {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *title = Localized(@"more");
        UIFont *font = [UIFont systemFontOfSize:15];
        [_moreBtn setTitle:title forState:UIControlStateNormal];
        _moreBtn.titleLabel.font = font;
        [_moreBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
        [_moreBtn addTarget:self action:@selector(clickMoreBtnSwitchAuthenticationWay:) forControlEvents:UIControlEventTouchUpInside];
        CGFloat width = [title sizeWithAttributes:@{NSFontAttributeName : font}].width + 30;
        _moreBtn.frame = CGRectMake((kScreenWidth - width) / 2.0, kScreenHeight - 50 - 30, width, 30);
    }
    return _moreBtn;
}

#pragma mark - 生命周期方法。
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    KDSDBManager *manager = [KDSDBManager sharedManager];
    NSData *imgData = [manager queryUserAvatarData];
    UIImage *img = imgData ? [[UIImage alloc] initWithData:imgData] : [UIImage imageNamed:@"头像-默认"];
    self.avatarIV = [[UIImageView alloc] initWithImage:img];
    self.avatarIV.frame = CGRectMake((kScreenWidth - 68) / 2.0, kStatusBarHeight + 48, 68, 68);
    self.avatarIV.layer.cornerRadius = 34;
    [self.view addSubview:self.avatarIV];
    
    LAContext *ctx = [[LAContext alloc] init];
    BOOL touchIDEnable = [manager queryUserTouchIDState] && [ctx canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    BOOL gEnagle = [manager queryUserGesturePwdState];
    if (touchIDEnable)
    {
        self.tipsLabel.center = CGPointMake(kScreenWidth / 2.0, CGRectGetMaxY(self.fpBtn.frame) + 25 + self.tipsLabel.bounds.size.height / 2);
        self.tipsLabel.text = Localized(@"clickAuthenticateFingerprint");
        [self clickFingerprintBtnAuthenticateFingerprint:self.fpBtn];
    }
    else if (gEnagle)
    {
        [self views];
        self.tipsLabel.center = CGPointMake(kScreenWidth / 2.0, CGRectGetMinY(self.gestureView.frame) - 20 -self.tipsLabel.bounds.size.height / 2);
        self.tipsLabel.text = Localized(@"drawGesturePwd");
    }
    else
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    [self.view addSubview:self.moreBtn];
}

///验证成功。
- (void)authenticateSuccess
{
    [[KDSDBManager sharedManager] updateUserAuthTimes:5];
    [[KDSDBManager sharedManager] updateUserAuthDate:NSDate.date];
    if (self.presentingViewController)
    {
        [self dismissViewControllerAnimated:NO completion:^{
            !self.finishBlock ?: self.finishBlock(YES);
        }];
    }
    else
    {
        !self.finishBlock ?: self.finishBlock(YES);
    }
}

#pragma mark - 控件等事件方法。
///点击指纹按钮验证指纹解锁。
- (void)clickFingerprintBtnAuthenticateFingerprint:(UIButton *)sender
{
    LAContext *ctx = [[LAContext alloc] init];
    [ctx evaluatePolicy:LAPolicyDeviceOwnerAuthentication  localizedReason:Localized(@"authAndOpenTouchID") reply:^(BOOL success, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success)
            {
                [self  authenticateSuccess];
            }
        });
        
    }];
}

///点击更多按钮切换验证方式。
- (void)clickMoreBtnSwitchAuthenticationWay:(UIButton *)sender
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    BOOL tEnable = [[KDSDBManager sharedManager] queryUserTouchIDState];
    BOOL gEnagle = [[KDSDBManager sharedManager] queryUserGesturePwdState];
    if (tEnable && gEnagle)//如果2种方式都启用，第一选项为切换指纹/手势密码解锁
    {
        BOOL isTouchId = !self.fpBtn.hidden;
        NSString *title = isTouchId ? Localized(@"authenticateWithGesturePwd") : Localized(@"authenticateWithFingerprint");
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (isTouchId)
            {
                self.tipsLabel.center = CGPointMake(kScreenWidth / 2.0, CGRectGetMinY(self.gestureView.frame) - 20 - self.tipsLabel.bounds.size.height / 2);
                self.tipsLabel.text = Localized(@"drawGesturePwd");
                for (UIView *view in self.views)
                {
                    view.hidden = NO;
                }
                self.gestureView.hidden = NO;
                self.fpBtn.hidden = YES;
            }
            else
            {
                self.tipsLabel.center = CGPointMake(kScreenWidth / 2.0, CGRectGetMaxY(self.fpBtn.frame) + 25 + self.tipsLabel.bounds.size.height / 2);
                self.tipsLabel.text = Localized(@"clickAuthenticateFingerprint");
                for (UIView *view in self.views)
                {
                    view.hidden = YES;
                }
                self.gestureView.hidden = YES;
                self.fpBtn.hidden = NO;
            }
        }];
        [ac addAction:action];
    }
    
    UIAlertAction *signin = [UIAlertAction actionWithTitle:Localized(@"signinWithPwd") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KDSLogoutNotification object:nil userInfo:nil];
    }];
    [ac addAction:signin];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleCancel handler:nil];
    [ac addAction:cancel];
    
    [self presentViewController:ac animated:YES completion:^{
        NSArray<UIView *> *views = [UIApplication sharedApplication].keyWindow.subviews;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToRemoveAlertController:)];
        [views.lastObject.subviews.firstObject addGestureRecognizer:tap];
    }];
}

///点击屏幕消除警告控制器。
- (void)tapToRemoveAlertController:(UITapGestureRecognizer *)tap
{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
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
    [self verifyGesturePwd:pwd];
}

- (void)gesturePwdViewDidEnd:(KDSGesturePwdView *)view
{
    for (UIView *view in self.views)
    {
        view.backgroundColor = KDSRGBColor(0xf8, 0xf8, 0xf8);
    }
}

///根据获取到的手势密码更新数据库状态，并处理后续逻辑。
- (void)verifyGesturePwd:(NSString *)pwd
{
    NSString *pwdInDB = [[KDSDBManager sharedManager] queryUserGesturePwd];
    if (![pwd isEqualToString:pwdInDB])
    {
        self.maxFailureTimes--;
        self.tipsLabel.text = [NSString stringWithFormat:Localized(@"gesturePwdIncorrect"), self.maxFailureTimes];
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.tipsLabel.text = Localized(@"drawGesturePwd");
        });
        return;
    }
    [self authenticateSuccess];
}

@end
