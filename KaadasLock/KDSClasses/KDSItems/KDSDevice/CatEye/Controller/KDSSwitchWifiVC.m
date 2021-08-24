//
//  KDSSwitchWifiVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/30.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSSwitchWifiVC.h"
#import "KDSCateyeHelpVC.h"

@interface KDSSwitchWifiVC ()

@end

@implementation KDSSwitchWifiVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"addCatEye");
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [self setUI];
}

-(void)navBackClick
{
    if (self.block) {
        self.block(@"");
    }
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)setUI
{
    ///下一步
    UIButton * nextBtn = [UIButton new];
    nextBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    [nextBtn setTitle:Localized(@"Forward to Switch WIFI") forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.layer.cornerRadius = 22;
    [self.view addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@44);
        make.width.mas_equalTo(@200);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-KDSSSALE_HEIGHT(50));
    }];
    ///提示视图
    UIView * tipsView = [UIView new];
    tipsView.backgroundColor = UIColor.whiteColor;
    tipsView.layer.cornerRadius = 4;
    [self.view addSubview:tipsView];
    [tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(15);
        make.right.mas_equalTo(self.view.mas_right).offset(-15);
        make.height.mas_equalTo(@75);
        make.centerY.mas_equalTo(self.view.mas_centerY).offset(50);
    }];
    UIImageView * tipImg = [UIImageView new];
    tipImg.image = [UIImage imageNamed:@"exclamationMark"];
    [tipsView addSubview:tipImg];
    [tipImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(@17);
        make.centerY.mas_equalTo(tipsView.mas_centerY).offset(0);
        make.left.mas_equalTo(tipsView.mas_left).offset(23);
    }];
    UILabel * tipMsgLabe = [UILabel new];
    tipMsgLabe.text = Localized(@"switch network gateway WiFi");
    tipMsgLabe.font = [UIFont systemFontOfSize:13];
    tipMsgLabe.textColor = UIColor.blackColor;
    tipMsgLabe.textAlignment = NSTextAlignmentLeft;
    [tipsView addSubview:tipMsgLabe];
    [tipMsgLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tipImg.mas_right).offset(10);
        make.right.mas_equalTo(tipsView.mas_right).offset(0);
        make.height.mas_equalTo(@14);
        make.centerY.mas_equalTo(tipsView.mas_centerY).offset(0);
    }];
    
    ///添加门锁的logo
    UIImageView * addZigBeeLocklogoImg = [UIImageView new];
    addZigBeeLocklogoImg.image = [UIImage imageNamed:@"gwAndWifiAtypism"];
    [self.view addSubview:addZigBeeLocklogoImg];
    [addZigBeeLocklogoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@50);
        make.width.mas_equalTo(@166);
        make.top.mas_equalTo(self.view.mas_top).offset(kNavBarHeight+kStatusBarHeight+40);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    
}

#pragma mark --手势事件

-(void)nextBtnClick:(UIButton *)sender
{
    [KDSTool openSettingsURLString];
}

-(void)navRightClick
{
    KDSCateyeHelpVC * vc = [KDSCateyeHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
