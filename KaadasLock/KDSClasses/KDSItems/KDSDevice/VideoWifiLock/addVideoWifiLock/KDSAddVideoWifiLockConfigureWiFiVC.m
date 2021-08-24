//
//  KDSAddVideoWifiLockConfigureWiFiVC.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/7.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAddVideoWifiLockConfigureWiFiVC.h"
#import "KDSXMMediaLockHelpVC.h"
#import "KDSHomeRoutersVC.h"
#import "KDSAMapLocationManager.h"
#import "KDSAccordDistributionNetworkVC.h"
#import "KDSAddVideoWifiLockStep5VC.h"

@interface KDSAddVideoWifiLockConfigureWiFiVC ()
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
///手动编辑前的wifi的ssid
@property (nonatomic, strong) NSString * wifiNametemp;
///wifi的bssid
@property (nonatomic, strong) NSString * bssidLb;

@end

///label之间多行显示的行间距
#define labelWidth  3

@implementation KDSAddVideoWifiLockConfigureWiFiVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"addDoorLock");
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
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
    
    ///第三步
    UILabel * tipMsgLabe1 = [UILabel new];
    tipMsgLabe1.text = @"第四步：配置连接Wi-Fi ";
    if (self.lock) {
        tipMsgLabe1.text = @"第二步：配置连接Wi-Fi ";
    }if (self.isAgainNetwork) {
        tipMsgLabe1.text = @"第三步：配置连接Wi-Fi ";
    }
     tipMsgLabe1.font = [UIFont systemFontOfSize:18];
     tipMsgLabe1.textColor = UIColor.blackColor;
     tipMsgLabe1.textAlignment = NSTextAlignmentLeft;
     [self.view addSubview:tipMsgLabe1];
     [tipMsgLabe1 mas_makeConstraints:^(MASConstraintMaker *make) {
         make.top.mas_equalTo(self.view.mas_top).offset(KDSScreenHeight > 667 ? 51 : 20);
         make.height.mas_equalTo(20);
         make.left.mas_equalTo(self.view).offset(KDSScreenWidth / 4);
         make.right.mas_equalTo(self.view.mas_right).offset(-10);
     }];
    
     UILabel * tipMsgLabe = [UILabel new];
     tipMsgLabe.text = @"① 请输入要连接的Wi-Fi信息";
     tipMsgLabe.font = [UIFont systemFontOfSize:14];
     tipMsgLabe.textColor = KDSRGBColor(126, 126, 126);
     tipMsgLabe.textAlignment = NSTextAlignmentLeft;
     [self.view addSubview:tipMsgLabe];
     [tipMsgLabe mas_makeConstraints:^(MASConstraintMaker *make) {
         make.top.mas_equalTo(tipMsgLabe1.mas_bottom).offset(KDSScreenHeight < 667 ? 20 : 35);
         make.height.mas_equalTo(16);
         make.left.mas_equalTo(self.view).offset(KDSScreenWidth / 4);
         make.right.mas_equalTo(self.view.mas_right).offset(-10);
     }];
     
     UILabel * tipMsg1Labe = [UILabel new];
     tipMsg1Labe.text = @"② 暂不支持5G频段的Wi-Fi以及酒店机场需认证的Wi-Fi";
     tipMsg1Labe.font = [UIFont systemFontOfSize:14];
     tipMsg1Labe.textColor = KDSRGBColor(126, 126, 126);
     tipMsg1Labe.textAlignment = NSTextAlignmentLeft;
     tipMsg1Labe.numberOfLines = 0;
     [self setLabelSpace:tipMsg1Labe withSpace:labelWidth withFont:[UIFont systemFontOfSize:14]];
     [self.view addSubview:tipMsg1Labe];
     [tipMsg1Labe mas_makeConstraints:^(MASConstraintMaker *make) {
         make.top.mas_equalTo(tipMsgLabe.mas_bottom).offset(0);
         make.height.mas_equalTo(45);
         make.left.mas_equalTo(self.view.mas_left).offset(KDSScreenWidth / 4);
         make.right.mas_equalTo(self.view.mas_right).offset(-(KDSScreenWidth / 4));
     }];
    
    UIView * line = [UIView new];
    line.backgroundColor = KDSRGBColor(220, 220, 220);
    [_supView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipMsg1Labe.mas_bottom).offset(70);
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
    _wifiNametf.clearButtonMode = UITextFieldViewModeAlways;
    _wifiNametf.textAlignment = NSTextAlignmentLeft;
    _wifiNametf.font = [UIFont systemFontOfSize:13];
    _wifiNametf.textColor = UIColor.blackColor;
    //取消默认大写属性
    _wifiNametf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [_wifiNametf addTarget:self action:@selector(wifiNametextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.supView addSubview:_wifiNametf];
    [_wifiNametf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(wifiNameIconImg.mas_right).offset(7);
        make.right.mas_equalTo(self.supView.mas_right).offset(-25.0);
        make.bottom.mas_equalTo(line.mas_bottom).offset(0);
        make.height.equalTo(@30);
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
        make.bottom.equalTo(self.supView.mas_bottom).offset(-45-kBottomSafeHeight);
    }];
    
    UILabel * routerProtocolLb = [UILabel new];
    routerProtocolLb.text = @"查看门锁Wi-Fi支持家庭路由器";
    routerProtocolLb.textColor = KDSRGBColor(31, 150, 247);
    routerProtocolLb.textAlignment = NSTextAlignmentCenter;
    routerProtocolLb.font = [UIFont systemFontOfSize:14];
    [self.routerProtocolView addSubview:routerProtocolLb];
    //取消下划线
//    NSRange strRange = {0,[routerProtocolLb.text length]};
//    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:routerProtocolLb.text];
//    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
//    routerProtocolLb.attributedText = str;
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
        make.bottom.mas_equalTo(self.routerProtocolView.mas_top).offset(-20);
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
    KDSXMMediaLockHelpVC * vc = [KDSXMMediaLockHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
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
     }if (self.pwdtf.text.length == 0) {
         [MBProgressHUD showError:@"Wi-Fi密码不能为空"];
         return;
     }

    KDSAddVideoWifiLockStep5VC * vc = [KDSAddVideoWifiLockStep5VC new];
    vc.ssid = self.wifiNametf.text;
    vc.pwd = self.pwdtf.text;
    vc.lock = self.lock;
    vc.isAgainNetwork = self.isAgainNetwork;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark --查看门锁wifi支持的家庭路由器
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

-(void)setLabelSpace:(UILabel*)label withSpace:(CGFloat)space withFont:(UIFont*)font  {
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = space; //设置行间距
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    //设置字间距 NSKernAttributeName:@1.5f
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@0.0f};
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:label.text attributes:dic];
    label.attributedText = attributeStr;
}

@end
