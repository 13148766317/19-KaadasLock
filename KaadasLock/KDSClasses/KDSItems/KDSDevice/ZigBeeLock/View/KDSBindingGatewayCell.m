//
//  KDSBindingGatewayCell.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/8.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSBindingGatewayCell.h"

@interface KDSBindingGatewayCell ()

@end

@implementation KDSBindingGatewayCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        [self.contentView addSubview:self.gateWayIconImg];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.AdministratorsLabel];
        [self.contentView addSubview:self.gateWayID];
        [self.contentView addSubview:self.rightIconBtn];
        [self.contentView addSubview:self.gateWayStatusLb];
        [self.contentView addSubview:self.gateWayStatusImg];
        [self.contentView addSubview:self.authMemGwLb];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [self makeMyConstrains];
    }
    return self;
}

-(void)makeMyConstrains
{
    [self.gateWayIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(48);
        make.height.mas_equalTo(41);
        make.left.mas_equalTo(self.mas_left).offset(26);
        make.centerY.mas_equalTo(self.mas_centerY).offset(0);
    }];
    [self.rightIconBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.right.mas_equalTo(self.mas_right).offset(-15);
        make.centerY.mas_equalTo(self.mas_centerY).offset(0);
    }];
    [self.authMemGwLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(70);
        make.right.mas_equalTo(self.mas_right).offset(-15);
        make.centerY.mas_equalTo(self.mas_centerY).offset(0);
        
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(13);
        make.right.mas_equalTo(self.rightIconBtn.mas_right).offset(-20);
        make.left.mas_equalTo(self.gateWayIconImg.mas_right).offset(20);
        make.top.mas_equalTo(self.mas_top).offset(23);
    }];
    [self.AdministratorsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(12);
        make.right.mas_equalTo(self.rightIconBtn.mas_right).offset(-20);
        make.left.mas_equalTo(self.gateWayIconImg.mas_right).offset(20);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(15);
    }];
    [self.gateWayID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(9);
        make.right.mas_equalTo(self.rightIconBtn.mas_right).offset(-20);
        make.left.mas_equalTo(self.gateWayIconImg.mas_right).offset(20);
        make.top.mas_equalTo(self.AdministratorsLabel.mas_bottom).offset(13);
    }];
    [self.gateWayStatusImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(17);
        make.left.mas_equalTo(self.gateWayIconImg.mas_right).offset(20);
        make.top.mas_equalTo(self.gateWayID.mas_bottom).offset(13);
    }];
    [self.gateWayStatusLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(17);
        make.right.mas_equalTo(self.rightIconBtn.mas_right).offset(-20);
        make.left.mas_equalTo(self.gateWayStatusImg.mas_right).offset(13);
        make.top.mas_equalTo(self.gateWayID.mas_bottom).offset(13);
    }];
  
  
}

- (void)setFrame:(CGRect)frame{
    frame.origin.x +=10;
    frame.origin.y += 10;
    frame.size.height -= 10;
    frame.size.width -= 20;
    [super setFrame:frame];
}

/*
- (void)setModel:(id)model{
    self.model = model;
    if ([self.model isKindOfClass:GatewayModel.class]) {
         GatewayModel * gw = (GatewayModel *)model;
        //网关ID
        self.gateWayID.text = [NSString stringWithFormat:@"%@",gw.deviceSN];
        //管理员昵称
        self.AdministratorsLabel.text = [NSString stringWithFormat:@"%@",gw.adminNickname];
        //网关昵称
        //    _gatawayNicknameLabel.text = [NSString stringWithFormat:@"%@",self.model.deviceNickName];
        
        if ([gw.state isEqualToString:@"offline"]) {
            self.gateWayStatusLb.text = @"离线";
            self.gateWayStatusLb.textColor = KDSRGBColor(153, 153, 153);
            self.gateWayStatusImg.image = [UIImage imageNamed:@"Gateway outline_icon"];
            self.gateWayIconImg.image = [UIImage imageNamed:@"Gateway offline"];
        }else if ([gw.state isEqualToString:@"online"]||gw.state == nil){
            self.gateWayStatusLb.text = @"在线";
            self.gateWayStatusLb.textColor = KDSRGBColor(31, 150, 247);
            self.gateWayStatusImg.image = [UIImage imageNamed:@"Gateway online_icon"];
            self.gateWayIconImg.image = [UIImage imageNamed:@"GatewayOnLine"];
        }
    }
}
*/


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark --Lazy load
-(UIImageView *)gateWayIconImg
{
    if (!_gateWayIconImg) {
        _gateWayIconImg = ({
            UIImageView * gwImg = [UIImageView new];
            gwImg.image = [UIImage imageNamed:@"GatewayOnLine"];
            
            gwImg;
        });
    }
    return _gateWayIconImg;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = ({
            UILabel *tLb = [UILabel new];
            tLb.font = [UIFont fontWithName:@"SFUIDisplay-Bold" size:17];
            tLb.textAlignment = NSTextAlignmentLeft;
            tLb.textColor = KDSRGBColor(51, 51, 51);
            tLb.text = @"Interface";
            tLb;
        });
    }
    return _titleLabel;
}

- (UILabel *)AdministratorsLabel
{
    if (!_AdministratorsLabel) {
        _AdministratorsLabel = ({
            UILabel * adminiLabel = [UILabel new];
            adminiLabel.font = [UIFont systemFontOfSize:12];
            adminiLabel.textColor = KDSRGBColor(153, 153, 153);
            adminiLabel.textAlignment = NSTextAlignmentLeft;
            ///暂时用此数据测试
            NSString * str = @"1456235896";
            adminiLabel.text = [NSString stringWithFormat:@"管理员：%@",str];
            adminiLabel;
        });
    }
    return _AdministratorsLabel;
}
- (UILabel *)gateWayID
{
    if (!_gateWayID) {
        _gateWayID = ({
            UILabel * ID = [UILabel new];
            ID.font = [UIFont systemFontOfSize:11];
            ID.textColor = KDSRGBColor(153, 153, 153);
            ID.textAlignment = NSTextAlignmentLeft;
            ///暂时用此数据测试
            NSString * str = @"GW01182510040";
            ID.text = [NSString stringWithFormat:@"ID：%@",str];
            ID;
        });
    }
    return _gateWayID;
}
- (UIButton *)rightIconBtn
{
    if (!_rightIconBtn) {
        _rightIconBtn = ({
            UIButton * rBtn = [UIButton new];
            rBtn.backgroundColor = UIColor.clearColor;
            rBtn.selected = NO;
            [rBtn setImage:[UIImage imageNamed:@"未选择"] forState:UIControlStateNormal];
            [rBtn setImage:[UIImage imageNamed:@"选择"] forState:UIControlStateSelected];
            rBtn;
        });
    }
    return _rightIconBtn;
}
- (UILabel *)authMemGwLb
{
    if (!_authMemGwLb) {
        _authMemGwLb = [UILabel new];
        _authMemGwLb.text = @"(授权网关)";
        _authMemGwLb.textColor = KDSRGBColor(153, 153, 153);
        _authMemGwLb.font = [UIFont systemFontOfSize:12];
        _authMemGwLb.textAlignment = NSTextAlignmentRight;
    }
    return _authMemGwLb;
}

- (UIImageView *)gateWayStatusImg
{
    if (!_gateWayStatusImg) {
        _gateWayStatusImg = ({
            UIImageView * gwsImg = [UIImageView new];
            gwsImg.image = [UIImage imageNamed:@"Gateway online_icon"];
            
            gwsImg;
        });
    }
    return _gateWayStatusImg;
}
- (UILabel *)gateWayStatusLb
{
    if (!_gateWayStatusLb) {
        _gateWayStatusLb = ({
            UILabel * gwsLb = [UILabel new];
            gwsLb.font = [UIFont systemFontOfSize:12];
            gwsLb.textColor = KDSRGBColor(31, 150, 247);
            gwsLb.textAlignment = NSTextAlignmentLeft;
            gwsLb.text = @"在线";
            gwsLb;
        });
    }
    return _gateWayStatusLb;
}


@end
