//
//  KDSAddLockActionSheetView.m
//  KaadasLock
//
//  Created by zhaona on 2019/6/26.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSAddLockActionSheetView.h"

@interface KDSAddLockActionSheetView ()

///提示：选择门锁类型
@property (nonatomic,strong)UILabel * choseTipsLb;
///叉按钮
@property (nonatomic,strong)UIButton * delBtn;
///添加蓝牙锁按钮
@property (nonatomic,strong)UIButton * addBleLockBtn;
///添加zigbee锁按钮
@property (nonatomic,strong)UIButton * addZigBeeLockBtn;
///添加门锁套装（相当于添加网关，网关下已经绑定了一个门锁）
@property (nonatomic,strong)UIButton * addWifiLockBtnBtn;
///添加蓝牙和网关之间的线
@property (nonatomic,strong)UIView * line;
///添加网关锁和门锁套装之间的线
@property (nonatomic,strong)UIView * line1;

@end

@implementation KDSAddLockActionSheetView


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       [self setUI];
    }
    
    return self;
}

-(void)showAlertViewinSuperView:(UIView *)superView{
    
    [superView addSubview:self];
}

-(void)setUI
{
    [self addSubview:self.choseTipsLb];
    [self addSubview:self.delBtn];
    [self addSubview:self.addBleLockBtn];
    [self addSubview:self.addZigBeeLockBtn];
    [self addSubview:self.addWifiLockBtnBtn];
    [self addSubview:self.line];
    [self addSubview:self.line1];
    [self.choseTipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(18);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(15);
        make.centerX.mas_equalTo(self.mas_centerX).offset(0);
    }];
    [self.delBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(20);
        make.right.mas_equalTo(self.mas_right).offset(-22);
        make.top.mas_equalTo(self.mas_top).offset(16);
    }];
    [self.addBleLockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(80);
        make.top.mas_equalTo(self.choseTipsLb.mas_bottom).offset(4);
    }];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(18);
        make.right.mas_equalTo(self.mas_right).offset(-18);
        make.height.mas_equalTo(0.5);
        make.bottom.mas_equalTo(self.line1.mas_bottom).offset(-70);
    }];
    [self.addWifiLockBtnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(80);
        make.top.mas_equalTo(self.line).offset(0);
    }];
    [self.line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(18);
        make.right.mas_equalTo(self.mas_right).offset(-18);
        make.height.mas_equalTo(0.5);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-80);
    }];
    [self.addZigBeeLockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(80);
    }];
}

#pragma 点击事件

-(void)cancleBtnClick:(UIButton *)sender
{
    !_cancleBtnClickBlock ?: _cancleBtnClickBlock();
    
}
-(void)addBleLockBtnClick:(UIButton *)sender
{
    !_addBleLockBtnClickBlock ?: _addBleLockBtnClickBlock();
}
-(void)addGWLockBtnClick:(UIButton *)sender
{
    !_addGWLockBtnClickBlock ?: _addGWLockBtnClickBlock();
    
}
-(void)addWifiLockBtnClick:(UIButton *)sender
{
    !_addWifiLockClickBlock ?: _addWifiLockClickBlock();
}


#pragma Lazy --Load

- (UILabel *)choseTipsLb
{
    if (!_choseTipsLb) {
        _choseTipsLb = [UILabel new];
        _choseTipsLb.text = @"选择门锁类型";
        _choseTipsLb.font = [UIFont fontWithName:@"PingFang-SC-Bold" size:15];
        _choseTipsLb.textColor = UIColor.blackColor;
    }
    return _choseTipsLb;
}

- (UIButton *)delBtn
{
    if (!_delBtn) {
        _delBtn = [UIButton new];
        [_delBtn setImage:[UIImage imageNamed:@"cancleIcon"] forState:UIControlStateNormal];
        [_delBtn addTarget:self action:@selector(cancleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _delBtn;
}

- (UIButton *)addBleLockBtn
{
    if (!_addBleLockBtn) {
        _addBleLockBtn = [UIButton new];
        [_addBleLockBtn setImage:[UIImage imageNamed:@"addBleLockIcon"] forState:UIControlStateNormal];
        [_addBleLockBtn setTitle:@"蓝牙锁" forState:UIControlStateNormal];
        _addBleLockBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_addBleLockBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        CGFloat    space = 10;// 图片和文字的间距
        [_addBleLockBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -space/2.0, 0, space/2.0)];
        [_addBleLockBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, space/2.0, 0, -space/2.0)];
        [_addBleLockBtn addTarget:self action:@selector(addBleLockBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addBleLockBtn;
}
- (UIButton *)addZigBeeLockBtn
{
    if (!_addZigBeeLockBtn) {
        _addZigBeeLockBtn = [UIButton new];
        [_addZigBeeLockBtn setImage:[UIImage imageNamed:@"addZigBeeLockIcon"] forState:UIControlStateNormal];
        [_addZigBeeLockBtn setTitle:@"网关锁" forState:UIControlStateNormal];
        _addZigBeeLockBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_addZigBeeLockBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        CGFloat    space = 10;// 图片和文字的间距
        [_addZigBeeLockBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -space/2.0, 0, space/2.0)];
        [_addZigBeeLockBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, space/2.0, 0, -space/2.0)];
        
        [_addZigBeeLockBtn addTarget:self action:@selector(addGWLockBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addZigBeeLockBtn;
}
-(UIButton *)addWifiLockBtnBtn
{
    if (!_addWifiLockBtnBtn) {
        _addWifiLockBtnBtn = [UIButton new];
        [_addWifiLockBtnBtn setImage:[UIImage imageNamed:@"addDoorLockSuit"] forState:UIControlStateNormal];
        [_addWifiLockBtnBtn setTitle:@"WiFi锁" forState:UIControlStateNormal];
        _addWifiLockBtnBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_addWifiLockBtnBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        CGFloat    space = 10;// 图片和文字的间距
        [_addWifiLockBtnBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -space/2.0, 0, space/2.0)];
        [_addWifiLockBtnBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, space/2.0, 0, -space/2.0)];
        
        [_addWifiLockBtnBtn addTarget:self action:@selector(addWifiLockBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _addWifiLockBtnBtn;
}
- (UIView *)line
{
    if (!_line) {
        _line = [UIView new];
        _line.backgroundColor = KDSRGBColor(234, 233, 233);
    }
    return _line;
}
- (UIView *)line1
{
    if (!_line1) {
        _line1 = [UIView new];
        _line1.backgroundColor = KDSRGBColor(234, 233, 233);
    }
    return _line1;
}

@end
