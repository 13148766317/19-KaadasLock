//
//  KDSAddCatEye4VC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/10.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSAddCatEye4VC.h"
#import "KDSSaveCatEyeVC.h"
#import "KDSBindingGatewayVC.h"
#import "KDSAddDeviceVC.h"
#import "KDSCateyeHelpVC.h"

@interface KDSAddCatEye4VC ()

@end

@implementation KDSAddCatEye4VC

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
    
    ///下一步
    NSString * SignOutStr;
    NSString * iconImgName;
    NSString * tipsIsBoolSuccess;
    if (self.isSuccess) {
        SignOutStr =Localized(@"nextStep");
        tipsIsBoolSuccess = Localized(@"Cat'sEyeConnectionSuccessful");
        iconImgName = @"addCateyeSuccess";
    }else{
        SignOutStr = Localized(@"Sign out");
        tipsIsBoolSuccess = Localized(@"addCatEyeFail");
        iconImgName = @"addCateyeFail";
    }
    
    UIButton * nextStepBtn = [UIButton new];
    nextStepBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    [nextStepBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [nextStepBtn setTitle:SignOutStr forState:UIControlStateNormal];
    [nextStepBtn addTarget:self action:@selector(nextStepBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    nextStepBtn.layer.cornerRadius = 22;
    [self.view addSubview:nextStepBtn];
    [nextStepBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@44);
        make.width.mas_equalTo(@200);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-KDSSSALE_HEIGHT(50));
    }];
    ///添加门锁的logo
    UIImageView * addZigBeeLocklogoImg = [UIImageView new];
    addZigBeeLocklogoImg.image = [UIImage imageNamed:iconImgName];
    [self.view addSubview:addZigBeeLocklogoImg];
    [addZigBeeLocklogoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(89);
        make.width.mas_equalTo(127);
        make.top.mas_equalTo(self.view.mas_top).offset(KDSSSALE_HEIGHT(90));
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    
    UILabel * tipMsgLabe = [UILabel new];
    tipMsgLabe.text = tipsIsBoolSuccess;
    tipMsgLabe.font = [UIFont systemFontOfSize:13];
    tipMsgLabe.textColor = UIColor.blackColor;
    tipMsgLabe.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipMsgLabe];
    [tipMsgLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(addZigBeeLocklogoImg.mas_bottom).offset(28);
        make.height.mas_equalTo(14);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    ///入网成功的提示
    if (!self.isSuccess) {
        
        nextStepBtn.backgroundColor =UIColor.whiteColor;
        [nextStepBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
        
        [addZigBeeLocklogoImg mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(71);
            make.width.mas_equalTo(117);
            make.top.mas_equalTo(self.view.mas_top).offset(kNavBarHeight+kStatusBarHeight+40);
            make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        }];
        UIButton * continueBtn = [UIButton new];
        [continueBtn setTitle:Localized(@"isConnect") forState:UIControlStateNormal];
        [continueBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [continueBtn addTarget:self action:@selector(continueBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        continueBtn.backgroundColor = KDSRGBColor(31, 150, 247);
        continueBtn.layer.cornerRadius = 22;
        [self.view addSubview:continueBtn];
        [continueBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(@44);
            make.width.mas_equalTo(@200);
            make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
            make.bottom.mas_equalTo(nextStepBtn.mas_top).offset(-26);
        }];
        
        ///提示视图
        CGFloat height = KDSScreenHeight < 375 ? 100:150;
        UIView * tipsView = [UIView new];
        tipsView.backgroundColor = UIColor.whiteColor;
        tipsView.layer.cornerRadius = 4;
        [self.view addSubview:tipsView];
        [tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view.mas_left).offset(15);
            make.right.mas_equalTo(self.view.mas_right).offset(-15);
            make.height.mas_equalTo(height);
            make.top.mas_equalTo(tipMsgLabe.mas_bottom).offset(KDSSSALE_HEIGHT(64));
        }];
        
        UIView * line1 = [UIView new];
        [tipsView addSubview:line1];
        line1.backgroundColor = KDSRGBColor(234, 233, 233);
        [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0.7);
            make.left.mas_equalTo(tipsView.mas_left).offset(57);
            make.top.mas_equalTo(tipsView.mas_top).offset(height/2);
            make.right.mas_equalTo(tipsView.mas_right).offset(0);
        }];
        
        
        UILabel * label1 = [UILabel new];
        label1.text = @"1";
        label1.textColor = UIColor.whiteColor;
        label1.font = [UIFont systemFontOfSize:15];
        label1.backgroundColor = KDSRGBColor(31, 150, 247);
        label1.layer.cornerRadius = 17/2;
        label1.textAlignment = NSTextAlignmentCenter;
        label1.layer.masksToBounds = YES;
        [tipsView addSubview:label1];
        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(17);
            make.top.mas_equalTo(tipsView.mas_top).offset(height/4);
            make.left.mas_equalTo(tipsView.mas_left).offset(23);
        }];
        
        UILabel * label2 = [UILabel new];
        label2.text = @"2";
        label2.textColor = UIColor.whiteColor;
        label2.font = [UIFont systemFontOfSize:15];
        label2.backgroundColor = KDSRGBColor(31, 150, 247);
        label2.layer.cornerRadius = 17/2;
        label2.textAlignment = NSTextAlignmentCenter;
        label2.layer.masksToBounds = YES;
        [tipsView addSubview:label2];
        [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(17);
            make.bottom.mas_equalTo(tipsView.mas_bottom).offset(-height/4);
            make.left.mas_equalTo(tipsView.mas_left).offset(23);
        }];
        
        
        UILabel * tipMsgLabe1 = [UILabel new];
        tipMsgLabe1.text = Localized(@"EquipmentConnectionTimeout");
        tipMsgLabe1.font = [UIFont systemFontOfSize:13];
        tipMsgLabe1.textColor = UIColor.blackColor;
        tipMsgLabe1.textAlignment = NSTextAlignmentLeft;
        [tipsView addSubview:tipMsgLabe1];
        [tipMsgLabe1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(label1.mas_right).offset(10);
            make.right.mas_equalTo(tipsView.mas_right).offset(0);
            make.height.mas_equalTo(14);
            make.top.mas_equalTo(tipsView.mas_top).offset(height/4);
        }];
        
        UILabel * tipMsgLabe2 = [UILabel new];
        tipMsgLabe2.text = Localized(@"NetworkCauseConnectionFailure");
        tipMsgLabe2.font = [UIFont systemFontOfSize:13];
        tipMsgLabe2.textColor = UIColor.blackColor;
        tipMsgLabe2.textAlignment = NSTextAlignmentLeft;
        [tipsView addSubview:tipMsgLabe2];
        [tipMsgLabe2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(label2.mas_right).offset(10);
            make.right.mas_equalTo(tipsView.mas_right).offset(0);
            make.height.mas_equalTo(14);
            make.bottom.mas_equalTo(tipsView.mas_bottom).offset(-height/4);
        }];
    }
}

#pragma mark 控件点击事件

-(void)nextStepBtnClick:(UIButton *)sender
{
    if (self.isSuccess) {
        ///成功进行下一步
        KDSSaveCatEyeVC * VC = [KDSSaveCatEyeVC new];
        VC.gatewayModel = self.gatewayModel;
        VC.deviceId = self.deviceId;
        [self.navigationController pushViewController:VC animated:YES];
    }else{
        ///退出：跳转至 添加设备列表
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[KDSAddDeviceVC class]]) {
                KDSAddDeviceVC *A =(KDSAddDeviceVC *)controller;
                [self.navigationController popToViewController:A animated:YES];
            }
        }
    }
    
}
///是否继续连接：返回到网关列表
-(void)continueBtnClick:(UIButton *)sender
{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[KDSBindingGatewayVC class]]) {
            KDSBindingGatewayVC *A =(KDSBindingGatewayVC *)controller;
            [self.navigationController popToViewController:A animated:YES];
        }
    }
}

////返回到网关列表
-(void)navBackClick
{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[KDSBindingGatewayVC class]]) {
            KDSBindingGatewayVC *A =(KDSBindingGatewayVC *)controller;
            [self.navigationController popToViewController:A animated:YES];
        }
    }
}

-(void)navRightClick
{
    KDSCateyeHelpVC * vc = [KDSCateyeHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
