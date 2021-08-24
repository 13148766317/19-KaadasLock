//
//  KDSDeviceTimingCell.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/14.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSDeviceTimingCell.h"

@interface KDSDeviceTimingCell ()

@property (nonatomic,strong)UIImageView * tipsIconImg;
///设备名称
@property (nonatomic,strong)UILabel * tipsNameLb;
///房间位置标签
@property (nonatomic,strong)UILabel * positionMarkLb;
///房间具体位置
@property (nonatomic,strong)UILabel * positionLb;
///零火开关状态的按钮
@property (nonatomic,strong)UIButton * powerStateBtn;

@end


@implementation KDSDeviceTimingCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
   self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = UIColor.whiteColor;
        self.tipsIconImg = [UIImageView new];
        self.tipsIconImg.image = [UIImage imageNamed:@"danPTimingIconImg"];
        [self.contentView addSubview:self.tipsIconImg];
        [self.tipsIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@25);
            make.left.mas_equalTo(self.mas_left).offset(15);
            make.top.mas_equalTo(self.mas_top).offset(6);
        }];
        self.powerStateBtn = [UIButton new];
        [self.powerStateBtn setBackgroundImage:[UIImage imageNamed:@"on-powerStatusIcon"] forState:UIControlStateNormal];
        [self.powerStateBtn setBackgroundImage:[UIImage imageNamed:@"off-powerStatusIcon"] forState:UIControlStateSelected];
        [self.powerStateBtn addTarget:self action:@selector(powerStateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.powerStateBtn];
        [self.powerStateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@37);
            make.height.equalTo(@18);
            make.top.mas_equalTo(self.mas_top).offset(9);
            make.right.mas_equalTo(self.mas_right).offset(-13);
        }];
        self.tipsNameLb = [UILabel new];
        self.tipsNameLb.text = @"单火开关";
        self.tipsNameLb.textColor = KDSRGBColor(51, 51, 51);
        self.tipsNameLb.font = [UIFont systemFontOfSize:13];
        self.tipsNameLb.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.tipsNameLb];
        [self.tipsNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(12);
            make.left.mas_equalTo(self.mas_left).offset(50);
            make.right.mas_equalTo(self.powerStateBtn.mas_left).offset(-20);
            make.height.equalTo(@15);
        }];
        self.positionMarkLb = [UILabel new];
        self.positionMarkLb.text = @"房间位置";
        self.positionMarkLb.textAlignment = NSTextAlignmentLeft;
        self.positionMarkLb.textColor = KDSRGBColor(51, 51, 51);
        self.positionMarkLb.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.positionMarkLb];
        [self.positionMarkLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(50);
            make.width.equalTo(@((KDSScreenWidth-65)/2));
            make.bottom.mas_equalTo(self.mas_bottom).offset(-10);
            make.height.equalTo(@15);
        }];
        self.positionLb = [UILabel new];
        self.positionLb.text = @"客厅";
        self.positionLb.textColor = KDSRGBColor(133, 133, 133);
        self.positionLb.font = [UIFont systemFontOfSize:12];
        self.positionLb.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.positionLb];
        [self.positionLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.mas_right).offset(-10);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-10);
            make.width.equalTo(@((KDSScreenWidth-65)/2));
            make.height.equalTo(@15);
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


#pragma mark 点击事件
-(void)powerStateBtnClick:(UIButton *)sender
{
    self.powerStateBtn.selected = !self.powerStateBtn.selected;
    !self.powerStateBtnDidChangeBlock ?: self.powerStateBtnDidChangeBlock(sender);
}

-(void)setFrame:(CGRect)frame
{
    frame.origin.y += 10;
    frame.size.height -= 10;
    [super setFrame:frame];
}

@end
