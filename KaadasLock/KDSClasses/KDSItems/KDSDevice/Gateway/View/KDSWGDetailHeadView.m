//
//  KDSWGDetailHeadView.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/26.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSWGDetailHeadView.h"
#import "KDSGW.h"


@interface KDSWGDetailHeadView ()

///网关的图标
@property (nonatomic,readwrite,strong)UIImageView * iconImg;
///背景图
@property (nonatomic,readwrite,strong)UIImageView * bgImg;
///网关是否在线
@property (nonatomic,readwrite,strong)UIImageView * gwStatImg;
///网关是否在线文字提示
@property (nonatomic,readwrite,strong)UILabel * gwStatLabel;
///网关名称、昵称
@property (nonatomic,readwrite,strong)UILabel * gwNameLb;
///网关型号：lse01
@property (nonatomic,readwrite,strong)UILabel*gwType;
///返回按钮
@property (nonatomic,readwrite,strong)UIButton * backBtn;
///标题
@property (nonatomic,readwrite,strong)UILabel * titleLb;
///查看更多网关信息
@property (nonatomic,readwrite,strong)UIButton * moreBtn;
///分享网关按钮
@property (nonatomic,readwrite,strong)UIButton * shareBtn;


@end

@implementation KDSWGDetailHeadView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addMySubViews];
        [self addMyConstraints];
    }
    return self;
}

-(void)addMySubViews
{
    [self addSubview:self.bgImg];
    [self addSubview:self.iconImg];
    [self addSubview:self.gwStatImg];
    [self addSubview:self.gwStatLabel];
    [self addSubview:self.gwNameLb];
    [self addSubview:self.gwType];
    [self addSubview:self.backBtn];
    [self addSubview:self.titleLb];
    [self addSubview:self.moreBtn];
    [self addSubview:self.shareBtn];

    
    
}
-(void)addMyConstraints
{
    [self.bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(0);
    }];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(44);
        make.left.mas_equalTo(self.mas_left).offset(0);
        make.top.mas_equalTo(kStatusBarHeight);
    }];
    [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kStatusBarHeight + 11);
        make.left.mas_equalTo(self.mas_left).offset(100);
        make.right.mas_equalTo(self.mas_right).offset(-100);
    }];
    [self.shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(0.001);
        make.right.mas_equalTo(self.mas_right).offset(0);
        make.top.mas_equalTo(kStatusBarHeight);
    }];
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(44);
        make.right.mas_equalTo(self.mas_right).offset(-15);
        make.top.mas_equalTo(kStatusBarHeight);
    }];
    [self.iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.iconImg.image.size);
        make.centerY.mas_equalTo(self.mas_centerY).offset(0);
        make.centerX.mas_equalTo(self.mas_centerX).offset(0);
        
    }];
    [self.gwNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom).offset(-16);
        make.height.mas_equalTo(18);
        make.centerX.mas_equalTo(self.mas_centerX).offset(0);
    }];
    [self.gwStatImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.gwNameLb.mas_top).offset(-12);
        make.width.height.mas_equalTo(17);
        make.centerX.mas_equalTo(self.mas_centerX).offset(-20);
    }];
    [self.gwStatLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.gwNameLb.mas_top).offset(-12);
        make.height.mas_equalTo(17);
        make.width.mas_equalTo(30);
        make.centerX.mas_equalTo(self.mas_centerX).offset(10);
    }];
    [self.gwType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-17);
        make.height.mas_equalTo(17);
        make.width.mas_equalTo(100);
        make.bottom.mas_equalTo(0);
    }];
    
    
}

-(void)setModel:(id)model
{
    _model = model;
    
    if ([model isKindOfClass:KDSGW.class]) {
        GatewayModel * gw = ((KDSGW *)model).model;
        if ([gw.model isEqualToString:@"6030"] || [gw.model isEqualToString:@"6032"]) {
            self.iconImg.image = [UIImage imageNamed:@"6030GW"];
            [self.iconImg mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.mas_centerY).offset(0);
                make.centerX.mas_equalTo(self.mas_centerX).offset(0);
                make.width.mas_offset(81);
                make.height.mas_offset(46);
                
            }];
        }else{
            self.iconImg.image = [UIImage imageNamed:@"Gateway_pic"];
            [self.iconImg mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.mas_centerY).offset(0);
                make.centerX.mas_equalTo(self.mas_centerX).offset(0);
                make.width.mas_offset(81);
                make.height.mas_offset(65);
                
            }];
        }
        self.gwNameLb.text = [NSString stringWithFormat:@"%@",gw.deviceNickName ?: gw.deviceSN];
        if ([model online]){///在线
            [self setDeviceStateImage:[UIImage imageNamed:@"wifi连接中2"] description:Localized(@"online")];
            self.gwStatLabel.textColor = KDSRGBColor(0x1f, 0x96, 0xf7);
        }else{
            [self setDeviceStateImage:[UIImage imageNamed:@"gwOfflineImg"] description:Localized(@"offline")];
            self.gwStatLabel.textColor = KDSRGBColor(124 , 210, 255);
            
        }
        
    }
}

- (void)setDeviceStateImage:(UIImage *)image description:(NSString *)desc
{
    self.gwStatImg.image = image;
    self.gwStatLabel.text = desc;
}

#pragma mark 点击事件

-(void)backBtnClick:(UIButton *)sender
{
    !_backBtnClickBlock ?: _backBtnClickBlock();
}
-(void)moreBtnClick:(UIButton *)sender
{
    !_moreBtnClickBlock ?: _moreBtnClickBlock();
    
}
-(void)shareBtnClick:(UIButton *)sender
{
    !_shareBtnClickBlock ?: _shareBtnClickBlock();
}

#pragma mark --Lazy load

- (UIImageView *)iconImg
{
    if (!_iconImg) {
        _iconImg = ({
            UIImageView * m = [UIImageView new];
            m.image = [UIImage imageNamed:@"gwDetailIconImg"];
            m;
        });
    }
    return _iconImg;
}
- (UIImageView *)gwStatImg
{
    if (!_gwStatImg) {
        _gwStatImg = ({
            UIImageView * s = [UIImageView new];
            s.image = [UIImage imageNamed:@"Gateway online_icon"];
            s;
        });
    }
    return _gwStatImg;
}

- (UILabel *)gwStatLabel
{
    if (!_gwStatLabel) {
        _gwStatLabel = ({
            UILabel * lb = [UILabel new];
            lb.textColor = KDSRGBColor(31, 150, 247);
            lb.textAlignment = NSTextAlignmentLeft;
            lb.font = [UIFont systemFontOfSize:12];
            lb.text = @"在线";
            lb;
        });
    }
    return _gwStatLabel;
}
- (UILabel *)gwNameLb
{
    if (!_gwNameLb) {
        _gwNameLb = ({
            UILabel * nLb = [UILabel new];
            nLb.textAlignment = NSTextAlignmentCenter;
            nLb.font = [UIFont fontWithName:@"PingFang-SC-Heavy" size:15];
            nLb.textColor = UIColor.whiteColor;
            nLb.backgroundColor = UIColor.clearColor;
            nLb;
        });
    }
    return _gwNameLb;
}
- (UILabel *)gwType
{
    if (!_gwType) {
        _gwType = ({
            UILabel * tLb = [UILabel new];
            tLb.textAlignment = NSTextAlignmentRight;
            tLb.font = [UIFont systemFontOfSize:12];
            tLb.hidden = YES;
            tLb.textColor = KDSRGBColor(153, 153, 153);
            tLb.text = @"型号：lse01";
            tLb;
        });
    }
    return _gwType;
}
- (UIImageView *)bgImg
{
    if (!_bgImg) {
        _bgImg = [UIImageView new];
        _bgImg.image = [UIImage imageNamed:@"deviceBg"];
    }
    return _bgImg;
}
- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton new];
        [_backBtn setImage:[UIImage imageNamed:@"whiteBack"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}
- (UILabel *)titleLb
{
    if (!_titleLb) {
        _titleLb = [UILabel new];
        _titleLb.text = Localized(@"gateWay");
        _titleLb.font = [UIFont fontWithName:@"PingFang-SC-Heavy" size:17];
        _titleLb.textColor = UIColor.whiteColor;
        _titleLb.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLb;
}
- (UIButton *)moreBtn
{
    if (!_moreBtn) {
        _moreBtn = [UIButton new];
        [_moreBtn setImage:[UIImage imageNamed:@"seeMoreWither"] forState:UIControlStateNormal];
        [_moreBtn addTarget:self action:@selector(moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreBtn;
}

- (UIButton *)shareBtn
{
    if (!_shareBtn) {
        _shareBtn = [UIButton new];
        [_shareBtn setImage:[UIImage imageNamed:@"shareWither"] forState:UIControlStateNormal];
        [_shareBtn addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _shareBtn.hidden = YES;
    }
    
    return _shareBtn;
}

@end
