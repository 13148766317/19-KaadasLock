//
//  KDSSafeStateCell.m
//  KaadasLock
//
//  Created by zhaoxueping on 2021/6/28.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSSafeStateCell.h"


@interface KDSSafeStateCell ()

/************cell组成：图标1 文案1+图标2 文案2******************/
///第一个图标
@property (nonatomic,strong)UIImageView * leftIV;
///第一个文案
@property (nonatomic, strong)UILabel * leftLb;
///第二个图标
@property (nonatomic,strong)UIImageView * rightIV;
////第二个文案
@property (nonatomic, strong)UILabel * rightLabel;

@end

@implementation KDSSafeStateCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.leftIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"password"]];
        self.leftIV.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.leftIV];
        [self.leftIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(23);
            make.centerY.equalTo(@0);
            make.width.height.equalTo(@20);
        }];
        
        UIColor *color = KDSRGBColor(0x33, 0x33, 0x33);
        UIFont *font = [UIFont systemFontOfSize:13];
        self.leftLb = [self createLabelWithText:Localized(@"PIN") color:color font:font];
        [self addSubview:self.leftLb];
        [self.leftLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.leftIV.mas_right).offset(15);
            make.centerY.equalTo(@0);
            make.size.mas_equalTo(self.leftLb.bounds.size);
        }];
        
        UILabel *centerLabel = [self createLabelWithText:@"+" color:color font:font];
        [self addSubview:centerLabel];
        [centerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.leftLb.mas_right).offset(19);
            make.centerY.equalTo(@0);
            make.size.mas_equalTo(centerLabel.bounds.size);
        }];
        
        self.rightIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fingerprint"]];
        self.rightIV.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.rightIV];
        [self.rightIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(centerLabel.mas_right).offset(19);
            make.centerY.equalTo(@0);
            make.width.height.equalTo(@20);
        }];
        
        self.rightLabel = [self createLabelWithText:Localized(@"fingerprint") color:color font:font];
        [self addSubview:self.rightLabel];
        [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.rightIV.mas_right).offset(15);
            make.centerY.equalTo(@0);
            make.size.mas_equalTo(self.rightLabel.bounds.size);
        }];
    }
    
    return self;
}

///根据内容创建一个提示内容标签，创建的标签已设置bounds。
- (UILabel *)createLabelWithText:(NSString *)text color:(UIColor *)color font:(UIFont *)font
{
    UILabel *label = [UILabel new];
    label.text = text;
    label.textColor = color;
    label.font = font;
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName : font}];
    label.bounds = CGRectMake(0, 0, ceil(size.width), ceil(size.height));
    return label;
}

- (void)setDict:(NSDictionary *)dict
{
    if (dict) {
        self.leftIV.image = [UIImage imageNamed:dict[@"leftIV"]];
        self.leftLb.text = dict[@"leftLabel"];
        self.rightIV.image = [UIImage imageNamed:dict[@"rightIV"]];
        self.rightLabel.text = dict[@"rightLabel"];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
