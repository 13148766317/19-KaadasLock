//
//  KDSAddNewWiFiLockFailVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/3/10.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAddNewWiFiLockFailVC.h"
#import "KDSWifiLockHelpVC.h"
#import "KDSConnectedReconnectVC.h"
#import "KDSAddNewWiFiLockStep5VC.h"
#import "KDSAccordDistributionNetworkVC.h"
#import "KDSDeviceConnectionStep1VC.h"

@interface KDSAddNewWiFiLockFailVC ()

@end

@implementation KDSAddNewWiFiLockFailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"addFail");
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [self setUI];
}

-(void)setUI
{
    UIView * supView = [UIView new];
    supView.backgroundColor = UIColor.whiteColor;
    supView.layer.masksToBounds = YES;
    supView.layer.cornerRadius = 10;
    [self.view addSubview:supView];
    [supView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.top.equalTo(self.view.mas_top).offset(10);
        make.bottom.equalTo(self.view.mas_bottom).offset(-10);
    }];
    
    ///第一步
    UILabel * tipMsgLabe1 = [UILabel new];
    tipMsgLabe1.text = @"搜索不到要添加的设备";
    tipMsgLabe1.font = [UIFont systemFontOfSize:18];
    tipMsgLabe1.textColor = UIColor.blackColor;
    tipMsgLabe1.textAlignment = NSTextAlignmentCenter;
    [supView addSubview:tipMsgLabe1];
    [tipMsgLabe1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(supView.mas_top).offset(KDSScreenHeight > 667 ? 40 : 20);
        make.height.mas_equalTo(20);
        make.centerX.equalTo(supView);
    }];
    UIImageView * tipsImgView = [UIImageView new];
    tipsImgView.image = [UIImage imageNamed:@"addNewWiFiLockFailImg"];
    [supView addSubview:tipsImgView];
    [tipsImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipMsgLabe1.mas_bottom).offset(KDSScreenHeight > 667 ? 50 : 30);
        make.width.equalTo(@96.5);
        make.height.equalTo(@100);
        make.centerX.equalTo(supView);
    }];
    
    ///第一步
    UILabel * tipMsgLabe2 = [UILabel new];
    tipMsgLabe2.text = @"再次确认";
    tipMsgLabe2.font = [UIFont systemFontOfSize:18];
    tipMsgLabe2.textColor = UIColor.blackColor;
    tipMsgLabe2.textAlignment = NSTextAlignmentLeft;
    [supView addSubview:tipMsgLabe2];
    [tipMsgLabe2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipsImgView.mas_bottom).offset(KDSScreenHeight > 667 ? 55 : 35);
        make.height.mas_equalTo(20);
        make.left.mas_equalTo(supView).offset(KDSScreenWidth / 4);
        make.right.mas_equalTo(supView.mas_right).offset(-10);
    }];
    
    UILabel * tipMsgLabe = [UILabel new];
    tipMsgLabe.text = @"① 后面板Wi-Fi模块插紧";
    tipMsgLabe.font = [UIFont systemFontOfSize:14];
    tipMsgLabe.textColor = KDSRGBColor(102, 102, 102);
    tipMsgLabe.textAlignment = NSTextAlignmentLeft;
    [supView addSubview:tipMsgLabe];
    [tipMsgLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe2.mas_bottom).offset(15);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(supView).offset(KDSScreenWidth / 4);
        make.right.mas_equalTo(supView.mas_right).offset(-10);
    }];
    UILabel * tipMsg1Labe = [UILabel new];
    tipMsg1Labe.text = @"② 确定门锁已激活 ";
    tipMsg1Labe.font = [UIFont systemFontOfSize:14];
    tipMsg1Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg1Labe.textAlignment = NSTextAlignmentLeft;
    [supView addSubview:tipMsg1Labe];
    [tipMsg1Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(supView).offset(KDSScreenWidth / 4);
        make.right.mas_equalTo(supView.mas_right).offset(-10);
    }];
    UILabel * tipMsg2Labe = [UILabel new];
    tipMsg2Labe.text = @"③ 门锁是否已联网";
    tipMsg2Labe.font = [UIFont systemFontOfSize:14];
    tipMsg2Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg2Labe.textAlignment = NSTextAlignmentLeft;
    [supView addSubview:tipMsg2Labe];
    [tipMsg2Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsg1Labe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(supView).offset(KDSScreenWidth / 4);
        make.right.mas_equalTo(supView.mas_right).offset(-10);
        
    }];
    UILabel * tipMsg3Labe = [UILabel new];
    tipMsg3Labe.text = @"④ 保持门锁唤醒状态";
    tipMsg3Labe.font = [UIFont systemFontOfSize:14];
    tipMsg3Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg3Labe.textAlignment = NSTextAlignmentLeft;
    [supView addSubview:tipMsg3Labe];
    [tipMsg3Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsg2Labe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(supView).offset(KDSScreenWidth / 4);
        make.right.mas_equalTo(supView.mas_right).offset(-10);
        
    }];
    
    UIButton * againSearchBtn = [UIButton new];
    [againSearchBtn setTitle:@"重新搜索门锁" forState:UIControlStateNormal];
    [againSearchBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    [againSearchBtn addTarget:self action:@selector(againSearchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    againSearchBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    againSearchBtn.backgroundColor = UIColor.whiteColor;
    againSearchBtn.layer.borderWidth = 1;
    againSearchBtn.layer.borderColor = KDSRGBColor(31, 150, 247).CGColor;
    againSearchBtn.layer.masksToBounds = YES;
    againSearchBtn.layer.cornerRadius = 20;
    [supView addSubview:againSearchBtn];
    [againSearchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.centerX.equalTo(supView);
        make.bottom.equalTo(supView.mas_bottom).offset(KDSScreenHeight < 667 ? -40 : -80);
    }];
    UIButton * otherJoinBtn = [UIButton new];
    [otherJoinBtn setTitle:@"其他配网方式" forState:UIControlStateNormal];
    [otherJoinBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [otherJoinBtn addTarget:self action:@selector(otherJoinBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    otherJoinBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    otherJoinBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    otherJoinBtn.layer.masksToBounds = YES;
    otherJoinBtn.layer.cornerRadius = 20;
    [supView addSubview:otherJoinBtn];
    [otherJoinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.centerX.equalTo(supView);
        make.bottom.equalTo(againSearchBtn.mas_top).offset(KDSScreenHeight > 667 ? -30 : -16);
        
    }];
    
}

#pragma mark 控件点击事件

-(void)navRightClick
{
    KDSWifiLockHelpVC * vc = [KDSWifiLockHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

//其他配网方式
-(void)otherJoinBtnClick:(UIButton *)sender
{
    KDSConnectedReconnectVC * vc = [KDSConnectedReconnectVC new];
    [self.navigationController pushViewController:vc animated:YES];
}
//重新搜索门锁
-(void)againSearchBtnClick:(UIButton *)sender
{
//    for (UIViewController *controller in self.navigationController.viewControllers) {
//        if ([controller isKindOfClass:[KDSAddNewWiFiLockStep5VC class]]) {
//            KDSAddNewWiFiLockStep5VC *A =(KDSAddNewWiFiLockStep5VC *)controller;
//            [self.navigationController popToViewController:A animated:YES];
//        }if ([controller isKindOfClass:[KDSAccordDistributionNetworkVC class]]) {
//            KDSAccordDistributionNetworkVC * B = (KDSAccordDistributionNetworkVC *)controller;
//            [self.navigationController popToViewController:B animated:YES];
//        }
//    }
    [self.navigationController popViewControllerAnimated:YES];

}

-(void)navBackClick
{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[KDSAddNewWiFiLockStep5VC class]]) {
            KDSAddNewWiFiLockStep5VC *A =(KDSAddNewWiFiLockStep5VC *)controller;
            [self.navigationController popToViewController:A animated:YES];
        }
//        if ([controller isKindOfClass:[KDSAccordDistributionNetworkVC class]]) {
//            KDSAccordDistributionNetworkVC * B = (KDSAccordDistributionNetworkVC *)controller;
//            [self.navigationController popToViewController:B animated:YES];
//        }
    }
//    [self.navigationController popViewControllerAnimated:YES];
}

@end
