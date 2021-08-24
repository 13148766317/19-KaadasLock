//
//  KDSMyMessageinfoStyleTwoCell.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/2.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSMyMessageinfoStyleTwoCell.h"

@interface KDSMyMessageinfoStyleTwoCell ()
///图标
@property(nonatomic,readwrite,strong)UIImageView * icoImg;

@end

@implementation KDSMyMessageinfoStyleTwoCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.icoImg];
        [self.contentView addSubview:self.timeLabel];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self makeMyConstrains];
    }
    
    return self;
}
-(void)makeMyConstrains
{
    ///消息最左边的图标
    [self.icoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(27);
        make.height.mas_equalTo(33);
        make.left.mas_equalTo(self.mas_left).offset(28);
        make.centerY.mas_equalTo(self.mas_centerY).offset(0);
    }];
    ///消息发布时间
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-15);
        make.width.mas_equalTo(75);
        make.height.mas_equalTo(10);
        make.centerY.mas_equalTo(self.mas_centerY).offset(0);
        
    }];
    ///主标题
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.left.mas_equalTo(self.icoImg.mas_right).offset(40);
        make.right.mas_equalTo(self.timeLabel.mas_left).offset(-20);
        make.centerY.mas_equalTo(self.mas_centerY).offset(0);
    }];
 
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setFrame:(CGRect)frame{
    frame.origin.y += 10;
    frame.size.height -= 10;
    [super setFrame:frame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark --Lazy load

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = ({
            UILabel * titleLb = [UILabel new];
            titleLb.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
            titleLb.textAlignment = NSTextAlignmentLeft;
            titleLb.textColor = KDSRGBColor(51, 51, 51);
            titleLb.text = @"授权用户 壮壮家的门锁";
            titleLb;
        });
    }
    return _titleLabel;
}


-(UIImageView *)icoImg
{
    if (!_icoImg) {
        _icoImg = ({
            UIImageView * icoImgView = [UIImageView new];
            icoImgView.image = [UIImage imageNamed:@"授权"];
            icoImgView;
        });
    }
    return _icoImg;
}
-(UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = ({
            UILabel * tLb = [UILabel new];
            tLb.font = [UIFont fontWithName:@"PingFang-SC-Medium" size:12];
            tLb.textAlignment = NSTextAlignmentRight;
            tLb.textColor = KDSRGBColor(142, 142, 147);
            tLb.backgroundColor = UIColor.clearColor;
            tLb.text = @"02-19 12:30";
            tLb;
        });
    }
    
    return _timeLabel;
}
//-(UILabel *)detailLabel
//{
//    if (!_detailLabel) {
//        _detailLabel = ({
//            UILabel * detailLb = [UILabel new];
//            detailLb.font = [UIFont systemFontOfSize:12];
//            detailLb.textAlignment = NSTextAlignmentLeft;
//            detailLb.textColor = KDSRGBColor(142, 142, 147);
//            detailLb.text = @"元宵节钜惠优惠专场活动火爆进行中，欢迎广大...";
//            detailLb;
//            
//        });
//    }
//    return _detailLabel;
//}

@end
