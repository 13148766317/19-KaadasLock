//
//  KDSGWMenaceCell.m
//  KaadasLock
//
//  Created by orange on 2019/4/29.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSGWMenaceCell.h"

@interface KDSGWMenaceCell ()

///名称标签。
@property (nonatomic, strong) UILabel *nameLabel;
///右箭头。
@property (nonatomic, weak) UIImageView *arrowIV;
///分隔线。
@property (nonatomic, strong) UIView *separator;

@end

@implementation KDSGWMenaceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.whiteColor;
        
        self.nameLabel = [UILabel new];
        self.nameLabel.font = [UIFont systemFontOfSize:17];
        self.nameLabel.textColor = KDSRGBColor(0x33, 0x33, 0x33);
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self).offset(38);
        }];
        
        UIImage *arrow = [UIImage imageNamed:@"rightArrow"];
        UIImageView *iv = [[UIImageView alloc] initWithImage:arrow];
        iv.hidden = YES;
        [self.contentView addSubview:iv];
        [iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-15);
            make.centerY.equalTo(@0);
            make.size.mas_equalTo(arrow.size);
        }];
        self.arrowIV = iv;
        
        self.separator = [UIView new];
        self.separator.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
        [self.contentView addSubview:self.separator];
        [self.separator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self);
            make.height.equalTo(@1);
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

- (void)setName:(NSString *)name
{
    _name = name;
    self.nameLabel.text = name;
    self.arrowIV.hidden = !name.length;
}

- (void)setHideSeparator:(BOOL)hideSeparator
{
    _hideSeparator = hideSeparator;
    self.separator.hidden = hideSeparator;
}

@end
