//
//  KDSMediaSettingCell.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/17.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSMediaSettingCell.h"

@interface KDSMediaSettingCell ()

///标题标签。
@property (nonatomic, strong) UILabel *titleLabel;
///子标题标签。
@property (nonatomic, strong) UILabel *subtitleLabel;
///用来说明选择的标签。
@property (nonatomic, strong) UILabel *explainLabel;
///switch
@property (nonatomic, strong) UISwitch *switchControl;
///右边箭头。
@property (nonatomic, strong) UIImageView *arrowIV;
///底部分割线。
@property (nonatomic, strong) UIView *separatorView;
///上圆角阴影。
@property (nonatomic, strong) CAShapeLayer *topLayer;
///下圆角阴影。
@property (nonatomic, strong) CAShapeLayer *bottomLayer;

@end


@implementation KDSMediaSettingCell

#pragma mark - 懒加载。
- (CAShapeLayer *)topLayer
{
    if (!_topLayer)
    {
        _topLayer = [CAShapeLayer layer];
    }
    return _topLayer;
}

- (CAShapeLayer *)bottomLayer
{
    if (!_bottomLayer)
    {
        _bottomLayer = [CAShapeLayer layer];
    }
    return _bottomLayer;
}

#pragma mark - 初始化等重载的父类方法。
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _hideSwitch = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.clearColor;
        
        self.containerView = [[UIView alloc] init];
        self.containerView.backgroundColor = UIColor.whiteColor;
        [self.contentView addSubview:self.containerView];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.equalTo(self);
        }];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textColor = KDSRGBColor(0x33, 0x33, 0x33);
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.containerView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.containerView.mas_top).offset(10);
            make.height.equalTo(@20);
            make.left.equalTo(self.containerView).offset(15);

        }];
        self.explainLabel = [[UILabel alloc] init];
        self.explainLabel.textColor = KDSRGBColor(154, 154, 154);
        self.explainLabel.numberOfLines = 0;
        self.explainLabel.font = [UIFont systemFontOfSize:16];
        self.explainLabel.adjustsFontSizeToFitWidth = YES;
        [self.containerView addSubview:self.explainLabel];
        [self.explainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
            make.bottom.equalTo(self.containerView.mas_bottom).offset(-10);
            make.left.equalTo(self.containerView).offset(15);
            make.right.equalTo(self.contentView).offset(-50);
        }];
        
        
        UIImage *arrow = [UIImage imageNamed:@"箭头Hight"];
        self.arrowIV = [[UIImageView alloc] initWithImage:arrow];
        self.arrowIV.contentMode = UIViewContentModeScaleAspectFit;
        [self.containerView addSubview:self.arrowIV];
        [self.arrowIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.containerView);
            make.right.equalTo(self.containerView).offset(-15);
            make.size.mas_equalTo(arrow.size);
        }];
        
        self.subtitleLabel = [[UILabel alloc] init];
        self.subtitleLabel.textColor = KDSRGBColor(0x99, 0x99, 0x99);
        self.subtitleLabel.font = [UIFont systemFontOfSize:12];
        self.subtitleLabel.textAlignment = NSTextAlignmentRight;
        [self.containerView addSubview:self.subtitleLabel];
        [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.containerView);
            make.left.equalTo(self.titleLabel.mas_left).offset(100);
            make.right.equalTo(self.arrowIV.mas_left).offset(-15);
        }];
        
        self.switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 26, 15)];
        self.switchControl.onTintColor = KDSRGBColor(69, 150, 240);
        CGFloat width = self.switchControl.bounds.size.width;
        self.switchControl.transform = CGAffineTransformMakeScale(sqrt(0.5), sqrt(0.5));
        [self.switchControl addTarget:self action:@selector(switchXmStateDidChange:) forControlEvents:UIControlEventValueChanged];
        self.switchControl.hidden = YES;
        [self.containerView addSubview:self.switchControl];
        [self.switchControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.containerView);
            make.right.equalTo(self.containerView).offset(-(13 - (width * (1 - sqrt(0.5))) / 2));
        }];
        
        self.separatorView = [UIView new];
        self.separatorView.backgroundColor = KDSRGBColor(0xea, 0xea, 0xe9);
        [self.containerView addSubview:self.separatorView];
        [self.separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.containerView).offset(17);
            make.bottom.right.equalTo(self.containerView);
            make.height.mas_equalTo(1);
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

#pragma mark - setter
- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle
{
    _subtitle = subtitle;
    self.subtitleLabel.text = subtitle;
}

- (void)setExplain:(NSString *)explain
{
    _explain = explain;
    self.explainLabel.text = explain;
}

- (void)setHideSwitch:(BOOL)hideSwitch
{
    _hideSwitch = hideSwitch;
    self.switchControl.hidden = hideSwitch;
    self.subtitleLabel.hidden = self.arrowIV.hidden = !hideSwitch;
}
- (void)setSwitchOn:(BOOL)switchOn
{
    if (!self.switchControl.hidden)
    {
        _switchOn = switchOn;
        self.switchControl.on = switchOn;
    }
}

- (void)setSwitchEnable:(BOOL)switchEnable
{
    if (!self.switchControl.hidden)
    {
        _switchEnable = switchEnable;
        self.switchControl.enabled = switchEnable;
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
    [self.arrowIV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(hideArrow ? self.arrowIV.image.size.width : -15);
    }];

}

#pragma mark - 控件等事件。
///选择开关状态改变执行。
- (void)switchXmStateDidChange:(UISwitch *)sender
{
    !self.switchXMStateDidChangeBlock ?: self.switchXMStateDidChangeBlock(sender);
}

@end
