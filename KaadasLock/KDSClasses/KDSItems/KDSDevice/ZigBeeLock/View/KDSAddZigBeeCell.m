//
//  KDSAddZigBeeCell.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/4.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSAddZigBeeCell.h"

@interface KDSAddZigBeeCell ()



@end

@implementation KDSAddZigBeeCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        [self.contentView addSubview:self.deviceIconImg];
        [self.contentView addSubview:self.deviceNameLabel];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
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
        make.centerY.mas_equalTo(self.mas_centerY).offset(0);
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
            devImg.contentMode = UIViewContentModeCenter;
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
            devLb.text = @"ZigBee 网关";
            devLb;
        });
    }
    return _deviceNameLabel;
}

@end
