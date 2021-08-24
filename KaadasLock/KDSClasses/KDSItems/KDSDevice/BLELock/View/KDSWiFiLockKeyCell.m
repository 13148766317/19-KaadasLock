//
//  KDSWiFiLockKeyCell.m
//  KaadasLock
//
//  Created by zhaona on 2020/5/29.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSWiFiLockKeyCell.h"

@interface KDSWiFiLockKeyCell ()

///序号标签+名称标签。
@property (nonatomic, strong) UILabel *numLabel;
///权限描述标签。
@property (nonatomic, strong) UILabel *jurisdictionLabel;
///分隔线。
@property (nonatomic, strong) UIView *separatorView;
///箭头
@property (nonatomic, weak) UIImageView *arrowIV;

@end

@implementation KDSWiFiLockKeyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.whiteColor;
        
        self.numLabel = [UILabel new];
        self.numLabel.textColor = KDSRGBColor(0x33, 0x33, 0x33);
        self.numLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:self.numLabel];
        [self.numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.left.equalTo(self).offset(16);
        }];
        
        UIImage *arrow = [UIImage imageNamed:@"rightArrow"];
        UIImageView *iv = [[UIImageView alloc] initWithImage:arrow];
        self.arrowIV = iv;
        [self.contentView addSubview:iv];
        [iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-16);
            make.centerY.equalTo(@0);
            make.size.mas_equalTo(arrow.size);
        }];
        
        self.jurisdictionLabel = [UILabel new];
        self.jurisdictionLabel.textAlignment = NSTextAlignmentRight;
        self.jurisdictionLabel.textColor = KDSRGBColor(0x99, 0x99, 0x99);
        self.jurisdictionLabel.font = [UIFont systemFontOfSize:12];
        self.jurisdictionLabel.numberOfLines = 0;
        [self.contentView addSubview:self.jurisdictionLabel];
        [self.jurisdictionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.right.equalTo(self).offset(-33);
            make.left.equalTo(self.numLabel.mas_right).offset(15);
        }];
        
        self.separatorView = [UIView new];
        self.separatorView.backgroundColor = KDSRGBColor(0xea, 0xe9, 0xe9);
        [self.contentView addSubview:self.separatorView];
        [self.separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.numLabel);
            make.bottom.equalTo(self);
            make.right.equalTo(iv);
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

///根据文字更新权限描述和名称标签的宽度约束。font参数外面调用时传nil。
- (void)updateLabelWidthConstraintWithJurisdictionFont:(nullable UIFont *)font
{
    //改变布局后要修改这里的值。V:[-46-15-33-]，如果默认字体权限描述+名称不够显示，缩小1号权限描述字体。
    //当数据量大了后频繁计算字宽(快速滑动时)会有卡顿，100个cell内应该不是很明显。
    if (!self.name || !self.jurisdiction) return;
    CGFloat spaces = 46 + 15 + 33;
    UIFont *defaultFont = font ?: [UIFont systemFontOfSize:12];
    CGFloat nWidth = ceil([self.name sizeWithAttributes:@{NSFontAttributeName : self.numLabel.font}].width);
    CGFloat jWidth = ceil([self.jurisdiction sizeWithAttributes:@{NSFontAttributeName : defaultFont}].width);
    if (nWidth + jWidth + spaces > kScreenWidth)
    {
        if (!font)
        {
            [self updateLabelWidthConstraintWithJurisdictionFont:[UIFont systemFontOfSize:11]];
            return;
        }
        if (jWidth > (kScreenWidth - spaces) * 0.8)
        {
            nWidth = (kScreenWidth - spaces) * 0.2;
        }
        else
        {
            nWidth = kScreenWidth - spaces - jWidth;
        }
    }
    self.jurisdictionLabel.font = defaultFont;
    [self.numLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(nWidth));
    }];
}

- (void)setName:(NSString *)name
{
    _name = name;
    self.numLabel.text = name;
    [self updateLabelWidthConstraintWithJurisdictionFont:nil];
}

- (void)setJurisdiction:(NSString *)jurisdiction
{
    _jurisdiction = jurisdiction;
    self.jurisdictionLabel.text = jurisdiction;
    [self updateLabelWidthConstraintWithJurisdictionFont:nil];
}

- (void)setHideSeparator:(BOOL)hideSeparator
{
    _hideSeparator = hideSeparator;
    self.separatorView.hidden = hideSeparator;
}

- (void)setHideArrow:(BOOL)hideArrow
{
    _hideArrow = hideArrow;
    self.arrowIV.hidden = hideArrow;
}


@end
