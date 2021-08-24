//
//  KDSBleAndWiFiChangeAdminiPwdVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/4/11.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSBleAndWiFiChangeAdminiPwdVC.h"
#import "KDSWifiLockHelpVC.h"
#import "KDSAddBleAndWiFiLockStep4.h"


@interface KDSBleAndWiFiChangeAdminiPwdVC ()

@property (nonatomic,strong) UIImageView * addZigBeeLocklogoImg;

@end

@implementation KDSBleAndWiFiChangeAdminiPwdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"addDoorLock");
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [self setUI];
    [self startAnimation4Connection];
}

-(void)setUI
{
    UIView * supView = [UIView new];
    supView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:supView];
    [supView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).offset(3);
    }];
    
    ///第一步
    UILabel * tipMsgLabe1 = [UILabel new];
    tipMsgLabe1.text = @"第三步：修改初始管理密码";
    tipMsgLabe1.font = [UIFont systemFontOfSize:18];
    tipMsgLabe1.textColor = UIColor.blackColor;
    tipMsgLabe1.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe1];
    [tipMsgLabe1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(35);
        make.height.mas_equalTo(20);
        make.left.mas_equalTo(self.view.mas_left).offset(KDSScreenHeight < 667 ? 30 : 50);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
                                
    UILabel * tipMsgLabe = [UILabel new];
    tipMsgLabe.text = @"① 按键区输入“*”两次";
    tipMsgLabe.font = [UIFont systemFontOfSize:14];
    tipMsgLabe.textColor = KDSRGBColor(102, 102, 102);
    tipMsgLabe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe];
    [tipMsgLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe1.mas_bottom).offset(KDSScreenHeight < 667 ? 20 : 35);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.view.mas_left).offset(KDSScreenHeight < 667 ? 30 : 50);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
    UILabel * tipMsg1Labe = [UILabel new];
    tipMsg1Labe.text = @"② 输入管理密码：“12345678”";
    tipMsg1Labe.font = [UIFont systemFontOfSize:14];
    tipMsg1Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg1Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg1Labe];
    [tipMsg1Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.view.mas_left).offset(KDSScreenHeight < 667 ? 30 : 50);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
    UILabel * tipMsg2Labe = [UILabel new];
    tipMsg2Labe.text = @"③ 按“#”确认，“已进入管理模式”";
    tipMsg2Labe.font = [UIFont systemFontOfSize:14];
    tipMsg2Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg2Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg2Labe];
    [tipMsg2Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsg1Labe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.view.mas_left).offset(KDSScreenHeight < 667 ? 30 : 50);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
    UILabel * tipMsg22Labe = [UILabel new];
    tipMsg22Labe.text = @"④ 语音播报：“请修改管理密码”";
    tipMsg22Labe.font = [UIFont systemFontOfSize:14];
    tipMsg22Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg22Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg22Labe];
    [tipMsg22Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsg2Labe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.view.mas_left).offset(KDSScreenHeight < 667 ? 30 : 50);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
    UILabel * tipMsg3Labe = [UILabel new];
    tipMsg3Labe.text = @"⑤输入新设定的管理密码，按“＃”确认";
    tipMsg3Labe.font = [UIFont systemFontOfSize:14];
    tipMsg3Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg3Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg3Labe];
    [tipMsg3Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsg22Labe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.view.mas_left).offset(KDSScreenHeight < 667 ? 30 : 50);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
    UILabel * tipMsg4Labe = [UILabel new];
    tipMsg4Labe.text = @"⑥再输入新设定的管理密码，按“＃”完成修改";
    tipMsg4Labe.font = [UIFont systemFontOfSize:14];
    tipMsg4Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg4Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg4Labe];
    [tipMsg4Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsg3Labe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.view.mas_left).offset(KDSScreenHeight < 667 ? 30 : 50);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
    
    ///添加门锁的logo
    self.addZigBeeLocklogoImg = [UIImageView new];
    self.addZigBeeLocklogoImg.image = [UIImage imageNamed:@"changeAdminiPwdImg"];
    [self.view addSubview:self.addZigBeeLocklogoImg];
    self.addZigBeeLocklogoImg.backgroundColor = UIColor.yellowColor;
    [self.addZigBeeLocklogoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsg4Labe.mas_bottom).offset(KDSScreenHeight < 667 ? 15 : 38);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.width.equalTo(@99.5);
        make.height.equalTo(@201.5);
    }];
    
    UIButton * connectBtn = [UIButton new];
    [connectBtn setTitle:@"已修改管理密码" forState:UIControlStateNormal];
    [connectBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [connectBtn addTarget:self action:@selector(changgeAdminPwdBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    connectBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    connectBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    connectBtn.layer.masksToBounds = YES;
    connectBtn.layer.cornerRadius = 20;
    [self.view addSubview:connectBtn];
    [connectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(KDSScreenHeight < 667 ? -42 : -62);
    }];
}


//NSArray *_arrayImages4Connecting; 几张图片按顺序切换
- (void)startAnimation4Connection {
    NSArray * _arrayImages4Connecting = [NSArray arrayWithObjects:
                                        [UIImage imageNamed:@"changeAdminiPwdImg1.jpg"],
                                        [UIImage imageNamed:@"changeAdminiPwdImg2.jpg"],
                                        [UIImage imageNamed:@"changeAdminiPwdImg3.jpg"],
                                        [UIImage imageNamed:@"changeAdminiPwdImg4.jpg"],
                                        [UIImage imageNamed:@"changeAdminiPwdImg5.jpg"],
                                        [UIImage imageNamed:@"changeAdminiPwdImg6.jpg"],
                                        [UIImage imageNamed:@"changeAdminiPwdImg7.jpg"],
                                        [UIImage imageNamed:@"changeAdminiPwdImg8.jpg"],
                                        [UIImage imageNamed:@"changeAdminiPwdImg9.jpg"],
                                        [UIImage imageNamed:@"changeAdminiPwdImg10.jpg"],
                                        [UIImage imageNamed:@"changeAdminiPwdImg11.jpg"],
                                        [UIImage imageNamed:@"changeAdminiPwdImg12.jpg"],
                                        [UIImage imageNamed:@"changeAdminiPwdImg13.jpg"],
                                        [UIImage imageNamed:@"changeAdminiPwdImg14.jpg"],
                                        [UIImage imageNamed:@"changeAdminiPwdImg15.jpg"],
                                        [UIImage imageNamed:@"changeAdminiPwdImg16.jpg"],
                                        nil];
    [self.addZigBeeLocklogoImg setAnimationImages:_arrayImages4Connecting];
    [self.addZigBeeLocklogoImg setAnimationRepeatCount:0];
    [self.addZigBeeLocklogoImg setAnimationDuration:16.0f];
    [self.addZigBeeLocklogoImg startAnimating];

}

//停止删除
-(void)imgAnimationStop{
    [self.addZigBeeLocklogoImg.layer removeAllAnimations];
}

-(void)dealloc
{
    [self imgAnimationStop];
}

#pragma mark 点击事件

-(void)navRightClick
{
    KDSWifiLockHelpVC * vc = [KDSWifiLockHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)changgeAdminPwdBtnClick:(UIButton * )sender
{
    KDSAddBleAndWiFiLockStep4 * vc = [KDSAddBleAndWiFiLockStep4 new];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
