//
//  KDSAddRYGWVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/11.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAddRYGWVC.h"
#import "KDSBLEBindHelpVC.h"
#import "KDSRYGWSearchTableVC.h"

@interface KDSAddRYGWVC ()

@end

@implementation KDSAddRYGWVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"addWg");
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [self setUI];
}

-(void)setUI
{
    UILabel * topTipsLb = [UILabel new];
    topTipsLb.text = @"按下按键保持3秒进行配网";
    topTipsLb.textColor = UIColor.blackColor;
    topTipsLb.font = [UIFont systemFontOfSize:17];
    topTipsLb.textAlignment = NSTextAlignmentCenter;
    topTipsLb.backgroundColor = UIColor.clearColor;
    [self.view addSubview:topTipsLb];
    [topTipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(KDSSSALE_HEIGHT(74));
        make.left.right.equalTo(self.view);
        make.height.equalTo(@20);
    }];
    
    UIButton * nextBtn = [UIButton new];
    [nextBtn setTitle:@"我确定，下一步" forState:UIControlStateNormal];
    [nextBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    nextBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    nextBtn.layer.cornerRadius = 22;
    [self.view addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.centerX.equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-KDSSSALE_HEIGHT(90));
    }];
    UILabel * tipsLb = [UILabel new];
    tipsLb.text = @"请确认设备进入配网状态";
    tipsLb.font = [UIFont systemFontOfSize:12];
    tipsLb.textAlignment = NSTextAlignmentCenter;
    tipsLb.backgroundColor = UIColor.clearColor;
    tipsLb.textColor = UIColor.blackColor;
    [self.view addSubview:tipsLb];
    [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.mas_equalTo(nextBtn.mas_top).offset(-20);
        make.height.equalTo(@15);
    }];
    
    UIImageView * tipsImg = [UIImageView new];
    tipsImg.image = [UIImage imageNamed:@"addRYGWStep1IocnImg"];
    [self.view addSubview:tipsImg];
    [tipsImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@160);
        make.height.equalTo(@171);
        make.centerX.equalTo(self.view);
        make.centerY.mas_equalTo(self.view.mas_centerY).offset(-20);
    }];
    
    
}

#pragma mark 点击事件

-(void)navRightClick
{
    KDSBLEBindHelpVC * vc = [KDSBLEBindHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)nextBtnClick:(UIButton *)sender
{
    KDSRYGWSearchTableVC * vc = [KDSRYGWSearchTableVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
