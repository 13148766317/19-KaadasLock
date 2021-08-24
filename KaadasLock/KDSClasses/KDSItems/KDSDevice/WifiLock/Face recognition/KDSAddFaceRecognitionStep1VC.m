//
//  KDSAddFaceRecognitionStep1VC.m
//  KaadasLock
//
//  Created by zhaona on 2020/5/12.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAddFaceRecognitionStep1VC.h"
#import "KDSAddFaceRecognitionStep2VC.h"

@interface KDSAddFaceRecognitionStep1VC ()

@property (nonatomic,strong)UIImageView * addFaceRecognitionImg;

@end

@implementation KDSAddFaceRecognitionStep1VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = @"添加面容识别";
    [self setUI];
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
    
    UILabel * tipMsg1Labe = [UILabel new];
    tipMsg1Labe.text = @"② 输入已修改的管理密码“********”";
    tipMsg1Labe.font = [UIFont systemFontOfSize:14];
    tipMsg1Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg1Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg1Labe];
    [tipMsg1Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(KDSScreenHeight > 667 ? 107 : 76);
        make.height.mas_equalTo(16);
        make.centerX.equalTo(self.view);
    }];
    
    UILabel * tipMsgLabe = [UILabel new];
    tipMsgLabe.text = @"① 按键区输入“*”两次";
    tipMsgLabe.font = [UIFont systemFontOfSize:14];
    tipMsgLabe.textColor = KDSRGBColor(102, 102, 102);
    tipMsgLabe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe];
    [tipMsgLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(tipMsg1Labe.mas_top).offset(-10);
        make.height.mas_equalTo(16);
        make.left.equalTo(tipMsg1Labe);
        
    }];
    ///第一步
    UILabel * tipMsgLabe1 = [UILabel new];
    tipMsgLabe1.text = @"第一步：门锁进入管理模式";
    tipMsgLabe1.font = [UIFont systemFontOfSize:18];
    tipMsgLabe1.textColor = UIColor.blackColor;
    tipMsgLabe1.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe1];
    [tipMsgLabe1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(tipMsgLabe.mas_top).offset(-20);
        make.height.mas_equalTo(20);
        make.left.equalTo(tipMsg1Labe);
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
        make.left.equalTo(tipMsg1Labe);
        
    }];
    UILabel * tipMsg3Labe = [UILabel new];
    tipMsg3Labe.text = @"④ 语音播报：“已进入管理模式”";
    tipMsg3Labe.font = [UIFont systemFontOfSize:14];
    tipMsg3Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg3Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg3Labe];
    [tipMsg3Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsg2Labe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.left.equalTo(tipMsg1Labe);
        
    }];
                                
    ///添加门锁的logo
    self.addFaceRecognitionImg = [UIImageView new];
    self.addFaceRecognitionImg.image = [UIImage imageNamed:@"lockOperateKeyboard"];
    [self.view addSubview:self.addFaceRecognitionImg];
    [self.addFaceRecognitionImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(201.5);
        make.width.mas_equalTo(99.5);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.top.mas_equalTo(tipMsg3Labe.mas_bottom).offset(KDSScreenHeight < 667 ? 54 : 84);
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
        make.bottom.equalTo(self.view.mas_bottom).offset(KDSScreenHeight <= 667 ? -46 : -66);
    }];
}

-(void)nextBtnClick:(UIButton *)sender
{
    KDSAddFaceRecognitionStep2VC * vc = [KDSAddFaceRecognitionStep2VC new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
