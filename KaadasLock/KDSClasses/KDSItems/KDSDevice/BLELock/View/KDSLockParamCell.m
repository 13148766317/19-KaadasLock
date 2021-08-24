//
//  KDSLockParamCell.m
//  KaadasLock
//
//  Created by orange on 2019/4/9.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSLockParamCell.h"

@interface KDSLockParamCell ()

///参数标题标签。
@property (nonatomic, strong) UILabel *titleLabel;
///参数内容标签。
@property (nonatomic, strong) UILabel *contentLabel;
///分隔线。
@property (nonatomic, strong) UIView *separatorView;
///右边箭头。
@property (nonatomic, strong) UIImageView *arrowIV;

@end

@implementation KDSLockParamCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.titleLabel = [UILabel new];
        self.titleLabel.textColor = KDSRGBColor(0x33, 0x33, 0x33);
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.left.equalTo(self).offset(15);
        }];
        
        self.contentLabel = [UILabel new];
        self.contentLabel.textAlignment = NSTextAlignmentRight;
        self.contentLabel.textColor = KDSRGBColor(0x99, 0x99, 0x99);
        self.contentLabel.font = [UIFont systemFontOfSize:12];
//        self.contentLabel.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:self.contentLabel];
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.left.equalTo(self.titleLabel).offset(50);
            make.right.equalTo(self).offset(-30);
        }];
        
        UIImage *arrow = [UIImage imageNamed:@"箭头Hight"];
        self.arrowIV = [[UIImageView alloc] initWithImage:arrow];
        self.arrowIV.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.arrowIV];
        [self.arrowIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-15);
            make.size.mas_equalTo(arrow.size);
        }];
        
        self.separatorView = [UIView new];
        self.separatorView.backgroundColor = KDSRGBColor(0xea, 0xe9, 0xe9);
        [self.contentView addSubview:self.separatorView];
        [self.separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(17);
            make.bottom.right.equalTo(self);
            make.height.equalTo(@1);
        }];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
#pragma mark - setter

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
    if ([self.title isEqualToString:Localized(@"deviceName")]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.right.equalTo(self).offset(-40);
        }];
    }else{
        self.accessoryType = UITableViewCellAccessoryNone;
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.left.equalTo(self.titleLabel).offset(50);
            make.right.equalTo(self).offset(-15);
        }];
    }
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
