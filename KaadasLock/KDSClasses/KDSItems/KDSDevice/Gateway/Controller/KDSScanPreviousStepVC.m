//
//  KDSScanPreviousStepVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/11.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSScanPreviousStepVC.h"
#import <AVFoundation/AVFoundation.h>
#import "RHScanViewController.h"

@interface KDSScanPreviousStepVC ()

@end

@implementation KDSScanPreviousStepVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"addWg");
    [self setUI];
}

-(void)setUI
{
    ///下一步
    UIView * nextStepView = [UIView new];
    nextStepView.backgroundColor = KDSRGBColor(31, 150, 247);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecoginzer:)];
    [nextStepView addGestureRecognizer:tap];
    nextStepView.layer.cornerRadius = KDSSSALE_HEIGHT(22);
    [self.view addSubview:nextStepView];
    [nextStepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(KDSSSALE_HEIGHT(44));
        make.width.mas_equalTo(200);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-KDSSSALE_HEIGHT(50));
    }];
    ///扫描图标
    UIImageView * scanningIcon = [UIImageView new];
    scanningIcon .image = [UIImage imageNamed:@"scanning_icon"];
    [nextStepView addSubview:scanningIcon];
    [scanningIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(18);
        make.left.mas_equalTo(nextStepView.mas_left).offset(27);
        make.centerY.mas_equalTo(nextStepView.mas_centerY).offset(0);
    }];
    ///去扫描设备二维码
    UILabel * scanningLb = [UILabel new];
    scanningLb.text = Localized(@"codeforScanner");
    scanningLb.font = [UIFont systemFontOfSize:15];
    scanningLb.textColor = UIColor.whiteColor;
    scanningLb.backgroundColor = UIColor.clearColor;
    [nextStepView addSubview:scanningLb];
    [scanningLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(15);
        make.left.mas_equalTo(scanningIcon.mas_right).offset(10);
        make.centerY.mas_equalTo(nextStepView.mas_centerY).offset(0);
    }];
    
    ///提示语：扫描网关后面二维码
    UILabel * tipMsgLabe = [UILabel new];
    tipMsgLabe.text = Localized(@"OpenBoxtwoGWCode");
    tipMsgLabe.font = [UIFont systemFontOfSize:17];
    tipMsgLabe.textColor = UIColor.blackColor;
    tipMsgLabe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe];
    [tipMsgLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.top.mas_equalTo(self.view.mas_top).offset(65);
    }];
    
    ///添加门锁的logo
    UIImageView * addZigBeeLocklogoImg = [UIImageView new];
    addZigBeeLocklogoImg.image = [UIImage imageNamed:@"Add gateway_pic"];
    [self.view addSubview:addZigBeeLocklogoImg];
    [addZigBeeLocklogoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(KDSSSALE_HEIGHT(89));
        make.width.mas_equalTo(KDSSSALE_WIDTH(186));
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.centerY.mas_equalTo(self.view.mas_centerY).offset(0);
    }];
    
}

#pragma mark 控件点击事件

-(void)gestureRecoginzer:(UITapGestureRecognizer *)tap
{
    ///鉴权相机权限
    RHScanViewController *vc = [RHScanViewController new];
    vc.isOpenInterestRect = YES;
    vc.isVideoZoom = YES;
    vc.fromWhereVC = @"GatewayVC";//添加网关
    [self.navigationController pushViewController:vc animated:YES];
}

@end
