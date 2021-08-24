//
//  KDSWFAMModeSpecificationVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/25.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSWFAMModeSpecificationVC.h"

@interface KDSWFAMModeSpecificationVC ()

@end

@implementation KDSWFAMModeSpecificationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = @"A-M自动/手动模式";
    [self setUI];
}

-(void)setUI{
    UILabel * tipsLb = [UILabel new];
    tipsLb.text = [NSString stringWithFormat:@"门锁%@模式状态",self.lock.wifiDevice.amMode.intValue == 0 ? @"自动" : @"手动"];
    tipsLb.textColor = KDSRGBColor(51, 51, 51);
    tipsLb.font = [UIFont systemFontOfSize:15];
    tipsLb.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipsLb];
    [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(55);
        make.centerX.equalTo(self.view);
        make.height.equalTo(@18);
    }];
    
    UIImageView * tipsImg = [UIImageView new];
    tipsImg.image = [UIImage imageNamed:@"wifi-AMModeSpecificationImg"];
    [self.view addSubview:tipsImg];
    [tipsImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(KDSScreenHeight < 667 ? 60 : 108);
        make.width.equalTo(@101);
        make.height.equalTo(@153);
        make.centerX.equalTo(self.view);
    }];
    
    UIView * supView = [UIView new];
    supView.backgroundColor = UIColor.whiteColor;
    supView.layer.masksToBounds = YES;
    supView.layer.cornerRadius = 4;
    [self.view addSubview:supView];
    [supView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipsImg.mas_bottom).offset(KDSScreenHeight < 667 ? 40 : 65);
        make.left.mas_equalTo(self.view.mas_left).offset(13);
        make.right.mas_equalTo(self.view.mas_right).offset(-13);
        make.height.equalTo(@182);
        
    }];
    
    UILabel * tipsLb1 = [UILabel new];
    tipsLb1.text = @"打开后面板后盖，有个A-M的拨动开关";
    tipsLb1.textColor = KDSRGBColor(51, 51, 51);
    tipsLb1.textAlignment = NSTextAlignmentLeft;
    tipsLb1.font = [UIFont systemFontOfSize:17];
    [supView addSubview:tipsLb1];
    [tipsLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(supView.mas_left).offset(10);
        make.right.mas_equalTo(supView.mas_right).offset(-10);
        make.top.mas_equalTo(supView.mas_top).offset(20);
        make.height.equalTo(@20);
    }];
    UILabel * tipsLb2 = [UILabel new];
    tipsLb2.text = @"①“A”档表示自动模式：";
    tipsLb2.textColor = KDSRGBColor(102, 102, 102);
    tipsLb2.textAlignment = NSTextAlignmentLeft;
    tipsLb2.font = [UIFont systemFontOfSize:15];
    [supView addSubview:tipsLb2];
    [tipsLb2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(supView.mas_left).offset(10);
        make.right.mas_equalTo(supView.mas_right).offset(-10);
        make.top.mas_equalTo(tipsLb1.mas_bottom).offset(15);
        make.height.equalTo(@15);
    }];
    UILabel * tipsLb3 = [UILabel new];
    tipsLb3.text = @"当关门后，方舌自动打出锁门，门处于锁定状态";
    tipsLb3.textColor = KDSRGBColor(102, 102, 102);
    tipsLb3.textAlignment = NSTextAlignmentLeft;
    tipsLb3.font = [UIFont systemFontOfSize:15];
    [supView addSubview:tipsLb3];
    [tipsLb3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(supView.mas_left).offset(10);
        make.right.mas_equalTo(supView.mas_right).offset(-10);
        make.top.mas_equalTo(tipsLb2.mas_bottom).offset(15);
        make.height.equalTo(@15);
    }];
    UILabel * tipsLb4 = [UILabel new];
    tipsLb4.text = @"②“M”档表示常开模式：";
    tipsLb4.textColor = KDSRGBColor(102, 102, 102);
    tipsLb4.textAlignment = NSTextAlignmentLeft;
    tipsLb4.font = [UIFont systemFontOfSize:15];
    [supView addSubview:tipsLb4];
    [tipsLb4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(supView.mas_left).offset(10);
        make.right.mas_equalTo(supView.mas_right).offset(-10);
        make.top.mas_equalTo(tipsLb3.mas_bottom).offset(15);
        make.height.equalTo(@15);
    }];
    UILabel * tipsLb5 = [UILabel new];
    tipsLb5.text = @"当关门后，方舌不打出，门处于常开状态";
    tipsLb5.textColor = KDSRGBColor(102, 102, 102);
    tipsLb5.textAlignment = NSTextAlignmentLeft;
    tipsLb5.font = [UIFont systemFontOfSize:15];
    [supView addSubview:tipsLb5];
    [tipsLb5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(supView.mas_left).offset(10);
        make.right.mas_equalTo(supView.mas_right).offset(-10);
        make.top.mas_equalTo(tipsLb4.mas_bottom).offset(15);
        make.height.equalTo(@15);
    }];

    
}

@end
