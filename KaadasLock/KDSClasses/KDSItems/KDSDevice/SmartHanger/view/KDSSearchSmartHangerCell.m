//
//  KDSSearchSmartHangerCell.m
//  KaadasLock
//
//  Created by Frank Hu on 2021/1/7.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSSearchSmartHangerCell.h"

@implementation KDSSearchSmartHangerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.textColor = KDSRGBColor(0x33, 0x33, 0x33);
        self.nameLabel.font = [UIFont systemFontOfSize:15];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bindBtnDidClickAction:)];
        [self.nameLabel addGestureRecognizer:tapGesture];
        self.nameLabel.userInteractionEnabled = YES;
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.right.equalTo(self).offset(23);
            make.left.equalTo(self).offset(23);
        }];
        
        self.underlineView = [[UIView alloc] init];
        self.underlineView.backgroundColor = KDSRGBColor(0xea, 0xe9, 0xe9);
        [self.contentView addSubview:self.underlineView];
        [self.underlineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self);
            make.height.mas_equalTo(1);
        }];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setBleName:(NSString *)bleName
{
    _bleName = bleName;
    self.nameLabel.text = bleName;
}

- (void)setHasBinded:(BOOL)hasBinded
{
    _hasBinded = hasBinded;
//    self.bindBtn.enabled = !hasBinded;
}

- (void)setUnderlineHidden:(BOOL)underlineHidden
{
    _underlineHidden = underlineHidden;
    self.underlineView.hidden = underlineHidden;
}

- (void)bindBtnDidClickAction:(UIButton *)sender
{
    !self.bindBtnDidClickBlock ?: self.bindBtnDidClickBlock(sender);
}

@end
