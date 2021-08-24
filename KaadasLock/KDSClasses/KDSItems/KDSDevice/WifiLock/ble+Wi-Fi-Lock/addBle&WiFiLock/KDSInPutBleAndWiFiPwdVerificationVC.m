//
//  KDSInPutBleAndWiFiPwdVerificationVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/4/17.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSInPutBleAndWiFiPwdVerificationVC.h"
#import "KDSWifiLockHelpVC.h"
#import "KDSHomeRoutersVC.h"
#import "KDSAMapLocationManager.h"
#import "KDSBleAndWiFiSendPwdAndSSIDVC.h"
#import "KDSAddBleAndWiFiLockStep1.h"

@interface KDSInPutBleAndWiFiPwdVerificationVC ()

@property (nonatomic, strong) UIButton * connectBtn;
@property (nonatomic, strong) UIView * supView;
///Wi-Fi名称输入框
@property (nonatomic, strong) UITextField * wifiNametf;
///密码输入框
@property (nonatomic, strong) UITextField * pwdtf;
///明文切换的按钮
@property (nonatomic, strong) UIButton * pwdPlaintextSwitchingBtn;
@property (nonatomic, strong) UILabel * tipsLb8;
@property (nonatomic, strong) UIView *routerProtocolView;
///手动编辑Wi-Fi SSID标记
@property (nonatomic,assign) BOOL auto2Hand;
///只有是Wi-Fi状态才可以配网
@property (nonatomic,assign) BOOL wifiStatus;
///手动编辑前的wifi的ssid
@property (nonatomic, strong) NSString * wifiNametemp;
///wifi的bssid
@property (nonatomic, strong) NSString * bssidLb;

@end

@implementation KDSInPutBleAndWiFiPwdVerificationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = @"输入Wi-Fi";
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkReachabilityStatusDidChange:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [self setUI];
}

-(void)setUI
{
    self.supView = [UIView new];
    self.supView.backgroundColor = UIColor.whiteColor;
    self.supView.layer.masksToBounds = YES;
    self.supView.layer.cornerRadius = 10;
    [self.view addSubview:self.supView];
    [self.supView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.top.equalTo(self.view.mas_top).offset(10);
        make.bottom.equalTo(self.view.mas_bottom).offset(-10);
    }];
    
    UILabel * tipMsgLabe1 = [UILabel new];
    tipMsgLabe1.text = @"连接您的家庭Wi-Fi";
    tipMsgLabe1.font = [UIFont systemFontOfSize:18];
    tipMsgLabe1.textColor = UIColor.blackColor;
    tipMsgLabe1.textAlignment = NSTextAlignmentLeft;
    [self.supView addSubview:tipMsgLabe1];
    [tipMsgLabe1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.supView.mas_top).offset(35);
        make.height.mas_equalTo(20);
        make.left.equalTo(self.supView.mas_left).offset(30);
        make.right.equalTo(_supView.mas_right).offset(-30);
    }];
    
    UILabel * tipMsgLb2 = [UILabel new];
    tipMsgLb2.text = @"暂不支持5G频段的Wi-Fi以及酒店机场需认证的Wi-Fi";
    tipMsgLb2.numberOfLines = 0;
    tipMsgLb2.textColor = KDSRGBColor(96, 96, 96);
    tipMsgLb2.textAlignment = NSTextAlignmentLeft;
    tipMsgLb2.font = [UIFont systemFontOfSize:13];
    [self.supView addSubview:tipMsgLb2];
    [tipMsgLb2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe1.mas_bottom).offset(10);
        make.height.mas_equalTo(30);
        make.left.equalTo(self.supView.mas_left).offset(30);
        make.right.equalTo(_supView.mas_right).offset(-10);
    }];
    
    UIView * line = [UIView new];
    line.backgroundColor = KDSRGBColor(220, 220, 220);
    [_supView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipMsgLb2.mas_bottom).offset(70);
        make.left.equalTo(_supView.mas_left).offset(30);
        make.right.equalTo(_supView.mas_right).offset(-30);
        make.height.equalTo(@1);
    }];
    
    UIImageView * wifiNameIconImg = [UIImageView new];
    wifiNameIconImg.image = [UIImage imageNamed:@"wifi-Lock-NameIcon"];
    [self.supView addSubview:wifiNameIconImg];
    [wifiNameIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@20);
        make.height.equalTo(@20);
        make.left.mas_equalTo(self.supView.mas_left).offset(33);
        make.bottom.mas_equalTo(line.mas_bottom).offset(-5);
    }];
    _wifiNametf = [UITextField new];
    _wifiNametf.placeholder = @"输入区分大小写";
//    _wifiNametf.clearButtonMode = UITextFieldViewModeAlways;
    _wifiNametf.textAlignment = NSTextAlignmentLeft;
    _wifiNametf.font = [UIFont systemFontOfSize:13];
    _wifiNametf.textColor = UIColor.blackColor;
    //取消默认大写属性
    _wifiNametf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [_wifiNametf addTarget:self action:@selector(wifiNametextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.supView addSubview:_wifiNametf];
    [_wifiNametf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(wifiNameIconImg.mas_right).offset(7);
        make.right.mas_equalTo(self.supView.mas_right).offset(-90.0);
        make.bottom.mas_equalTo(line.mas_bottom).offset(0);
        make.height.equalTo(@30);
    }];
    
    UIButton * changeWiFiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [changeWiFiBtn setTitle:@"更换网络" forState:UIControlStateNormal];
    changeWiFiBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [changeWiFiBtn addTarget:self action:@selector(jumpSetWifiClick:) forControlEvents:UIControlEventTouchUpInside];
    [changeWiFiBtn setTitleColor:KDSRGBColor(170, 170, 170) forState:UIControlStateNormal];
    [self.supView addSubview:changeWiFiBtn];
    [changeWiFiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.supView.mas_right).offset(-30.0);
        make.bottom.mas_equalTo(line.mas_bottom).offset(0);
        make.height.equalTo(@30);
        make.width.equalTo(@55);
    }];
    
    UIView * line2 = [UIView new];
    line2.backgroundColor = KDSRGBColor(220, 220, 220);
    [self.supView addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line.mas_bottom).offset(54);
        make.left.equalTo(_supView.mas_left).offset(30);
        make.right.equalTo(_supView.mas_right).offset(-30);
        make.height.equalTo(@1);
    }];
    
    self.tipsLb8 = [UILabel new];
    self.tipsLb8.text = @"请使用手机连接2.4G Wi-Fi";
    self.tipsLb8.textColor = KDSRGBColor(31, 150, 247);
    self.tipsLb8.textAlignment = NSTextAlignmentLeft;
    self.tipsLb8.font = [UIFont systemFontOfSize:12];
    [self.supView addSubview:self.tipsLb8];
    [self.tipsLb8 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.supView.mas_left).offset(30);
        make.height.equalTo(@20);
        make.top.equalTo(line2.mas_bottom).offset(10);
        make.right.equalTo(self.supView.mas_right).offset(-20);
    }];
    
    UIImageView * pwdIconImg = [UIImageView new];
    pwdIconImg.image = [UIImage imageNamed:@"wifi-Lock-pwdIcon"];
    [self.supView addSubview:pwdIconImg];
    [pwdIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@20);
        make.height.equalTo(@20);
        make.left.mas_equalTo(self.supView.mas_left).offset(33);
        make.bottom.mas_equalTo(line2.mas_bottom).offset(-5);
    }];
    self.pwdPlaintextSwitchingBtn = [UIButton new];
    [self.pwdPlaintextSwitchingBtn setImage:[UIImage imageNamed:@"眼睛闭Default"] forState:UIControlStateNormal];
    [self.pwdPlaintextSwitchingBtn setImage:[UIImage imageNamed:@"眼睛开Default"] forState:UIControlStateSelected];
    [self.pwdPlaintextSwitchingBtn addTarget:self action:@selector(plaintextClick:) forControlEvents:UIControlEventTouchUpInside];
    self.pwdPlaintextSwitchingBtn.selected = YES;
    [self.supView addSubview:self.pwdPlaintextSwitchingBtn];
    [self.pwdPlaintextSwitchingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@18);
        make.height.equalTo(@11);
        make.right.mas_equalTo(self.supView.mas_right).offset(-25.0);
        make.bottom.mas_equalTo(line2.mas_bottom).offset(-5);
    }];
    _pwdtf = [UITextField new];
    _pwdtf.placeholder=@"请输入密码";
    _pwdtf.secureTextEntry = NO;
    _pwdtf.keyboardType = UIKeyboardTypeDefault;
    _pwdtf.borderStyle=UITextBorderStyleNone;
    _pwdtf.textAlignment = NSTextAlignmentLeft;
    _pwdtf.font = [UIFont systemFontOfSize:13];
    _pwdtf.textColor = UIColor.blackColor;
    //取消默认大写属性
    _pwdtf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [_pwdtf addTarget:self action:@selector(pwdtextFieldDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.supView addSubview:_pwdtf];
    [_pwdtf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(pwdIconImg.mas_right).offset(7);
        make.right.mas_equalTo(self.pwdPlaintextSwitchingBtn.mas_left).offset(-5);
        make.bottom.mas_equalTo(line2.mas_bottom).offset(0);
        make.height.equalTo(@30);
    }];
    
    self.routerProtocolView = [UIView new];
    self.routerProtocolView.backgroundColor = UIColor.clearColor;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(supportedHomeRoutersClickTap:)];
    [self.routerProtocolView addGestureRecognizer:tap];
    [self.supView addSubview:self.routerProtocolView];
    [self.routerProtocolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@30);
        make.left.right.equalTo(self.supView);
        make.bottom.equalTo(self.supView.mas_bottom).offset(-45);
    }];
    
    UILabel * routerProtocolLb = [UILabel new];
    routerProtocolLb.text = @"查看门锁Wi-Fi支持家庭路由器";
    routerProtocolLb.textColor = KDSRGBColor(31, 150, 247);
    routerProtocolLb.textAlignment = NSTextAlignmentCenter;
    routerProtocolLb.font = [UIFont systemFontOfSize:14];
    [self.routerProtocolView addSubview:routerProtocolLb];
    NSRange strRange = {0,[routerProtocolLb.text length]};
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:routerProtocolLb.text];
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    routerProtocolLb.attributedText = str;
    [routerProtocolLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self.routerProtocolView);
    }];
    
    _connectBtn = [UIButton new];
    _connectBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    _connectBtn.layer.masksToBounds = YES;
    _connectBtn.layer.cornerRadius = 22;
    [_connectBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [_connectBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _connectBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_connectBtn addTarget:self action:@selector(confirmBtnClicl:) forControlEvents:UIControlEventTouchUpInside];
    [self.supView addSubview:_connectBtn];
    [_connectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.bottom.mas_equalTo(self.routerProtocolView.mas_top).offset(KDSScreenHeight < 667 ? -20 : -40);
        make.centerX.mas_equalTo(self.supView.mas_centerX).offset(0);
    }];
    
     [[KDSAMapLocationManager sharedManager] initWithLocationManager];
    if ([KDSAMapLocationManager sharedManager].ssid.length != 0) {
          _wifiNametf.text = [KDSAMapLocationManager sharedManager].ssid;
          _wifiNametemp = _wifiNametf.text;

      }else{
          _wifiNametf.text=@"";
      }
      self.bssidLb = [KDSAMapLocationManager sharedManager].bssid;
    
    
}

- (void)dealloc{
    
    [KDSNotificationCenter removeObserver:self];
    KDSLog(@"tabbar销毁了")
}

#pragma mark 控件点击事件

-(void)navRightClick
{
    KDSWifiLockHelpVC * vc = [KDSWifiLockHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)navBackClick
{
    UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:@"" message:@"确定重新开始配网吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[KDSAddBleAndWiFiLockStep1 class]]) {
                KDSAddBleAndWiFiLockStep1 *A =(KDSAddBleAndWiFiLockStep1 *)controller;
                [self.navigationController popToViewController:A animated:YES];
            }
        }
    }];
    [cancelAction setValue:KDSRGBColor(164, 164, 164) forKey:@"titleTextColor"];
    [alerVC addAction:cancelAction];
    [alerVC addAction:okAction];
    [self presentViewController:alerVC animated:YES completion:nil];
}

///明文切换
-(void)plaintextClick:(UIButton *)sender
{
    self.pwdPlaintextSwitchingBtn.selected = !self.pwdPlaintextSwitchingBtn.selected;
    if (self.pwdPlaintextSwitchingBtn.selected) {
        self.pwdtf.secureTextEntry = NO;
    }else{
        self.pwdtf.secureTextEntry = YES;
    }
}
///wifi账户的名称(32个字节)
- (void)wifiNametextFieldDidChange:(UITextField *)textField{
    //只要改变就为yes
    _auto2Hand = YES;
//    NSLog(@"中国中国中国中国===========%@，===%@",textField.text,_wifiNametemp);

    if ([textField.text isEqualToString:_wifiNametemp]) {
        //除非为一致
        _auto2Hand = NO;
    }
    if (textField.text.length > 32) {
        textField.text = [textField.text substringToIndex:12];
        [MBProgressHUD showError:@"Wi-Fi账户不能超过32个字节"];
    }
}
///wifi账户的名称的密码（64个字节）
-(void)pwdtextFieldDidChange:(UITextField *)textField{
    if (textField.text.length > 64) {
        textField.text = [textField.text substringToIndex:12];
        [MBProgressHUD showError:@"Wi-Fi名称的密码不能超过64个字节"];
    }
}

///确认入网按钮
-(void)confirmBtnClicl:(UIButton *)btn
{
     NSLog(@"------ap配网-----");
     if (self.wifiNametf.text.length == 0) {
         [MBProgressHUD showError:@"Wi-Fi账号不能为空"];
         return;
     }
    KDSBleAndWiFiSendPwdAndSSIDVC * vc = [KDSBleAndWiFiSendPwdAndSSIDVC new];
    self.model.wifiName = self.wifiNametf.text;
    vc.wifiNameStr = self.wifiNametf.text;
    vc.auto2Hand = self.auto2Hand;
    vc.bssid = self.bssidLb;
    vc.pwdStr = self.pwdtf.text;
    vc.model = self.model;
    vc.bleTool = self.bleTool;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)supportedHomeRoutersClickTap:(UITapGestureRecognizer *)btn
{
    KDSHomeRoutersVC * VC = [KDSHomeRoutersVC new];
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark --键盘弹出
- (void)keyboardWillChangeFrame:(NSNotification *)notification{
    
    //取出键盘动画的时间
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //取得键盘最后的frame
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //计算控制器的view需要平移的距离
    CGFloat transformY = keyboardFrame.origin.y - self.connectBtn.frame.size.height;
    NSLog(@"键盘上移的高度：%f-----取出键盘动画时间：%f",transformY,duration);
    [UIView animateWithDuration:duration animations:^{
        [self.connectBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.tipsLb8.mas_bottom).offset(20);
            make.width.equalTo(@200);
            make.height.equalTo(@44);
            make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        }];
    }];
}
#pragma mark --键盘收回
- (void)keyboardDidHide:(NSNotification *)notification{
    
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        [self.connectBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@200);
            make.height.equalTo(@44);
            make.bottom.mas_equalTo(self.routerProtocolView.mas_top).offset(KDSScreenHeight < 667 ? -20 : -40);
            make.centerX.mas_equalTo(self.supView.mas_centerX).offset(0);
        }];
    }];
}

-(void)jumpSetWifiClick:(UIButton *)sender
{
    [KDSTool openSettingsURLString];
}

#pragma mark - 通知中心

-(void)applicationBecomeActive:(NSNotification *)no{
    
    [[KDSAMapLocationManager sharedManager] initWithLocationManager];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _wifiNametf.text = [KDSAMapLocationManager sharedManager].ssid;
        self.bssidLb = [KDSAMapLocationManager sharedManager].bssid;
    });
}

///网络状态改变的通知。当网络不可用时，会将网关、猫眼和网关锁的状态设置为离线后发出通知KDSDeviceSyncNotification
- (void)networkReachabilityStatusDidChange:(NSNotification *)noti
{
    NSNumber *number = noti.userInfo[AFNetworkingReachabilityNotificationStatusItem];
    AFNetworkReachabilityStatus status = number.integerValue;
    switch (status)
    {
        case AFNetworkReachabilityStatusReachableViaWWAN://2G,3G,4G...
            [KDSUserManager sharedManager].netWorkIsWiFi = NO;
            [KDSUserManager sharedManager].netWorkIsAvailable = YES;
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi://wifi网络
            [KDSUserManager sharedManager].netWorkIsWiFi = YES;
            [KDSUserManager sharedManager].netWorkIsAvailable = YES;
            break;
        case AFNetworkReachabilityStatusNotReachable://无网络
            [KDSUserManager sharedManager].netWorkIsAvailable = NO;
            [KDSUserManager sharedManager].netWorkIsWiFi = NO;
            break;
        default://未识别的网络/不可达的网络
            break;
    }
}


@end
