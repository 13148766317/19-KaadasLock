//
//  KDSSysMsgDetailsCell.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/2.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSSysMsgDetailsCell.h"

@interface KDSSysMsgDetailsCell ()

///日期标签。
@property (nonatomic, strong) UILabel *dateLabel;
///圆角视图。
@property (nonatomic, strong) UIView *cornerView;
///标题标签。
@property (nonatomic, strong) UILabel *titleLabel;
///内容标签。
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation KDSSysMsgDetailsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.clearColor;
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = KDSRGBColor(0x2b, 0x2f, 0x50);
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        self.titleLabel.numberOfLines = 0;
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(20);
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self).offset(-15);
            make.height.mas_lessThanOrEqualTo(20);
        }];
        
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.textAlignment = NSTextAlignmentCenter;
        self.dateLabel.textColor = KDSRGBColor(0xc2, 0xc2, 0xc2);
        self.dateLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.dateLabel];
        [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(8);
            make.left.right.equalTo(self);
            make.height.mas_equalTo(15);
        }];
        
        self.cornerView = [[UIView alloc] init];
        self.cornerView.backgroundColor = UIColor.whiteColor;
        self.cornerView.layer.cornerRadius = 5;
        [self.contentView addSubview:self.cornerView];
        [self.cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self);
            make.top.mas_equalTo(self.dateLabel.mas_bottom).offset(12);
        }];
        
        self.contentLabel = [[UILabel alloc] init];
        self.contentLabel.textColor = KDSRGBColor(0x95, 0x95, 0x95);
        self.contentLabel.font = [UIFont systemFontOfSize:13];
        self.contentLabel.numberOfLines = 0;
        [self.contentView addSubview:self.contentLabel];
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.topMargin.equalTo(self.cornerView).offset(17.5);
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self).offset(-15);
            make.bottom.equalTo(self).offset(-17.5);
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

- (void)setDate:(NSString *)date
{
    _date = date;
    self.dateLabel.text = date;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

- (void)setContent:(NSString *)content
{
    _content = content;
    self.contentLabel.text = content;
}

@end
