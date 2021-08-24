//
//  KDSAddZeroFireSingleStep2VC.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/17.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAddZeroFireSingleStep2VC.h"
#import "KDSAddZeroFireSingleStep3VC.h"

@interface KDSAddZeroFireSingleStep2VC ()

@end

@implementation KDSAddZeroFireSingleStep2VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"addDevice");
    [self setUI];
    
}

-(void)setUI{
    
    UILabel * tipsLb1 = [UILabel new];
    tipsLb1.text = @"2. 开关安装 ";
    tipsLb1.textColor = KDSRGBColor(51, 51, 51);
    tipsLb1.textAlignment = NSTextAlignmentLeft;
    tipsLb1.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:tipsLb1];
    [tipsLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(47);
        make.left.mas_equalTo(self.view.mas_left).offset(30);
        make.height.equalTo(@20);
        make.right.mas_equalTo(self.view.mas_right).offset(-30);
    }];
    UILabel * tipsLb2 = [UILabel new];
    tipsLb2.text = @"① 用一字螺丝刀掀起开关面壳 ";
    tipsLb2.textColor = KDSRGBColor(102, 102, 102);
    tipsLb2.textAlignment = NSTextAlignmentLeft;
    tipsLb2.font = [UIFont systemFontOfSize:15];
    tipsLb2.numberOfLines = 0;
    [self.view addSubview:tipsLb2];
    [tipsLb2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipsLb1.mas_bottom).offset(15);
        make.left.mas_equalTo(self.view.mas_left).offset(30);
        make.height.equalTo(@20);
        make.right.mas_equalTo(self.view.mas_right).offset(-30);
    }];
    
    UIImageView * tipsImg1 = [UIImageView new];
    tipsImg1.image = [UIImage imageNamed:@"AddZeroFireSingleStep2Icon1"];
    [self.view addSubview:tipsImg1];
    [tipsImg1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@234.5);
        make.height.equalTo(@135);
        make.top.mas_equalTo(tipsLb2.mas_bottom).offset(18);
        make.centerX.equalTo(self.view);
    }];
    UILabel * tipsLb3 = [UILabel new];
    tipsLb3.text = @"② 用螺丝钉将开关固定到墙壁接线盒里， 再扣上面壳 ";
    tipsLb3.textColor = KDSRGBColor(102, 102, 102);
    tipsLb3.textAlignment = NSTextAlignmentLeft;
    tipsLb3.font = [UIFont systemFontOfSize:15];
    tipsLb3.numberOfLines = 0;
    [self.view addSubview:tipsLb3];
    [tipsLb3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipsImg1.mas_bottom).offset(15);
        make.left.mas_equalTo(self.view.mas_left).offset(30);
        make.height.equalTo(@40);
        make.right.mas_equalTo(self.view.mas_right).offset(-30);
    }];
    
    UIImageView * tipsImg2 = [UIImageView new];
    tipsImg2.image = [UIImage imageNamed:@"AddZeroFireSingleStep2Icon2"];
    [self.view addSubview:tipsImg2];
    [tipsImg2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@234.5);
        make.height.equalTo(@135);
        make.top.mas_equalTo(tipsLb3.mas_bottom).offset(10);
        make.centerX.equalTo(self.view);
    }];
    
    UIButton * nextBtn = [UIButton new];
    [nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [nextBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    nextBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    [nextBtn addTarget:self action:@selector(nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.layer.cornerRadius = 22;
    nextBtn.layer.masksToBounds = YES;
    [self.view addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipsImg2.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@200);
        make.height.equalTo(@44);
    }];
    
}

#pragma mark 点击事件

-(void)nextBtnClick:(UIButton *)sender
{
    KDSAddZeroFireSingleStep3VC * vc = [KDSAddZeroFireSingleStep3VC new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
