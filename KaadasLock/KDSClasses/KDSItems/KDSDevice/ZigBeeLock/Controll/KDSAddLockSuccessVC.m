//
//  KDSAddLockSuccessVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/10.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSAddLockSuccessVC.h"
#import "KDSSaveLockVC.h"
#import "KDSAddDeviceVC.h"

@interface KDSAddLockSuccessVC ()

@end

@implementation KDSAddLockSuccessVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"addDoorLock");
    [self setUI];
}

#pragma mark 控件点击事件

-(void)nextStepBtnClick:(UIButton *)sender
{
    if (self.isSuccess) {
        KDSSaveLockVC * VC = [KDSSaveLockVC new];
        VC.gw = self.gw;
        VC.device = self.device;
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
-(void)ConnectionBtnClick:(UIButton *)sender
{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[KDSBindingGatewayVC class]]) {
            KDSBindingGatewayVC *A =(KDSBindingGatewayVC *)controller;
            [self.navigationController popToViewController:A animated:YES];
        }
    }

}
///返回：网关列表
-(void)navBackClick
{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[KDSBindingGatewayVC class]]) {
            KDSBindingGatewayVC *A =(KDSBindingGatewayVC *)controller;
            [self.navigationController popToViewController:A animated:YES];
        }
    }
}
-(void)setUI
{
    ///下一步
    NSString * nextStepBtnTitle;
    NSString * addZBLockImgName;
    NSString * tipMsgLbText;
    UIButton * nextStepBtn = [UIButton new];
    if (self.isSuccess) {
        nextStepBtnTitle = Localized(@"nextStep");
        addZBLockImgName = @"添加智能锁_入网成功";
        tipMsgLbText = Localized(@"addZBLockSuccess");
        nextStepBtn.backgroundColor = KDSRGBColor(31, 150, 247);
        [nextStepBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    }else{
        nextStepBtnTitle = Localized(@"Sign out");
        addZBLockImgName = @"AddGWLockFail_pic";
        tipMsgLbText = Localized(@"addZBLockFail");
        nextStepBtn.backgroundColor = UIColor.whiteColor;
        [nextStepBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    }
    
    [nextStepBtn setTitle:nextStepBtnTitle forState:UIControlStateNormal];
    [nextStepBtn addTarget:self action:@selector(nextStepBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    nextStepBtn.layer.cornerRadius = 22;
    [self.view addSubview:nextStepBtn];
    [nextStepBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@44);
        make.width.mas_equalTo(@200);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-KDSSSALE_HEIGHT(50));
    }];
    
    if (!self.isSuccess) {
        ///是否继续连接
        UIButton * isConnectionBtn = [UIButton new];
        [isConnectionBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        isConnectionBtn.backgroundColor = KDSRGBColor(31, 150, 247);
        [isConnectionBtn setTitle:Localized(@"isConnect") forState:UIControlStateNormal];
        [isConnectionBtn addTarget:self action:@selector(ConnectionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        isConnectionBtn.layer.cornerRadius = 22;
        [self.view addSubview:isConnectionBtn];
        [isConnectionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(@44);
            make.width.mas_equalTo(@200);
            make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
            make.bottom.mas_equalTo(nextStepBtn.mas_top).offset(-26);
        }];
    }
    ///添加门锁的logo
    UIImageView * addZigBeeLocklogoImg = [UIImageView new];
    addZigBeeLocklogoImg.image = [UIImage imageNamed:addZBLockImgName];
    [self.view addSubview:addZigBeeLocklogoImg];
    [addZigBeeLocklogoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(95);
        make.width.mas_equalTo(142);
        make.top.mas_equalTo(self.view.mas_top).offset(kNavBarHeight+kStatusBarHeight+40);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    
    UILabel * tipMsgLabe = [UILabel new];
    tipMsgLabe.text = tipMsgLbText;
    tipMsgLabe.font = [UIFont systemFontOfSize:13];
    tipMsgLabe.textColor = UIColor.blackColor;
    tipMsgLabe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe];
    [tipMsgLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(addZigBeeLocklogoImg.mas_bottom).offset(KDSSSALE_HEIGHT(27));
        make.height.mas_equalTo(14);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
}


@end
