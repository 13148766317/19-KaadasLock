//
//  KDSConnectedReconnectVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/3/10.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSConnectedReconnectVC.h"
#import "KDSWifiLockHelpVC.h"
#import "KDSAccordDistributionNetworkVC.h"

@interface KDSConnectedReconnectVC ()

@property (nonatomic,strong) UIImageView * addZigBeeLocklogoImg;

@end

@implementation KDSConnectedReconnectVC

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
        make.top.mas_equalTo(self.view.mas_top).offset(3);
    }];
    ///第一步
    UILabel * tipMsgLabe1 = [UILabel new];
    tipMsgLabe1.text = @"第一步：已进入管理模式";
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
    tipMsgLabe.text = @"① 按键区输入“*”两次";
    tipMsgLabe.font = [UIFont systemFontOfSize:14];
    tipMsgLabe.textColor = KDSRGBColor(102, 102, 102);
    tipMsgLabe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe];
    [tipMsgLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe1.mas_bottom).offset(15);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.view).offset(KDSScreenWidth / 4);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
    UILabel * tipMsg1Labe = [UILabel new];
    tipMsg1Labe.text = @"②输入已修改的管理密码“********”";
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
    UILabel * tipMsg2Labe = [UILabel new];
    tipMsg2Labe.text = @"③ 按“#”确认，";
    tipMsg2Labe.font = [UIFont systemFontOfSize:14];
    tipMsg2Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg2Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg2Labe];
    [tipMsg2Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsg1Labe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.view).offset(KDSScreenWidth / 4);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
        
    }];
    UILabel * tipMsg3Labe = [UILabel new];
    tipMsg3Labe.text = @"④语音播报：“已进入管理模式”";
    tipMsg3Labe.font = [UIFont systemFontOfSize:14];
    tipMsg3Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg3Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg3Labe];
    [tipMsg3Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsg2Labe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.view).offset(KDSScreenWidth / 4);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
        
    }];
    ///添加门锁的logo
    self.addZigBeeLocklogoImg = [UIImageView new];
    self.addZigBeeLocklogoImg.image = [UIImage imageNamed:@"changeAdminiPwdImg"];
    [self.view addSubview:self.addZigBeeLocklogoImg];
    [self.addZigBeeLocklogoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(201.5);
        make.width.mas_equalTo(99.5);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.top.mas_equalTo(tipMsg3Labe.mas_bottom).offset(KDSScreenHeight < 667 ? 19 : 59);
    }];
    

   UILabel * routerProtocolLb = [UILabel new];
   routerProtocolLb.text = @"已进入管理模式";
   routerProtocolLb.textColor = KDSRGBColor(158, 158, 158);
   routerProtocolLb.textAlignment = NSTextAlignmentCenter;
   routerProtocolLb.font = [UIFont systemFontOfSize:12];
   [self.view addSubview:routerProtocolLb];
   [routerProtocolLb mas_makeConstraints:^(MASConstraintMaker *make) {
       make.bottom.equalTo(self.view.mas_bottom).offset(KDSScreenHeight <= 667 ? -28 : -48);
       make.height.equalTo(@20);
       make.centerX.equalTo(self.view);
   }];
    
    UIButton * nextBtn = [UIButton new];
    [nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [nextBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    nextBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    nextBtn.layer.masksToBounds = YES;
    nextBtn.layer.cornerRadius = 20;
    [self.view addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(routerProtocolLb.mas_top).offset(KDSScreenHeight > 667 ? -30 : -16);
    }];
    
}

//NSArray *_arrayImages4Connecting; 几张图片按顺序切换
- (void)startAnimation4Connection {
    NSArray * _arrayImages4Connecting = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"inAdminiModelImg1.jpg"],
                                         [UIImage imageNamed:@"inAdminiModelImg2.jpg"],
                                         [UIImage imageNamed:@"inAdminiModelImg3.jpg"],
                                         [UIImage imageNamed:@"inAdminiModelImg4.jpg"],
                                         [UIImage imageNamed:@"inAdminiModelImg5.jpg"],
                                         [UIImage imageNamed:@"inAdminiModelImg6.jpg"],
                                         [UIImage imageNamed:@"inAdminiModelImg7.jpg"],
                                         nil];
    [self.addZigBeeLocklogoImg setAnimationImages:_arrayImages4Connecting];
    [self.addZigBeeLocklogoImg setAnimationRepeatCount:0];
    [self.addZigBeeLocklogoImg setAnimationDuration:7.0f];
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

-(void)nextBtnClick:(UITapGestureRecognizer *)tap
{
    KDSAccordDistributionNetworkVC * vc = [KDSAccordDistributionNetworkVC new];
    vc.lock = self.lock;
    [self.navigationController pushViewController:vc animated:YES];
}



@end
