//
//  KDSSceneDetailStyle1Cell.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/18.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSSceneDetailStyle1Cell.h"

@interface KDSSceneDetailStyle1Cell ()

///展示场景触发条件
@property (nonatomic,strong)UILabel * triggerTipsLb;
@property (nonatomic,strong)UIView * line1;
@property (nonatomic,strong)UIView * line2;
///定时的图标
@property (nonatomic,strong)UIImageView * timingIconImg;
///定时的标签
@property (nonatomic,strong)UILabel * timingTipsLb;
///现实具体的定时策略Lb
@property (nonatomic,strong)UILabel * timingLb;
@property (nonatomic,strong)UIImageView * rightArrowImg1;
///具体设备的图标
@property (nonatomic,strong)UIImageView * deviceTipsImg;
///具体设备的名称
@property (nonatomic,strong)UILabel * deviceNameLb;
///具体设备状态的Lb
@property (nonatomic,strong)UILabel * deviceStateLb;
@property (nonatomic,strong)UIImageView * rightArrowImg2;

@end

@implementation KDSSceneDetailStyle1Cell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = UIColor.whiteColor;
        self.triggerTipsLb = [UILabel new];
        self.triggerTipsLb.text = @"场景触发条件";
        self.triggerTipsLb.textColor = KDSRGBColor(51, 51, 51);
        self.triggerTipsLb.font = [UIFont systemFontOfSize:14];
        self.triggerTipsLb.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.triggerTipsLb];
        [self.triggerTipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(20);
            make.height.equalTo(@50);
            make.top.right.equalTo(self);
            
        }];
        self.line1 = [UIView new];
        self.line1.backgroundColor = KDSRGBColor(234, 233, 233);
        [self.contentView addSubview:self.line1];
        [self.line1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.triggerTipsLb.mas_bottom).offset(0);
            make.left.mas_equalTo(self.mas_left).offset(10);
            make.right.mas_equalTo(self.mas_right).offset(-5);
            make.height.equalTo(@1);
        }];
        self.timingIconImg = [UIImageView new];
        self.timingIconImg.image = [UIImage imageNamed:@"off-deviceTimingIcon"];
        [self.contentView addSubview:self.timingIconImg];
        [self.timingIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.line1.mas_bottom).offset(12);
            make.left.mas_equalTo(self.mas_left).offset(20);
            make.width.height.equalTo(@25);
        }];
        self.timingTipsLb = [UILabel new];
        self.timingTipsLb.text = @"定 时";
        self.timingTipsLb.textColor = KDSRGBColor(51, 51, 51);
        self.timingTipsLb.font = [UIFont systemFontOfSize:14];
        self.timingTipsLb.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.timingTipsLb];
        [self.timingTipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.timingIconImg.mas_right).offset(3);
            make.width.equalTo(@40);
            make.height.equalTo(@50);
            make.top.mas_equalTo(self.line1.mas_bottom).offset(0);
        }];
        self.rightArrowImg1 = [UIImageView new];
        self.rightArrowImg1.image = [UIImage imageNamed:@"rightArrow"];
        [self.contentView addSubview:self.rightArrowImg1];
        [self.rightArrowImg1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.line1.mas_bottom).offset(18);
            make.width.equalTo(@6);
            make.height.equalTo(@11);
            make.right.mas_equalTo(self.mas_right).offset(-15);
        }];
        self.timingLb = [UILabel new];
        self.timingLb.text = @"22:00-6:00    每天";
        self.timingLb.textColor = KDSRGBColor(51, 51, 51);
        self.timingLb.font = [UIFont systemFontOfSize:14];
        self.timingLb.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.timingLb];
        [self.timingLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.line1.mas_bottom).offset(0);
            make.height.equalTo(@50);
            make.left.mas_equalTo(self.timingTipsLb.mas_right).offset(5);
            make.right.mas_equalTo(self.rightArrowImg1.mas_left).offset(-10);
        }];
        self.line2 = [UIView new];
        self.line2.backgroundColor = KDSRGBColor(234, 233, 233);
        [self.contentView addSubview:self.line2];
        [self.line2 mas_makeConstraints:^(MASConstraintMaker *make) {
           make.top.mas_equalTo(self.timingLb.mas_bottom).offset(0);
           make.left.mas_equalTo(self.mas_left).offset(10);
           make.right.mas_equalTo(self.mas_right).offset(-5);
           make.height.equalTo(@1);
        }];
        self.deviceTipsImg = [UIImageView new];
        self.deviceTipsImg.image = [UIImage imageNamed:@"danPTimingIconImg"];
        [self.contentView addSubview:self.deviceTipsImg];
        [self.deviceTipsImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.line2.mas_bottom).offset(12);
            make.left.mas_equalTo(self.mas_left).offset(20);
            make.width.height.equalTo(@25);
        }];
        
        self.rightArrowImg2 = [UIImageView new];
        self.rightArrowImg2.image = [UIImage imageNamed:@"rightArrow"];
        [self.contentView addSubview:self.rightArrowImg2];
        [self.rightArrowImg2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.line2.mas_bottom).offset(18);
            make.width.equalTo(@6);
            make.height.equalTo(@11);
            make.right.mas_equalTo(self.mas_right).offset(-15);
                   
            }];
        
        self.deviceStateLb = [UILabel new];
        self.deviceStateLb.text = @"开启";
        self.deviceStateLb.textColor = KDSRGBColor(51, 51, 51);
        self.deviceStateLb.textAlignment = NSTextAlignmentRight;
        self.deviceStateLb.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.deviceStateLb];
        [self.deviceStateLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.line2.mas_bottom).offset(0);
            make.height.equalTo(@50);
            make.right.mas_equalTo(self.rightArrowImg2.mas_left).offset(-10);
            make.width.equalTo(@40);
        }];
        
        self.deviceNameLb = [UILabel new];
        self.deviceNameLb.text = @"智能门锁";
        self.deviceNameLb.textColor = KDSRGBColor(51, 51, 51);
        self.deviceNameLb.font = [UIFont systemFontOfSize:14];
        self.deviceNameLb.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.deviceNameLb];
        [self.deviceNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.deviceTipsImg.mas_right).offset(3);
            make.right.mas_equalTo(self.deviceStateLb.mas_left).offset(-10);
            make.height.equalTo(@50);
            make.top.mas_equalTo(self.line2.mas_bottom).offset(0);
        }];
    
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setFrame:(CGRect)frame
{
    frame.origin.y += 10;
    frame.size.height -= 10;
    [super setFrame:frame];
}

@end
