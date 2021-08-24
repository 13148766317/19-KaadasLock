//
//  KDSAddNewWiFiLockStep3VC.m
//  KaadasLock
//
//  Created by zhaona on 2020/3/10.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAddNewWiFiLockStep3VC.h"
#import "KDSWifiLockHelpVC.h"
#import "KDSChangeAdminiPwdVC.h"
#import "KDSAddNewWiFiLockStep4ToMasterVC.h"


@interface KDSAddNewWiFiLockStep3VC ()

@property (nonatomic,strong) UIImageView * addZigBeeLocklogoImg;

@end

@implementation KDSAddNewWiFiLockStep3VC

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
        make.top.mas_equalTo(self.view.mas_top).offset(KDSScreenHeight > 667 ? 51 : 20);
        make.height.mas_equalTo(20);
        make.left.mas_equalTo(self.view.mas_left).offset(30);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
    
    UILabel * tipMsgLabe = [UILabel new];
    tipMsgLabe.text = @"① 用手触碰按键区，唤醒门锁";
    tipMsgLabe.font = [UIFont systemFontOfSize:14];
    tipMsgLabe.textColor = KDSRGBColor(102, 102, 102);
    tipMsgLabe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe];
    [tipMsgLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe1.mas_bottom).offset(KDSScreenHeight < 667 ? 20 : 35);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.view.mas_left).offset(30);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
    UILabel * tipMsg1Labe = [UILabel new];
    tipMsg1Labe.text = @"语音是否播报:“密码过于简单，请及时修改管理密码”";
    tipMsg1Labe.numberOfLines = 0;
    tipMsg1Labe.font = [UIFont systemFontOfSize:14];
    tipMsg1Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg1Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg1Labe];
    [tipMsg1Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe.mas_bottom).offset(10);
        make.height.mas_equalTo(KDSScreenHeight <= 667 ? 32 : 16);
        make.left.mas_equalTo(self.view.mas_left).offset(30);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
    
    ///添加门锁的logo
    self.addZigBeeLocklogoImg = [UIImageView new];
    self.addZigBeeLocklogoImg.image = [UIImage imageNamed:@"addNewWiFiLockStep2Img1.jpg"];
    [self.view addSubview:self.addZigBeeLocklogoImg];
    [self.addZigBeeLocklogoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsg1Labe.mas_bottom).offset(KDSScreenHeight < 667 ? 30 : 65);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.height.equalTo(@235);
        make.width.equalTo(@163);
        
    }];
    
   UIButton * doorLockActiveBtn = [UIButton new];
   [doorLockActiveBtn setTitle:@"去修改管理密码" forState:UIControlStateNormal];
   [doorLockActiveBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
   [doorLockActiveBtn addTarget:self action:@selector(goChangeAdminiPwdClick:) forControlEvents:UIControlEventTouchUpInside];
   doorLockActiveBtn.titleLabel.font = [UIFont systemFontOfSize:15];
   doorLockActiveBtn.backgroundColor = UIColor.whiteColor;
   doorLockActiveBtn.layer.borderWidth = 1;
   doorLockActiveBtn.layer.borderColor = KDSRGBColor(31, 150, 247).CGColor;
   doorLockActiveBtn.layer.masksToBounds = YES;
   doorLockActiveBtn.layer.cornerRadius = 20;
   [self.view addSubview:doorLockActiveBtn];
   [doorLockActiveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       make.width.equalTo(@200);
       make.height.equalTo(@44);
       make.centerX.equalTo(self.view);
       make.bottom.equalTo(self.view.mas_bottom).offset(KDSScreenHeight <= 667 ? -45 : -65);
   }];
    
    UIButton * connectBtn = [UIButton new];
    [connectBtn setTitle:@"已修改管理密码" forState:UIControlStateNormal];
    [connectBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [connectBtn addTarget:self action:@selector(havedChangeAdminiPwdClick:) forControlEvents:UIControlEventTouchUpInside];
    connectBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    connectBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    connectBtn.layer.masksToBounds = YES;
    connectBtn.layer.cornerRadius = 20;
    [self.view addSubview:connectBtn];
    [connectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(doorLockActiveBtn.mas_top).offset(KDSScreenHeight > 667 ? -30 : -16);
    }];
    
    
}

//NSArray *_arrayImages4Connecting; 几张图片按顺序切换
- (void)startAnimation4Connection {
    NSArray * _arrayImages4Connecting = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"addNewWiFiLockStep2Img1.jpg"],
                                         [UIImage imageNamed:@"addNewWiFiLockStep2Img2.jpg"],
                                         nil];
    [self.addZigBeeLocklogoImg setAnimationImages:_arrayImages4Connecting];
    [self.addZigBeeLocklogoImg setAnimationRepeatCount:0];
    [self.addZigBeeLocklogoImg setAnimationDuration:2.0f];
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

#pragma mark 控件点击事件
//帮助
-(void)navRightClick
{
    KDSWifiLockHelpVC * vc = [KDSWifiLockHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}
//去修改管理员密码
-(void)goChangeAdminiPwdClick:(UIButton *)sender
{
    KDSChangeAdminiPwdVC * vc = [KDSChangeAdminiPwdVC new];
    [self.navigationController pushViewController:vc animated:YES];
}
//已修改管理员密码
-(void)havedChangeAdminiPwdClick:(UIButton *)sender
{
    KDSAddNewWiFiLockStep4ToMasterVC * vc = [KDSAddNewWiFiLockStep4ToMasterVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
