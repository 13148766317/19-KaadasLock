//
//  KDSAddSmartHangerFailVC.m
//  KaadasLock
//
//  Created by Frank Hu on 2021/1/11.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSAddSmartHangerFailVC.h"

@interface KDSAddSmartHangerFailVC ()

@end

@implementation KDSAddSmartHangerFailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"Pairing network failure");
    [self setUI];
}

- (void)navBackClick
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)setUI{
    
    UIImageView * failImg = [UIImageView new];
    failImg.image = [UIImage imageNamed:@"add_smart_hanger_fail"];
    [self.view addSubview:failImg];
    [failImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(KDSScreenHeight < 667 ? 20 : KDSSSALE_HEIGHT(72));
        make.width.equalTo(@188);
        make.height.equalTo(@54);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        
    }];
    
    UILabel * failTipsLb = [UILabel new];
    failTipsLb.text = Localized(@"Pairing failure");
    failTipsLb.font = [UIFont systemFontOfSize:15];
    failTipsLb.textColor = KDSRGBColor(86, 86, 86);
    failTipsLb.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:failTipsLb];
    [failTipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(failImg.mas_bottom).offset(42);
        make.height.equalTo(@20);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    
    UIView * tipsView = [UIView new];
    tipsView.backgroundColor = UIColor.whiteColor;
    tipsView.layer.masksToBounds = YES;
    tipsView.layer.cornerRadius = 10;
    [self.view addSubview:tipsView];
    [tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(failTipsLb.mas_bottom).offset(KDSSSALE_HEIGHT(32));
        make.left.mas_equalTo(self.view.mas_left).offset(10);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
        make.height.equalTo(@100);
        
    }];
    UIView * dotView1 = [UIView new];
    dotView1.backgroundColor = KDSRGBColor(181, 181, 181);
    dotView1.layer.masksToBounds = YES;
    dotView1.layer.cornerRadius = 3.5;
    [tipsView addSubview:dotView1];
    [dotView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipsView.mas_top).offset(25);
        make.left.mas_equalTo(tipsView.mas_left).offset(11);
        make.width.height.equalTo(@7);
    }];
    UILabel * dotLb1 = [UILabel new];
    dotLb1.text = @"请重新按照说明，启动设备配网";
    dotLb1.font= [UIFont systemFontOfSize:13];
    dotLb1.textColor = KDSRGBColor(149, 149, 149);
    dotLb1.textAlignment = NSTextAlignmentLeft;
    [tipsView addSubview:dotLb1];
    [dotLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tipsView.mas_left).offset(26);
        make.top.mas_equalTo(tipsView.mas_top).offset(19);
        make.right.mas_equalTo(tipsView.mas_right).offset(-26);
        make.height.equalTo(@15);
        
    }];
    
    UIView * dotView2 = [UIView new];
    dotView2.backgroundColor = KDSRGBColor(181, 181, 181);
    dotView2.layer.masksToBounds = YES;
    dotView2.layer.cornerRadius = 3.5;
    [tipsView addSubview:dotView2];
    [dotView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(dotView1.mas_bottom).offset(25);
        make.left.mas_equalTo(tipsView.mas_left).offset(11);
        make.width.height.equalTo(@7);
    }];
    UILabel * dotLb2 = [UILabel new];
    dotLb2.text = @"请保持手机靠近晾衣机";
    dotLb2.font= [UIFont systemFontOfSize:13];
    dotLb2.textColor = KDSRGBColor(149, 149, 149);
    dotLb2.textAlignment = NSTextAlignmentLeft;
    [tipsView addSubview:dotLb2];
    [dotLb2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tipsView.mas_left).offset(26);
        make.top.mas_equalTo(dotLb1.mas_bottom).offset(15);
        make.right.mas_equalTo(tipsView.mas_right).offset(-26);
        make.height.equalTo(@15);
        
    }];
    
    UIButton * rematchBtn = [UIButton new];
    [rematchBtn setTitle:@"重新连接" forState:UIControlStateNormal];
    rematchBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [rematchBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    rematchBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    rematchBtn.layer.masksToBounds = YES;
    rematchBtn.layer.cornerRadius = 22;
    [rematchBtn addTarget:self action:@selector(rematchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rematchBtn];
    [rematchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@(44));
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(KDSScreenHeight <= 667 ? -40 : -KDSSSALE_HEIGHT(60));
    }];

    
}

#pragma 点击事件
///wifi路由器支持品牌解说
-(void)supportedHomeRoutersClickTap:(UITapGestureRecognizer *)btn{
    
    KDSHomeRoutersVC * VC = [KDSHomeRoutersVC new];
    [self.navigationController pushViewController:VC animated:YES];
}
///取消--回到设备首页
-(void)otherConFigBtnClick:(UIButton *)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

-(void)rematchBtnClick:(UIButton *)sender
{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[KDSAddSmartHangerStep1VC class]]) {
            KDSAddSmartHangerStep1VC *A =(KDSAddSmartHangerStep1VC *)controller;
            [self.navigationController popToViewController:A animated:YES];
        }
    }
}



@end
