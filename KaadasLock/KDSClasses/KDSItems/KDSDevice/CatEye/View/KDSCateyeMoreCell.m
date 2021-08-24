//
//  KDSCateyeMoreCell.m
//  KaadasLock
//
//  Created by zhaona on 2019/5/9.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSCateyeMoreCell.h"

@interface KDSCateyeMoreCell ()
///底部分割线。
@property (nonatomic, strong) UIView *separatorView;

@end

@implementation KDSCateyeMoreCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.clearColor;
        [self addMySubView];
        [self addMakeConstraints];
    }
    return self;
}
-(void)addMySubView
{
    [self.contentView addSubview:self.titleNameLb];
    [self.contentView addSubview:self.selectBtn];
    [self.contentView addSubview:self.separatorView];
}
-(void)addMakeConstraints{
    
    [self.selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(22);
        make.centerY.mas_equalTo(self.mas_centerY).offset(0);
        make.right.mas_equalTo(self.mas_right).offset(-17);
    }];
    
    [self.titleNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(17);
        make.height.mas_equalTo(15);
        make.right.mas_equalTo(self.selectBtn.mas_left).offset(-20);
        make.centerY.mas_equalTo(self.mas_centerY).offset(0);
    
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
    return @"KDSCateyeMoreCell";
}


@end
