//
//  KDSBindingRYGWSuccessVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/12.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSBindingRYGWSuccessVC.h"

@interface KDSBindingRYGWSuccessVC ()

@end

@implementation KDSBindingRYGWSuccessVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"addWg");
    [self setUI];
}

-(void)setUI
{
    UIImageView * tipsImg = [UIImageView new];
    tipsImg.image = [UIImage imageNamed:@"addRYGWSuccessImg"];
    tipsImg.backgroundColor = UIColor.clearColor;
    [self.view addSubview:tipsImg];
    [tipsImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@207);
        make.height.equalTo(@156);
        make.centerX.equalTo(self.view);
        make.top.mas_equalTo(KDSSSALE_HEIGHT(56));
    }];
    UILabel * tipsLb = [UILabel new];
    tipsLb.text = @"网关绑定成功！";
    tipsLb.font = [UIFont systemFontOfSize:15];
    tipsLb.textColor = KDSRGBColor(51, 51, 51);
    tipsLb.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipsLb];
    [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipsImg.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.height.equalTo(@20);
    }];
    UILabel * tipsLb1 = [UILabel new];
    tipsLb1.text = @"请确认设备成功开启并处于发现状态";
    tipsLb1.font = [UIFont systemFontOfSize:13];
    tipsLb1.textColor = KDSRGBColor(51, 51, 51);
    tipsLb1.textAlignment = NSTextAlignmentCenter;
    tipsLb1.hidden = YES;
    [self.view addSubview:tipsLb1];
    [tipsLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipsLb.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.height.equalTo(@20);
    }];
    UIButton * rematchBtn = [UIButton new];
    [rematchBtn setTitle:@"进入设备详情" forState:UIControlStateNormal];
    [rematchBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    rematchBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    rematchBtn.layer.cornerRadius = 22;
    [self.view addSubview:rematchBtn];
    [rematchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@44);
        make.width.equalTo(@200);
        make.centerX.equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(KDSScreenHeight < 667 ? -40 : -80);
    }];
}


@end
