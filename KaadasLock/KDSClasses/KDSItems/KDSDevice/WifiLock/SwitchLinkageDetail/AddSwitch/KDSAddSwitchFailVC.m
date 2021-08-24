//
//  KDSAddSwitchFailVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/4/20.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAddSwitchFailVC.h"
#import "KDSAddSwitchVC.h"
#import "KDSSwitchLinkageDetailVC.h"

@interface KDSAddSwitchFailVC ()

@end

@implementation KDSAddSwitchFailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"addFail");
    
    [self setUI];
}

-(void)setUI{
    
    UIImageView * tipsIconImg = [UIImageView new];
    tipsIconImg.image = [UIImage imageNamed:@"addSwithFailImg"];
    [self.view addSubview:tipsIconImg];
    [tipsIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@65);
        make.height.equalTo(@45);
        make.top.equalTo(self.view.mas_top).offset(KDSScreenWidth <= 375 ? 30 : 50);
        make.centerX.equalTo(self.view);
    }];
    UILabel * tipsLb = [UILabel new];
    tipsLb.text = @"配置失败";
    tipsLb.textColor = KDSRGBColor(153, 153, 153);
    tipsLb.font = [UIFont systemFontOfSize:15];
    tipsLb.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipsLb];
    [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@20);
        make.top.equalTo(tipsIconImg.mas_bottom).offset(30);
        make.centerX.equalTo(self.view);
        
    }];
    
    UIView * supView = [UIView new];
    supView.backgroundColor = UIColor.whiteColor;
    supView.layer.masksToBounds = YES;
    supView.layer.cornerRadius = 4;
    [self.view addSubview:supView];
    [supView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsLb.mas_bottom).offset(KDSScreenWidth <= 375 ? 40 : 55);
        make.left.equalTo(self.view.mas_left).offset(15);
        make.right.equalTo(self.view.mas_right).offset(-15);
        make.height.equalTo(@(KDSScreenWidth <= 375 ? 150 : 225));
    }];
    
    UIView * line1 = [UIView new];
    line1.backgroundColor = KDSRGBColor(234, 233, 233);
    [supView addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(supView.mas_left).offset(57);
        make.top.equalTo(supView.mas_top).offset(KDSScreenWidth <= 375 ? 50 : 75);
        make.height.equalTo(@1);
        make.right.equalTo(supView);
    }];
    
    UIView * line2 = [UIView new];
    line2.backgroundColor = KDSRGBColor(234, 233, 233);
    [supView addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(supView.mas_left).offset(57);
        make.bottom.equalTo(supView.mas_bottom).offset(KDSScreenWidth <= 375 ? -50 : -75);
        make.height.equalTo(@1);
        make.right.equalTo(supView);
    }];
    
    
    UILabel * tipsLb1 = [UILabel new];
    tipsLb1.text = @"1";
    tipsLb1.textColor = UIColor.whiteColor;
    tipsLb1.textAlignment = NSTextAlignmentCenter;
    tipsLb1.font = [UIFont systemFontOfSize:12];
    tipsLb1.backgroundColor = KDSRGBColor(31, 150, 247);
    tipsLb1.layer.cornerRadius = 17/2;
    tipsLb1.layer.masksToBounds = YES;
    [supView addSubview:tipsLb1];
    [tipsLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@17);
        make.top.equalTo(supView).offset(KDSScreenWidth <= 375 ? (50-17)/2 :(75 -17)/2);
        make.left.equalTo(supView.mas_left).offset(22);
    }];
    
    UILabel * tipsLb1Content = [UILabel new];
    tipsLb1Content.text = @"确保您的门锁已唤醒";
    tipsLb1Content.font = [UIFont systemFontOfSize:13];
    tipsLb1Content.textAlignment = NSTextAlignmentLeft;
    tipsLb1Content.textColor = UIColor.blackColor;
    [supView addSubview:tipsLb1Content];
    [tipsLb1Content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tipsLb1.mas_right).offset(15);
        make.right.equalTo(supView.mas_right).offset(0);
        make.top.equalTo(supView.mas_top).offset(0);
        make.bottom.equalTo(line1);
    }];
    
    UILabel * tipsLb2 = [UILabel new];
    tipsLb2.text = @"2";
    tipsLb2.textColor = UIColor.whiteColor;
    tipsLb2.textAlignment = NSTextAlignmentCenter;
    tipsLb2.font = [UIFont systemFontOfSize:12];
    tipsLb2.backgroundColor = KDSRGBColor(31, 150, 247);
    tipsLb2.layer.cornerRadius = 17/2;
    tipsLb2.layer.masksToBounds = YES;
    [supView addSubview:tipsLb2];
    [tipsLb2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@17);
        make.top.equalTo(line1).offset(KDSScreenWidth <= 375 ? (50-17)/2 :(75 -17)/2);
        make.left.equalTo(supView.mas_left).offset(22);
    }];
    
    UILabel * tipsLb2Content = [UILabel new];
    tipsLb2Content.text = @"查看开关面板按键是否能正常控制灯光";
    tipsLb2Content.font = [UIFont systemFontOfSize:13];
    tipsLb2Content.textAlignment = NSTextAlignmentLeft;
    tipsLb2Content.textColor = UIColor.blackColor;
    [supView addSubview:tipsLb2Content];
    [tipsLb2Content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tipsLb2.mas_right).offset(15);
        make.right.equalTo(supView.mas_right).offset(0);
        make.top.equalTo(line1.mas_bottom).offset(0);
        make.bottom.equalTo(line2.mas_top).offset(0);
    }];
    
    UILabel * tipsLb3 = [UILabel new];
    tipsLb3.text = @"3";
    tipsLb3.textColor = UIColor.whiteColor;
    tipsLb3.textAlignment = NSTextAlignmentCenter;
    tipsLb3.font = [UIFont systemFontOfSize:12];
    tipsLb3.backgroundColor = KDSRGBColor(31, 150, 247);
    tipsLb3.layer.cornerRadius = 17/2;
    tipsLb3.layer.masksToBounds = YES;
    [supView addSubview:tipsLb3];
    [tipsLb3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@17);
        make.top.equalTo(line2).offset(KDSScreenWidth <= 375 ? (50-17)/2 :(75 -17)/2);
        make.left.equalTo(supView.mas_left).offset(22);
    }];
    
    UILabel * tipsLb3Content = [UILabel new];
    tipsLb3Content.text = @"长按开关任意键5秒  ， 红色LED灯是否快闪";
    tipsLb3Content.font = [UIFont systemFontOfSize:13];
    tipsLb3Content.textAlignment = NSTextAlignmentLeft;
    tipsLb3Content.textColor = UIColor.blackColor;
    [supView addSubview:tipsLb3Content];
    [tipsLb3Content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tipsLb3.mas_right).offset(15);
        make.right.equalTo(supView.mas_right).offset(0);
        make.top.equalTo(line2.mas_bottom).offset(0);
        make.bottom.equalTo(supView.mas_bottom).offset(0);
    }];
    
    UIButton * cancelBtn = [UIButton new];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [cancelBtn setTitleColor:KDSRGBColor(112, 112, 112)/*KDSRGBColor(31, 150, 247) */forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    NSRange otherConFigstrRange = {0,[cancelBtn.titleLabel.text length]};
    NSMutableAttributedString * otherConFigstr = [[NSMutableAttributedString alloc] initWithString:cancelBtn.titleLabel.text];
    [otherConFigstr addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:otherConFigstrRange];
    [cancelBtn setAttributedTitle:otherConFigstr forState:UIControlStateNormal];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(44));
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(KDSScreenHeight <= 667 ? -40 : -60);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    
    UIButton * rematchBtn = [UIButton new];
    [rematchBtn setTitle:@"重新配置" forState:UIControlStateNormal];
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
        make.bottom.mas_equalTo(cancelBtn.mas_top).offset(-KDSSSALE_HEIGHT(23));
    }];
}


#pragma mark 点击事件
//重新配置
-(void)rematchBtnClick:(UIButton *)btn
{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[KDSAddSwitchVC class]]) {
            KDSAddSwitchVC *A =(KDSAddSwitchVC *)controller;
            [self.navigationController popToViewController:A animated:YES];
        }
    }
}
//取消
-(void)cancelClick:(UIButton *)sender
{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[KDSSwitchLinkageDetailVC class]]) {
            KDSSwitchLinkageDetailVC *A =(KDSSwitchLinkageDetailVC *)controller;
            [self.navigationController popToViewController:A animated:YES];
        }
    }
}

@end
