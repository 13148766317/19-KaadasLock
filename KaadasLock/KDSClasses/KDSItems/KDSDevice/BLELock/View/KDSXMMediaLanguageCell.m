//
//  KDSXMMediaLanguageCell.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/10/27.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSXMMediaLanguageCell.h"

@interface KDSXMMediaLanguageCell ()

///底部分割线。
@property (nonatomic, strong) UIView *separatorView;

@end

@implementation KDSXMMediaLanguageCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle =  UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.clearColor;
        [self addMySubView];
        [self addMakeConstraints];
        
    }
    return self;
}
-(void)addMySubView
{
    [self.contentView addSubview:self.languaImagIcon];
    [self.contentView addSubview:self.titleNameLb];
    [self.contentView addSubview:self.selectBtn];
    [self.contentView addSubview:self.separatorView];
}
-(void)addMakeConstraints{
    
    [self.languaImagIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(24);
        make.height.width.equalTo(@20);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self.selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@22);
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.mas_right).offset(-17);
    }];
    
    [self.titleNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.languaImagIcon.mas_right).offset(27);
        make.height.equalTo(@15);
        make.right.equalTo(self.selectBtn.mas_left).offset(-20);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self.separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(17);
        make.bottom.right.equalTo(self);
        make.height.mas_equalTo(1);
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

- (void)setHideSeparator:(BOOL)hideSeparator
{
    _hideSeparator = hideSeparator;
    self.separatorView.hidden = hideSeparator;
}

#pragma mark --Lazy load

- (UIImageView *)languaImagIcon
{
    if (!_languaImagIcon) {
        _languaImagIcon = [UIImageView new];
    }
    return _languaImagIcon;
}

- (UILabel *)titleNameLb
{
    if (!_titleNameLb) {
        _titleNameLb = ({
            UILabel * lb = [UILabel new];
            lb.font = [UIFont systemFontOfSize:15];
            lb.textColor = KDSRGBColor(51, 51, 51);
            lb.textAlignment = NSTextAlignmentLeft;
            lb;
        });
    }
    return _titleNameLb;
}

- (UIButton *)selectBtn
{
    if (!_selectBtn) {
        _selectBtn =({
            UIButton * btn = [UIButton new];
            [btn setImage:[UIImage imageNamed:@"unselected22x22"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"selected22x22"] forState:UIControlStateSelected];
            btn;
        });
    }
    return _selectBtn;
}

- (UIView *)separatorView
{
    if (!_separatorView) {
        _separatorView = [UIView new];
        _separatorView.backgroundColor = KDSRGBColor(0xea, 0xea, 0xe9);
    }
    return _separatorView;
}

+(NSString *)ID
{
    return @"KDSXMMediaLanguageCell";
}

@end
