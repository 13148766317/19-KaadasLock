//
//  KDSDeviceContentCell.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/9.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSDeviceContentCell.h"

@interface KDSDeviceContentCell ()

///设备图标
@property (nonatomic,readwrite,strong)UIImageView * deviceIconImg;
///设备名称
@property (nonatomic,readwrite,strong)UILabel * deviceNameLabel;
///电量图标
@property (nonatomic,readwrite,strong)UIImageView * ElectricQuantityImg;
///电量百分比
@property (nonatomic,readwrite,strong)UILabel * BatteryPercentageLabel;
///蓝牙状态图标
@property (nonatomic,readwrite,strong)UIImageView * bluIconImg;
///蓝牙状态文字显示
@property (nonatomic,readwrite,strong)UILabel * bluStipLabel;

@end

@implementation KDSDeviceContentCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        [self.contentView addSubview:self.deviceIconImg];
        [self.contentView addSubview:self.deviceNameLabel];
        [self.contentView addSubview:self.ElectricQuantityImg];
        [self.contentView addSubview:self.BatteryPercentageLabel];
        [self.contentView addSubview:self.bluIconImg];
        [self.contentView addSubview:self.bluStipLabel];
        
        [self makeMyConstrains];
    }
    return self;
}

-(void)makeMyConstrains
{
    [self.deviceIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(22);
        make.height.mas_equalTo(87);
        make.left.mas_equalTo(self.mas_left).offset(35);
        make.centerY.mas_equalTo(self.mas_centerY).offset(0);
    }];
    [self.deviceNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(15);
        make.right.mas_equalTo(self.mas_right).offset(-40);
        make.left.mas_equalTo(self.deviceIconImg.mas_right).offset(43);
        make.top.mas_equalTo(self.mas_top).offset(31);
    }];
    [self.ElectricQuantityImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(13);
        make.width.mas_equalTo(23);
        make.left.mas_equalTo(self.deviceIconImg.mas_right).offset(43);
        make.top.mas_equalTo(self.deviceNameLabel.mas_bottom).offset(6);
        
        
    }];
    [self.BatteryPercentageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(12);
        make.right.mas_equalTo(self.mas_right).offset(-40);
        make.left.mas_equalTo(self.ElectricQuantityImg.mas_right).offset(8);
        make.top.mas_equalTo(self.deviceNameLabel.mas_bottom).offset(6);
    }];
    [self.bluIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(17);
        make.left.mas_equalTo(self.deviceIconImg.mas_right).offset(43);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-31);
    }];
    [self.bluStipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(12);
        make.right.mas_equalTo(self.mas_right).offset(-40);
        make.left.mas_equalTo(self.bluIconImg.mas_right).offset(8);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-31);
    }];
}

- (void)setFrame:(CGRect)frame{
    frame.origin.x +=10;
    frame.origin.y += 10;
    frame.size.height -= 10;
    frame.size.width -= 20;
    [super setFrame:frame];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark --Lazy load
-(UIImageView *)deviceIconImg
{
    if (!_deviceIconImg) {
        _deviceIconImg = ({
            UIImageView * devImg = [UIImageView new];
            devImg.image = [UIImage imageNamed:@"KDSLockShare"];
            
            devImg;
        });
    }
    return _deviceIconImg;
}

-(UILabel *)deviceNameLabel
{
    if (!_deviceNameLabel) {
        _deviceNameLabel = ({
            UILabel *devLb = [UILabel new];
            devLb.font = [UIFont fontWithName:@"SFUIDisplay-Bold" size:15];
            devLb.textAlignment = NSTextAlignmentLeft;
            devLb.textColor = KDSRGBColor(51, 51, 51);
            devLb.text = @"Kaadas K9 智能锁";
            devLb;
        });
    }
    return _deviceNameLabel;
}

- (UIImageView *)ElectricQuantityImg
{
    if (!_ElectricQuantityImg) {
        _ElectricQuantityImg = ({
            UIImageView * EImg = [UIImageView new];
            EImg.image = [UIImage imageNamed:@"power100"];
            EImg;
        });
    }
    return _ElectricQuantityImg;
}
- (UILabel *)BatteryPercentageLabel
{
    if (!_BatteryPercentageLabel) {
        _BatteryPercentageLabel = ({
            UILabel * BLb = [UILabel new];
            BLb.text = @"电量 100%";
            BLb.font = [UIFont systemFontOfSize:12];
            BLb.textColor = KDSRGBColor(153, 153, 153);
            BLb.textAlignment = NSTextAlignmentLeft;
            BLb;
        });
    }
    return _BatteryPercentageLabel;
}
- (UIImageView *)bluIconImg
{
    if (!_bluIconImg) {
        _bluIconImg = ({
            UIImageView * bImg = [UIImageView new];
            bImg.image = [UIImage imageNamed:@"添加设备-蓝牙"];
            bImg;
        });
    }
    return _bluIconImg;
}
- (UILabel *)bluStipLabel
{
    if (!_bluStipLabel) {
        _bluStipLabel = ({
            UILabel * bSLb = [UILabel new];
            bSLb.text = @"未找到设备";
            bSLb.font = [UIFont systemFontOfSize:12];
            bSLb.textColor = KDSRGBColor(153, 153, 153);
            bSLb.textAlignment = NSTextAlignmentLeft;
            bSLb;
        });
    }
    return _bluStipLabel;
}
@end
