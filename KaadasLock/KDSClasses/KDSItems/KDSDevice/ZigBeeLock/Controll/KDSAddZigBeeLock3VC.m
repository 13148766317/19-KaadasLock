
//
//  KDSAddZigBeeLock3VC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/8.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSAddZigBeeLock3VC.h"
#import "KDSAddZigBeeLock5VC.h"
#import "KDSBLEBindHelpVC.h"

@interface KDSAddZigBeeLock3VC ()

@end

@implementation KDSAddZigBeeLock3VC

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
    KDSAddZigBeeLock5VC * add5VC = [KDSAddZigBeeLock5VC new];
    add5VC.gw = self.gw;
    [self.navigationController pushViewController:add5VC animated:YES];
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
    ///添加门锁的logo
    UIImageView * addZigBeeLocklogoImg = [UIImageView new];
    addZigBeeLocklogoImg.image = [UIImage imageNamed:@"添加网关智能锁2"];
    [self.view addSubview:addZigBeeLocklogoImg];
    [addZigBeeLocklogoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(addZigBeeLocklogoImg.image.size);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.centerY.mas_equalTo(self.view.mas_centerY).offset(0);
    }];
    
    UILabel * tipMsgLabe3 = [UILabel new];
    tipMsgLabe3.text = @"第三步";
    tipMsgLabe3.font = [UIFont systemFontOfSize:18];
    tipMsgLabe3.textColor = UIColor.blackColor;
    tipMsgLabe3.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe3];
    [tipMsgLabe3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(45);
        make.height.mas_equalTo(18);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    
   ///提示语：
    UILabel * tipMsgLabe = [UILabel new];
    tipMsgLabe.text = @"根据语音提示，按键 【4】进入拓展功能";
    tipMsgLabe.font = [UIFont systemFontOfSize:13];
    tipMsgLabe.textColor = KDSRGBColor(102, 102, 102);
    tipMsgLabe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe];
    [tipMsgLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe3.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
}

@end
