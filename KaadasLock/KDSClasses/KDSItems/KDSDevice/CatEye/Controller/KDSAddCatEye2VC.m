//
//  KDSAddCatEye2VC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/10.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSAddCatEye2VC.h"
#import "KDSAddCatEye3VC.h"
#import "KDSMQTT.h"
#import "MBProgressHUD+MJ.h"
#import "KDSAddCatEyeVC.h"
#import "KDSCateyeHelpVC.h"

@interface KDSAddCatEye2VC ()
@property (nonatomic,readwrite,strong)NSString *deviceMAC;
@property (nonatomic,readwrite,strong)NSString *deviceID;
@property (nonatomic,readwrite,strong)NSString *deviceSN;
@end

@implementation KDSAddCatEye2VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"addCatEye");
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [self setUI];
}

-(void)setUI
{
    ///添加门锁的logo
    UIImageView * addZigBeeLocklogoImg = [UIImageView new];
    addZigBeeLocklogoImg.image = [UIImage imageNamed:@"添加ZigBee_添加猫眼_入网成功"];
    [self.view addSubview:addZigBeeLocklogoImg];
    [addZigBeeLocklogoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(203);
        make.height.mas_equalTo(147);
        make.right.mas_equalTo(self.view.mas_right).offset(-KDSSSALE_WIDTH(43));
        make.centerY.mas_equalTo(self.view.mas_centerY).offset(0);
    }];
   ///提示语：第二步
    UILabel * tipMsgLabe = [UILabel new];
    tipMsgLabe.text = Localized(@"theSecondStep");
    tipMsgLabe.font = [UIFont systemFontOfSize:17];
    tipMsgLabe.textColor = UIColor.blackColor;
    tipMsgLabe.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipMsgLabe];
    [tipMsgLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(16);
        make.top.mas_equalTo(self.view.mas_top).offset(55);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    ///提示语：配置网络
    UILabel * tipMsg1Lb = [UILabel new];
    tipMsg1Lb.text = Localized(@"netWork");
    tipMsg1Lb.font = [UIFont systemFontOfSize:13];
    tipMsg1Lb.textColor = KDSRGBColor(153, 153, 153);
    tipMsg1Lb.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipMsg1Lb];
    [tipMsg1Lb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(16);
        make.top.mas_equalTo(tipMsgLabe.mas_bottom).offset(10);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    ///提示语：按猫眼上的配网按钮听到正在配置网络
    UILabel * detailLabe = [UILabel new];
    detailLabe.text = Localized(@"cat'sEyeNetworkBeingConfigured");
    detailLabe.font = [UIFont systemFontOfSize:13];
    detailLabe.textColor = KDSRGBColor(153, 153, 153);
    detailLabe.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:detailLabe];
    [detailLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(16);
        make.top.mas_equalTo(tipMsg1Lb.mas_bottom).offset(10);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    
    ///下一步
    UIButton * nextStepBtn = [UIButton new];
    nextStepBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    [nextStepBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [nextStepBtn setTitle:Localized(@"nextStep") forState:UIControlStateNormal];
    [nextStepBtn addTarget:self action:@selector(nextStepBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    nextStepBtn.layer.cornerRadius = 22;
    [self.view addSubview:nextStepBtn];
    [nextStepBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@44);
        make.width.mas_equalTo(@200);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-KDSSSALE_HEIGHT(50));
    }];
}

-(void)nextStepBtnClick:(UIButton *)sender
{
    KDSAddCatEyeVC * vc = [KDSAddCatEyeVC new];
    vc.gateway = self.gateway;
    vc.gwConfigWifiSsid = self.gwSid;
    vc.gwConfigPwd = self.wifiPwd;
    [self.navigationController pushViewController:vc animated:YES];
   
}

#pragma mark 控件点击事件

-(void)navRightClick
{
    KDSCateyeHelpVC * vc = [KDSCateyeHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
