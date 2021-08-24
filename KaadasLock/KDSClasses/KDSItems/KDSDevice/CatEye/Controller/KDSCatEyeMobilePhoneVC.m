//
//  KDSCatEyeMobilePhoneVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/5/8.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSCatEyeMobilePhoneVC.h"
#import "KDSGenerateQRCodeVC.h"
#import "KDSCateyeHelpVC.h"

@interface KDSCatEyeMobilePhoneVC ()

@end

@implementation KDSCatEyeMobilePhoneVC

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
    UILabel * tipsLb = [UILabel new];
    tipsLb.text = @"手机屏幕对准";
    tipsLb.textColor = KDSRGBColor(51, 51, 51);
    tipsLb.textAlignment = NSTextAlignmentCenter;
    tipsLb.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:tipsLb];
    [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@20);
        make.top.equalTo(KDSScreenHeight < 667 ? @30 : @80);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    UIImageView * tipsImgView = [UIImageView new];
    tipsImgView.image = [UIImage imageNamed:@"catEyeMobilePhone"];
    [self.view addSubview:tipsImgView];
    [tipsImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@206.5);
        make.height.equalTo(@156);
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
    
    
    UIButton * nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [nextBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [nextBtn addTarget:self action:@selector(nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    nextBtn.layer.cornerRadius = 22;
    nextBtn.layer.masksToBounds = YES;
    [self.view addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(-50);
    }];
    
    UILabel * tipsLb2 = [UILabel new];
    tipsLb2.text = @"将手机移动到猫头前面5-10cm";
    tipsLb2.textColor = KDSRGBColor(51, 51, 51);
    tipsLb2.textAlignment = NSTextAlignmentCenter;
    tipsLb2.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:tipsLb2];
    [tipsLb2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@15);
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(nextBtn.mas_top).offset(KDSScreenHeight < 667 ? -20 : -46);
    }];
    
    UIImageView * tipsImgView2 = [UIImageView new];
    tipsImgView2.image = [UIImage imageNamed:@"提示"];
    [self.view addSubview:tipsImgView2];
    [tipsImgView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@12);
        make.right.equalTo(tipsLb2.mas_left).offset(-7);
        make.bottom.equalTo(nextBtn.mas_top).offset(KDSScreenHeight < 667 ? -22 : -48);
    }];
    
}

-(void)nextBtnClick:(UIButton *)sender
{
    KDSGenerateQRCodeVC *vc = [[KDSGenerateQRCodeVC alloc] init];
    vc.gwConfigPwd = self.gwConfigPwd;
    vc.gwConfigWifiSsid = self.gwConfigWifiSsid;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)navRightClick
{
    KDSCateyeHelpVC * vc = [KDSCateyeHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
