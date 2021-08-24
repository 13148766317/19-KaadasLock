//
//  KDSAddZeroFireSingleStep1VC.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/17.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAddZeroFireSingleStep1VC.h"
#import "KDSAddZeroFireSingleStep2VC.h"

@interface KDSAddZeroFireSingleStep1VC ()

@end

@implementation KDSAddZeroFireSingleStep1VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"addDevice");
    [self setUI];
}

-(void)setUI{
    
    UILabel * tipsLb1 = [UILabel new];
    tipsLb1.text = @"1. 开关接线";
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
    tipsLb2.text = @"切断总闸，按照要求进行接线，接线图如下所示；（L孔接火线、L1/L2孔接电灯导线）";
    tipsLb2.textColor = KDSRGBColor(102, 102, 102);
    tipsLb2.textAlignment = NSTextAlignmentLeft;
    tipsLb2.font = [UIFont systemFontOfSize:16];
    tipsLb2.numberOfLines = 0;
    [self.view addSubview:tipsLb2];
    [tipsLb2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipsLb1.mas_bottom).offset(15);
        make.left.mas_equalTo(self.view.mas_left).offset(30);
        make.height.equalTo(@60);
        make.right.mas_equalTo(self.view.mas_right).offset(-30);
    }];
    
    UIImageView * tipsImg = [UIImageView new];
    tipsImg.image = [UIImage imageNamed:@"AddZeroFireSingleStep1Icon"];
    [self.view addSubview:tipsImg];
    [tipsImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipsLb2.mas_bottom).offset(KDSScreenHeight < 667 ? 40 : 70);
        make.width.equalTo(@198.5);
        make.height.equalTo(@248);
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
        make.top.mas_equalTo(tipsImg.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@200);
        make.height.equalTo(@44);
    }];
}


#pragma mark 点击事件

-(void)nextBtnClick:(UIButton *)sender
{
    KDSAddZeroFireSingleStep2VC * vc = [KDSAddZeroFireSingleStep2VC new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
