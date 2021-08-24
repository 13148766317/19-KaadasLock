//
//  KDSLockMoreSettingCell.m
//  xiaokaizhineng
//
//  Created by orange on 2019/2/14.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSLockMoreSettingCell.h"
#import "Masonry.h"

@interface KDSLockMoreSettingCell ()

///标题标签。
@property (nonatomic, strong) UILabel *titleLabel;
///子标题标签。
@property (nonatomic, strong) UILabel *subtitleLabel;
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

@implementation KDSLockMoreSettingCell

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
        self.cornerState = KDSCornerStateNone;
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
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        [self.containerView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.containerView);
            make.left.equalTo(self.containerView).offset(15);

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
        [self.switchControl addTarget:self action:@selector(switchStateDidChange:) forControlEvents:UIControlEventValueChanged];
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

- (void)layoutSubviews
{
    ///FIXME:圆角大小改变需要修改这里
    /*CGFloat radius = 5;
    UIBezierPath *path1 = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(radius, radius)];
    self.topLayer.path = path1.CGPath;
    
    UIBezierPath *path2 = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(radius, radius)];
    self.bottomLayer.path = path2.CGPath;*/
}

#pragma mark - setter
//  设置标题
- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}
// 设置子标题
- (void)setSubtitle:(NSString *)subtitle
{
    _subtitle = subtitle;
    self.subtitleLabel.text = subtitle;
}
//  隐藏开关
- (void)setHideSwitch:(BOOL)hideSwitch
{
    _hideSwitch = hideSwitch;
    self.switchControl.hidden = hideSwitch;
    self.subtitleLabel.hidden = self.arrowIV.hidden = !hideSwitch;
}
// 打开开关
- (void)setSwitchOn:(BOOL)switchOn
{
    if (!self.switchControl.hidden)
    {
        _switchOn = switchOn;
        self.switchControl.on = switchOn;
    }
}
//  开关不能点击
- (void)setSwitchEnable:(BOOL)switchEnable
{
    if (!self.switchControl.hidden)
    {
        _switchEnable = switchEnable;
        self.switchControl.enabled = switchEnable;
    }
}
//   设置分割线
- (void)setHideSeparator:(BOOL)hideSeparator
{
    _hideSeparator = hideSeparator;
    self.separatorView.hidden = hideSeparator;
}

- (void)setCornerState:(KDSCornerState)cornerState
{
    _cornerState = cornerState;
    if (cornerState == KDSCornerStateNone)
    {
        self.containerView.layer.mask = nil;
    }
    else if (cornerState == KDSCornerStateTop)
    {
        self.containerView.layer.mask = self.topLayer;
    }
    else
    {
        self.containerView.layer.mask = self.bottomLayer;
    }
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
- (void)switchStateDidChange:(UISwitch *)sender
{
    // 开关选中的回调
    !self.switchStateDidChangeBlock ?: self.switchStateDidChangeBlock(sender);
}

@end
