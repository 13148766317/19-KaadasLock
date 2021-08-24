//
//  KDSAddBleAndWiFiLockStep2.m
//  KaadasLock
//
//  Created by zhaona on 2020/4/11.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAddBleAndWiFiLockStep2.h"
#import "KDSWifiLockHelpVC.h"
#import "KDSAddBleAndWiFiLockStep3.h"
#import "KDSBleAndWiFiDoorLockNotActiveVC.h"


@interface KDSAddBleAndWiFiLockStep2 ()

@property (nonatomic,strong) UIImageView * addZigBeeLocklogoImg;

@end

@implementation KDSAddBleAndWiFiLockStep2

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
    tipMsgLabe1.text = @"第二步：门锁激活 ";
    tipMsgLabe1.font = [UIFont systemFontOfSize:18];
    tipMsgLabe1.textColor = UIColor.blackColor;
    tipMsgLabe1.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe1];
    [tipMsgLabe1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(KDSScreenHeight > 667 ? 51 : 20);
        make.height.mas_equalTo(20);
        make.left.mas_equalTo(self.view).offset(KDSScreenWidth / 4);
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
        make.left.mas_equalTo(self.view).offset(KDSScreenWidth / 4);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
    UILabel * tipMsg1Labe = [UILabel new];
    tipMsg1Labe.text = @"门锁是否语音播报：“门锁未激活“";
    tipMsg1Labe.font = [UIFont systemFontOfSize:14];
    tipMsg1Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg1Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg1Labe];
    [tipMsg1Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.view).offset(KDSScreenWidth / 4);
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
   [doorLockActiveBtn setTitle:@"门锁未激活" forState:UIControlStateNormal];
   [doorLockActiveBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
   doorLockActiveBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [doorLockActiveBtn addTarget:self action:@selector(doorLockActiveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
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
    [connectBtn setTitle:@"门锁已激活" forState:UIControlStateNormal];
    [connectBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [connectBtn addTarget:self action:@selector(connectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
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

-(void)navRightClick
{
    KDSWifiLockHelpVC * vc = [KDSWifiLockHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}
//门锁已激活
-(void)connectBtnClick:(UIButton *)sender
{
    KDSAddBleAndWiFiLockStep3 * vc = [KDSAddBleAndWiFiLockStep3 new];
    [self.navigationController pushViewController:vc animated:YES];
}
//门锁未激活
-(void)doorLockActiveBtnClick:(UIButton *)sender
{
    KDSBleAndWiFiDoorLockNotActiveVC * vc = [KDSBleAndWiFiDoorLockNotActiveVC new];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
