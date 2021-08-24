//
//  KDSShowBleAndWiFiLockView.m
//  KaadasLock
//
//  Created by zhaona on 2020/4/22.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSShowBleAndWiFiLockView.h"

@interface KDSShowBleAndWiFiLockView ()

@end

@implementation KDSShowBleAndWiFiLockView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self layoutAllSubviews];
    }
    return self;
}
 
- (void)layoutAllSubviews{
    
    UIImageView * tipsImg = [UIImageView new];
    tipsImg.image = [UIImage imageNamed:@"addBleAndWiFiLockSuccessImg"];
    [self addSubview:tipsImg];
    [tipsImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@251.5);
        make.height.equalTo(@346);
        make.centerX.equalTo(self);
        make.centerY.equalTo(self);
    }];
    UILabel * tipsLb = [UILabel new];
    tipsLb.text = @"门锁已添加成功";
    tipsLb.textColor = UIColor.whiteColor;
    tipsLb.font = [UIFont systemFontOfSize:19];
    tipsLb.textAlignment = NSTextAlignmentCenter;
    [self addSubview:tipsLb];
    [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@30);
        make.top.equalTo(tipsImg.mas_top).offset(20);
        make.centerX.equalTo(tipsImg);
    }];
    UILabel * tipsLb1 = [UILabel new];
    tipsLb1.text = @"快来设置智能开关吧！";
    tipsLb1.textColor = UIColor.whiteColor;
    tipsLb1.font = [UIFont systemFontOfSize:19];
    tipsLb1.textAlignment = NSTextAlignmentCenter;
    [self addSubview:tipsLb1];
    [tipsLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@30);
        make.top.equalTo(tipsLb.mas_bottom).offset(10);
        make.centerX.equalTo(tipsImg);
    }];
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setImage:[UIImage imageNamed:@"cancleBtnIconImg"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@35);
        make.bottom.equalTo(tipsImg.mas_top).offset(-1);
        make.right.equalTo(tipsImg.mas_right);
    }];
    
    UIButton * settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingBtn setTitle:@"立即设置" forState:UIControlStateNormal];
    settingBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    settingBtn.layer.masksToBounds = YES;
    settingBtn.layer.cornerRadius = 18.6;
    [settingBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    settingBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [settingBtn addTarget:self action:@selector(settingBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:settingBtn];
    [settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@188);
        make.height.equalTo(@38);
        make.bottom.equalTo(tipsImg.mas_bottom).offset(-20);
        make.centerX.equalTo(self);
    }];
    
}
#pragma mark - 手势点击事件,移除View
- (void)dismissContactView:(UITapGestureRecognizer *)tapGesture{
    
    [self dismissContactView];
}
 
-(void)dismissContactView
{
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
    
}
-(void)cancelBtnClick:(UIButton *)sender
{
    !_cancelBtnClickBlock ?: _cancelBtnClickBlock();
    
}
-(void)settingBtnClick:(UIButton *)sender
{
    !_settingBtnClickBlock ?: _settingBtnClickBlock();
}


@end
