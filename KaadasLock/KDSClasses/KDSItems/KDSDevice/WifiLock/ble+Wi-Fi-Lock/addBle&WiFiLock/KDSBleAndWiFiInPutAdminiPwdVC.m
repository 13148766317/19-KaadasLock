//
//  KDSBleAndWiFiInPutAdminiPwdVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/4/15.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSBleAndWiFiInPutAdminiPwdVC.h"
#import "KDSWifiLockHelpVC.h"
#import "KDSAddNewWiFiLockStep1VC.h"
#import "KDSBleAndWiFiDoorLockVerificationVC.h"


@interface KDSBleAndWiFiInPutAdminiPwdVC ()

///密码输入框
@property (nonatomic, strong) UITextField * pwdTf;
@property (nonatomic, strong) UIButton * nextBtn;
@property (nonatomic, strong) UIView * supView;

///密码明文切换
@property (nonatomic,strong)  UIButton *visibleBtn;
@end

@implementation KDSBleAndWiFiInPutAdminiPwdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.navigationTitleLabel.text = @"门锁验证";
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [self setUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    ///蓝牙解析的数据57字节（28随机数+4CRC+13蓝牙SN+12蓝牙key）数据解析格式和之前Wi-Fi的一致
}

-(void)setUI
{
    self.supView = [UIView new];
    self.supView.backgroundColor = UIColor.whiteColor;
    self.supView.layer.masksToBounds = YES;
    self.supView.layer.cornerRadius = 10;
    [self.view addSubview:self.supView];
    [self.supView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.top.equalTo(self.view.mas_top).offset(10);
        make.bottom.equalTo(self.view.mas_bottom).offset(-10);
    }];
    
    UILabel * tipMsgLabe1 = [UILabel new];
    tipMsgLabe1.text = @"输入锁管理员密码";
    tipMsgLabe1.font = [UIFont systemFontOfSize:18];
    tipMsgLabe1.textColor = UIColor.blackColor;
    tipMsgLabe1.textAlignment = NSTextAlignmentLeft;
    [self.supView addSubview:tipMsgLabe1];
    [tipMsgLabe1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.supView.mas_top).offset(35);
        make.height.mas_equalTo(20);
        make.left.equalTo(self.supView.mas_left).offset(30);
        make.right.equalTo(_supView.mas_right).offset(-30);
    }];
    
    UIView * line = [UIView new];
    line.backgroundColor = KDSRGBColor(220, 220, 220);
    [_supView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipMsgLabe1.mas_bottom).offset(50);
        make.left.equalTo(_supView.mas_left).offset(30);
        make.right.equalTo(_supView.mas_right).offset(-30);
        make.height.equalTo(@1);
    }];
    UIImageView * pwdIconImg = [UIImageView new];
    pwdIconImg.image = [UIImage imageNamed:@"wifi-Lock-pwdIcon"];
    [_supView addSubview:pwdIconImg];
    [pwdIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@20);
        make.left.equalTo(_supView.mas_left).offset(30);
        make.bottom.equalTo(line.mas_top).offset(-5);
    }];
    
    _pwdTf= [UITextField new];
    _pwdTf.placeholder=Localized(@"input6~12NumericPwd");
    _pwdTf.secureTextEntry = YES;
    _pwdTf.borderStyle=UITextBorderStyleNone;
    _pwdTf.textAlignment = NSTextAlignmentLeft;
    _pwdTf.keyboardType = UIKeyboardTypeNumberPad;
    _pwdTf.font = [UIFont systemFontOfSize:13];
    _pwdTf.textColor = UIColor.blackColor;
    [_pwdTf addTarget:self action:@selector(pwdtextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_supView addSubview:_pwdTf];
    [_pwdTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(pwdIconImg.mas_right).offset(7);
        make.right.mas_equalTo(_supView.mas_right).offset(-30);
        make.bottom.equalTo(line.mas_top).offset(0);
        make.height.equalTo(@30);
    }];
    
    // zhu 添加密文
    self.visibleBtn  =  [UIButton buttonWithType:UIButtonTypeCustom] ;
    [self.visibleBtn setImage:[UIImage imageNamed:@"眼睛闭Default"] forState:UIControlStateNormal];
    [self.visibleBtn setImage:[UIImage imageNamed:@"眼睛开Default"] forState:UIControlStateSelected];
    // 添加点击事件
    [self.visibleBtn  addTarget:self action:@selector(visiblebtn:) forControlEvents:UIControlEventTouchUpInside];
    [_supView addSubview:self.visibleBtn];
    [self.visibleBtn  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_pwdTf.mas_centerY);
        make.right.mas_equalTo(_supView.mas_right).offset(-20);
        make.width.equalTo(@34);
        make.height.equalTo(@17);
       // make.bottom.equalTo(line.mas_top).offset(0);
        
    }];
    _nextBtn = [UIButton new];
    [_nextBtn setTitle:Localized(@"nextStep") forState:UIControlStateNormal];
    [_nextBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _nextBtn.backgroundColor = KDSRGBColor(191, 191, 191);
    _nextBtn.layer.masksToBounds = YES;
    _nextBtn.layer.cornerRadius = 22;
    _nextBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_nextBtn addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextBtn];
    [_nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.supView.mas_bottom).offset(-73);
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        
    }];
    
    
}


#pragma mark 控件点击事件

-(void)navRightClick
{
    KDSWifiLockHelpVC * vc = [KDSWifiLockHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)nextClick:(UIButton *)sender
{
    //upDataAdminiContinueStr
    NSLog(@"点击了下一步");
    KDSBleAndWiFiDoorLockVerificationVC * vc = [KDSBleAndWiFiDoorLockVerificationVC new];
    vc.crcData = self.crcData;
    vc.adminPwd = self.pwdTf.text;
    vc.bleTool = self.bleTool;
    vc.tsn = self.tsn;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)navBackClick
{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[KDSAddNewWiFiLockStep1VC class]]) {
            KDSAddNewWiFiLockStep1VC *A =(KDSAddNewWiFiLockStep1VC *)controller;
            [self.navigationController popToViewController:A animated:YES];
        }
    }
}

-(void)pwdtextFieldDidChange:(UITextField *)textField
{
    if (textField.text.length >= 6) {
            _nextBtn.backgroundColor = KDSRGBColor(31, 150, 247);
       }
       if (textField.text .length < 6) {
           _nextBtn.backgroundColor = KDSRGBColor(191, 191, 191);
       }
       if (textField.text.length > 12) {
           textField.text = [textField.text substringToIndex:12];
           [MBProgressHUD showError:Localized(@"PwdLength6BitsAndNotMoreThan12bits")];
       }
}

///密码明文切换
- (void)visiblebtn:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.pwdTf.secureTextEntry = NO;
    }else{
    self.pwdTf.secureTextEntry = YES;
    }
    [self.pwdTf becomeFirstResponder];
    
}



#pragma mark --键盘弹出
- (void)keyboardWillChangeFrame:(NSNotification *)notification{
    
    //取出键盘动画的时间
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //取得键盘最后的frame
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //计算控制器的view需要平移的距离
    CGFloat transformY = keyboardFrame.origin.y - self.nextBtn.frame.size.height;
    NSLog(@"键盘上移的高度：%f-----取出键盘动画时间：%f",transformY,duration);
    [UIView animateWithDuration:duration animations:^{
        [self.nextBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.supView.mas_top).offset(170);
            make.width.equalTo(@200);
            make.height.equalTo(@44);
            make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        }];
    }];
}
#pragma mark --键盘收回
- (void)keyboardDidHide:(NSNotification *)notification{
    
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        [self.nextBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.supView.mas_bottom).offset(-73);
            make.width.equalTo(@200);
            make.height.equalTo(@44);
            make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        }];
    }];
}


@end
