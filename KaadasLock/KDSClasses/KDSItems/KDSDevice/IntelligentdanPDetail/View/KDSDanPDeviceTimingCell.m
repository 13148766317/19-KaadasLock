//
//  KDSDanPDeviceTimingCell.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/13.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSDanPDeviceTimingCell.h"

@interface KDSDanPDeviceTimingCell ()

///显示重复日期的控件（周日~周六）
@property (strong, nonatomic)UILabel *repeatLabel;
///显示设备定时（开始—结束）时间
@property (strong, nonatomic)UILabel *startAndEndTimerLb;
///是否启动定时的按钮
@property (strong, nonatomic)UIButton *switchBtn;
///显示开关(单键一个、双键两个)的具体状态
@property (strong, nonatomic)UILabel *powerKaiS1Lb;
///显示开关(单键一个、双键两个)的具体状态
@property (strong, nonatomic)UILabel *powerKaiS2Lb;
///显示定时状态的图标
@property (strong, nonatomic)UIImageView * timingSrartImg;
@property (strong, nonatomic)UIView * line;

@end


@implementation KDSDanPDeviceTimingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = UIColor.whiteColor;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 4;
        self.timingSrartImg = [UIImageView new];
        self.timingSrartImg.image = [UIImage imageNamed:@"open-deviceTimingIcon"];
        [self.contentView addSubview:self.timingSrartImg];
        [self.timingSrartImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(8);
            make.top.mas_equalTo(self.mas_top).offset(15);
            make.width.height.equalTo(@15);
        }];
        self.switchBtn = [UIButton new];
        [self.switchBtn setBackgroundImage:[UIImage imageNamed:@"on-powerStatusIcon"] forState:UIControlStateNormal];
        [self.switchBtn setBackgroundImage:[UIImage imageNamed:@"off-powerStatusIcon"] forState:UIControlStateSelected];
        [self.contentView addSubview:self.switchBtn];
        self.switchBtn.selected = YES;
        [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@37);
            make.height.equalTo(@18);
            make.right.mas_equalTo(self.mas_right).offset(-10);
            make.top.mas_equalTo(self.mas_top).offset(20);
        }];
        self.startAndEndTimerLb = [UILabel new];
        self.startAndEndTimerLb.text = @"18:00 - 22:00";
        self.startAndEndTimerLb.font = [UIFont fontWithName:@"PingFang-SC-Bold" size:18];
        self.startAndEndTimerLb.textColor = KDSRGBColor(49, 49, 49);
        [self.contentView addSubview:self.startAndEndTimerLb];
        [self.startAndEndTimerLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(13);
            make.height.equalTo(@20);
            make.left.mas_equalTo(self.mas_left).offset(35);
            make.right.mas_equalTo(self.mas_right).offset(-20);
        }];
        self.repeatLabel= [UILabel new];
        self.repeatLabel.text = @"周一 周二 周三 周四 周五 周六";
        self.repeatLabel.textColor = KDSRGBColor(95, 95, 95);
        self.repeatLabel.font = [UIFont systemFontOfSize:10];
        [self.contentView addSubview:self.repeatLabel];
        [self.repeatLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@15);
            make.top.mas_equalTo(self.startAndEndTimerLb.mas_bottom).offset(10);
            make.left.mas_equalTo(self.mas_left).offset(35);
            make.right.mas_equalTo(self.mas_right).offset(-20);
        }];
        self.line = [UIView new];
        self.line.backgroundColor = KDSRGBColor(238, 238, 238);
        [self.contentView addSubview:self.line];
        [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-35);
            make.height.equalTo(@1);
        }];
        
        self.powerKaiS1Lb = [UILabel new];
        self.powerKaiS1Lb.text = @"电源开关1-开启";
        self.powerKaiS1Lb.textColor = KDSRGBColor(44, 44, 44);
        self.powerKaiS1Lb.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.powerKaiS1Lb];
        [self.powerKaiS1Lb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(35);
            make.height.equalTo(@35);
            make.bottom.mas_equalTo(self.mas_bottom).offset(0);
        }];
        self.powerKaiS2Lb = [UILabel new];
        self.powerKaiS2Lb.text = @"电源开关2-开启";
        self.powerKaiS2Lb.textColor = KDSRGBColor(44, 44, 44);
        self.powerKaiS2Lb.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.powerKaiS2Lb];
        [self.powerKaiS2Lb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.powerKaiS1Lb.mas_right).offset(KDSScreenHeight < 667 ? 20 : 40);
            make.height.equalTo(@35);
            make.bottom.mas_equalTo(self.mas_bottom).offset(0);
        }];
        
    }
    
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setFrame:(CGRect)frame
{
    frame.origin.x +=10;
    frame.origin.y += 10;
    frame.size.height -= 10;
    frame.size.width -= 20;
    [super setFrame:frame];
}

@end
