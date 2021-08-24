//
//  KDSCatEyePlaybackCell.m
//  KaadasLock
//
//  Created by zhaona on 2019/5/8.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSCatEyePlaybackCell.h"

@interface KDSCatEyePlaybackCell ()


@end

@implementation KDSCatEyePlaybackCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self addMySubView];
        [self makeConstraints];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

-(void)setAlarmModel:(AlarmMessageModel *)alarmModel{
    _alarmModel = alarmModel;
    if (alarmModel.photoImg) {
        self.photoImg.image = alarmModel.photoImg;
    }else{
        self.photoImg.image = [UIImage imageNamed:@"默认图片"];
    }
    NSInteger dateInte = alarmModel.timeStr.integerValue;
    self.lbAndSnaptime.text = [KDSTool timestampSwitchTime:dateInte andFormatter:@"yyyy-MM-dd HH:mm:ss"];
    self.lbAndSnaptime.textColor = KDSRGBColor(133, 136, 149);
    if ([alarmModel.isChecked isEqualToString:@"true"]) {
        NSLog(@"isChecked333 = %@",alarmModel.isChecked);
        self.boolReadImg.hidden = YES;
    }else{
        self.boolReadImg.hidden = NO;
    }
}

-(void)addMySubView
{
    [self.contentView addSubview:self.photoImg];
    [self.contentView addSubview:self.lbAndSnaptime];
    [self.contentView addSubview:self.boolReadImg];
    [self.contentView addSubview:self.rightArrowImg];
}

-(void)makeConstraints
{
    [self.photoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(68);
        make.width.mas_equalTo(120);
        make.left.mas_equalTo(self.mas_left).offset(16);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-10);
        
    }];
    [self.rightArrowImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(8);
        make.height.mas_equalTo(13);
        make.right.mas_equalTo(self.mas_right).offset(-16);
        make.centerY.mas_equalTo(self.mas_centerY).offset(0);
    }];
    
    [self.boolReadImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(6);
        make.right.mas_equalTo(self.rightArrowImg.mas_left).offset(-13);
        make.centerY.mas_equalTo(self.mas_centerY).offset(0);
    }];
    
    [self.lbAndSnaptime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.photoImg.mas_right).offset(16);
        make.height.mas_equalTo(15);
        make.centerY.mas_equalTo(self.mas_centerY).offset(0);
        make.right.mas_equalTo(self.boolReadImg.mas_left).offset(-20);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark --Lazy load

- (UIImageView *)photoImg
{
    if (!_photoImg) {
        _photoImg = ({
            UIImageView * img = [UIImageView new];
            img.image = [UIImage imageNamed:@"默认图片"];
            img;
        });
    }
    return _photoImg;
}

- (UILabel *)lbAndSnaptime
{
    if (!_lbAndSnaptime) {
        _lbAndSnaptime = ({
            UILabel * lb = [UILabel new];
            lb.textAlignment = NSTextAlignmentLeft;
            lb.font = [UIFont systemFontOfSize:11];
            lb.textColor = KDSRGBColor(102, 102, 102);
            lb.text = @"0000/00/00 00:00:00";
            lb.backgroundColor = UIColor.clearColor;
            lb;
        });
    }
    return _lbAndSnaptime;
}

- (UIImageView *)boolReadImg
{
    if (!_boolReadImg) {
        _boolReadImg = ({
            UIImageView * bImg = [UIImageView new];
            bImg.backgroundColor = KDSRGBColor(255, 0, 21);
            bImg.layer.masksToBounds = YES;
            bImg.layer.cornerRadius = 3;
            bImg;
        });
    }
    return _boolReadImg;
}

- (UIImageView *)rightArrowImg
{
    if (!_rightArrowImg) {
        _rightArrowImg = ({
            UIImageView * rImg = [UIImageView new];
            rImg.image = [UIImage imageNamed:@"rightArrow"];
            rImg.backgroundColor = UIColor.clearColor;
            rImg;
        });
    }
    return _rightArrowImg;
}

+ (NSString *)ID{
    return @"KDSCatEyePlaybackCell";
}

@end
