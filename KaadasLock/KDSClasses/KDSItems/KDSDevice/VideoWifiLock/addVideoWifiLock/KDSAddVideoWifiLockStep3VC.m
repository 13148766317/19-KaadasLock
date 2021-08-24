//
//  KDSAddVideoWifiLockStep3VC.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/8.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAddVideoWifiLockStep3VC.h"
#import "KDSVideoWiFiLockUpDataAdminiPwdVC.h"
#import "KDSAddVideoWifiLockConfigureWiFiVC.h"
#import "KDSXMMediaLockHelpVC.h"

@interface KDSAddVideoWifiLockStep3VC ()

@property (nonatomic, strong) UIView *routerProtocolView;

@end

@implementation KDSAddVideoWifiLockStep3VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"addDoorLock");
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [self setUI];
}

-(void)setUI
{
    UIView * supView = [UIView new];
    supView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:supView];
    [supView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).offset(3);
    }];
    
    ///第一步
    UILabel * tipMsgLabe1 = [UILabel new];
    tipMsgLabe1.text = @"第三步：已进入管理配置模式";
    if (self.lock) {
        tipMsgLabe1.text = @"第一步：已进入管理配置模式";
    }if (self.isAgainNetwork) {
        tipMsgLabe1.text = @"第二步：已进入管理配置模式";
    }
    tipMsgLabe1.font = [UIFont systemFontOfSize:18];
    tipMsgLabe1.textColor = UIColor.blackColor;
    tipMsgLabe1.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe1];
    [tipMsgLabe1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(35);
        make.height.mas_equalTo(20);
        make.width.equalTo(@275);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    UILabel * tipMsgLabe = [UILabel new];
    tipMsgLabe.text = @"① 按键区输入“*”两次";
    tipMsgLabe.font = [UIFont systemFontOfSize:14];
    tipMsgLabe.textColor = KDSRGBColor(102, 102, 102);
    tipMsgLabe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe];
    [tipMsgLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe1.mas_bottom).offset(KDSScreenHeight < 667 ? 20 : 35);
        make.height.mas_equalTo(16);
        make.width.equalTo(@275);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    UILabel * tipMsg1Labe = [UILabel new];
    tipMsg1Labe.text = @"② 输入已修改的管理密码“********”";
    tipMsg1Labe.font = [UIFont systemFontOfSize:14];
    tipMsg1Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg1Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg1Labe];
    [tipMsg1Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.width.equalTo(@275);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
                             
    UILabel * tipMsg2Labe = [UILabel new];
    tipMsg2Labe.text = @"③ 按“#”确认，";
    tipMsg2Labe.font = [UIFont systemFontOfSize:14];
    tipMsg2Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg2Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg2Labe];
    [tipMsg2Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsg1Labe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.width.equalTo(@275);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    UILabel * tipMsg22Labe = [UILabel new];
    tipMsg22Labe.text = @"④ 语音播报：“已进入管理模式”";
    tipMsg22Labe.font = [UIFont systemFontOfSize:14];
    tipMsg22Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg22Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg22Labe];
    [tipMsg22Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsg2Labe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.width.equalTo(@275);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    UILabel * tipMsg3Labe = [UILabel new];
    tipMsg3Labe.text = @"⑤ 根据语音提示，按“4”选择“配网设置”";
    tipMsg3Labe.font = [UIFont systemFontOfSize:14];
    tipMsg3Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg3Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg3Labe];
    [tipMsg3Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsg22Labe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.width.equalTo(@275);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    UILabel * tipMsg4Labe = [UILabel new];
    tipMsg4Labe.text = @"⑥ 语音播报：“已进入配网状态”";
    tipMsg4Labe.font = [UIFont systemFontOfSize:14];
    tipMsg4Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg4Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg4Labe];
    [tipMsg4Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsg3Labe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.width.equalTo(@275);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    ///暂时没有用到，先隐藏
    UILabel * tipMsg5Labe = [UILabel new];
    tipMsg5Labe.text = @"⑦ 语音播报：“配网中，请稍后”";
    tipMsg5Labe.hidden = YES;
    tipMsg5Labe.font = [UIFont systemFontOfSize:14];
    tipMsg5Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg5Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg5Labe];
    [tipMsg5Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsg4Labe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.width.equalTo(@275);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    self.routerProtocolView = [UIView new];
    self.routerProtocolView.backgroundColor = UIColor.clearColor;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(supportedHomeRoutersClickTap:)];
    [self.routerProtocolView addGestureRecognizer:tap];
    [self.view addSubview:self.routerProtocolView];
    [self.routerProtocolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@30);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-45-kBottomSafeHeight);
    }];
    
    UILabel * routerProtocolLb = [UILabel new];
    routerProtocolLb.text = @"如何修改初始管理密码？";
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
    
    UIButton * connectBtn = [UIButton new];
    [connectBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [connectBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [connectBtn addTarget:self action:@selector(nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    connectBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    connectBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    connectBtn.layer.masksToBounds = YES;
    connectBtn.layer.cornerRadius = 20;
    [self.view addSubview:connectBtn];
    [connectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.bottom.mas_equalTo(self.routerProtocolView.mas_top).offset(-20);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
}

#pragma mark --如何修改初始管理密码？
-(void)supportedHomeRoutersClickTap:(UITapGestureRecognizer *)btn
{
    KDSVideoWiFiLockUpDataAdminiPwdVC * vc = [KDSVideoWiFiLockUpDataAdminiPwdVC new];
    [self.navigationController pushViewController:vc animated:YES];
}
///下一步
-(void)nextBtnClick:(UIButton *)sender
{
    KDSAddVideoWifiLockConfigureWiFiVC * vc = [KDSAddVideoWifiLockConfigureWiFiVC new];
    vc.lock = self.lock;
    vc.isAgainNetwork = self.isAgainNetwork;
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(void)navRightClick
{
    KDSXMMediaLockHelpVC * vc = [KDSXMMediaLockHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
