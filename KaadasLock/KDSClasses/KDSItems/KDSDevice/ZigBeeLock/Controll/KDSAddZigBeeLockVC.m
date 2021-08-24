//
//  KDSAddZigBeeLockVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/8.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSAddZigBeeLockVC.h"
#import "KDSAddZigBeeLock2VC.h"
#import "KDSBLEBindHelpVC.h"

@interface KDSAddZigBeeLockVC ()


@end

@implementation KDSAddZigBeeLockVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"addDoorLock");
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [self setUI];
}

#pragma mark 控件点击事件

-(void)navRightClick
{
    KDSBLEBindHelpVC *vc = [[KDSBLEBindHelpVC alloc] init];
    vc.helpFromStr = @"ZigeBeeLock";
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)nextStepBtnClick:(UIButton *)sender
{
    KDSAddZigBeeLock2VC * zb2VC = [KDSAddZigBeeLock2VC new];
    zb2VC.gw = self.gw;
    [self.navigationController pushViewController:zb2VC animated:YES];
}

-(void)setUI
{
    ///下一步
    UIButton * nextStepBtn = [UIButton new];
    nextStepBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    [nextStepBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [nextStepBtn setTitle:Localized(@"nextStep") forState:UIControlStateNormal];
    [nextStepBtn addTarget:self action:@selector(nextStepBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    nextStepBtn.layer.cornerRadius = 22;
    [self.view addSubview:nextStepBtn];
    [nextStepBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@44);
        make.width.mas_equalTo(@200);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-KDSSSALE_HEIGHT(50));
    }];
    
    ///第一步
    UILabel * tipMsgLabe1 = [UILabel new];
    tipMsgLabe1.text = @"第一步";
    tipMsgLabe1.font = [UIFont systemFontOfSize:18];
    tipMsgLabe1.textColor = UIColor.blackColor;
    tipMsgLabe1.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipMsgLabe1];
    [tipMsgLabe1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.top.mas_equalTo(self.view.mas_top).offset(51);
        make.height.mas_equalTo(20);
    }];
    
    ///提示语：确保门锁和猫眼安装好，并装上电池
    UILabel * tipMsgLabe = [UILabel new];
    tipMsgLabe.text = @"确保门锁安装好，并装上电池";
    tipMsgLabe.font = [UIFont systemFontOfSize:14];
    tipMsgLabe.textColor = KDSRGBColor(102, 102, 102);
    tipMsgLabe.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipMsgLabe];
    [tipMsgLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.top.mas_equalTo(tipMsgLabe1.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
    }];
    
    ///添加门锁的logo
    UIImageView * addZigBeeLocklogoImg = [UIImageView new];
    addZigBeeLocklogoImg.image = [UIImage imageNamed:@"添加网关智能锁1"];
    [self.view addSubview:addZigBeeLocklogoImg];
    [addZigBeeLocklogoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(KDSSSALE_HEIGHT(199));
        make.width.mas_equalTo(KDSSSALE_WIDTH(81));
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.centerY.mas_equalTo(self.view.mas_centerY).offset(0);
    }];
    
}

@end
