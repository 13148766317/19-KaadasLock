//
//  KDSCatEyeMoreSettingCellTableViewCell.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/16.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSCatEyeMoreSettingCellTableViewCell.h"
#import "CateyeSetModel.h"


@interface KDSCatEyeMoreSettingCellTableViewCell ()

@property (nonatomic,readwrite,strong)UILabel * deTitleLabel;
///标题：设备名称 铃声、响铃次数等
@property (nonatomic,readwrite,strong)UILabel * titleLabel;
@property (nonatomic,readwrite,strong)UIButton * monitoringBtn;

@end

@implementation KDSCatEyeMoreSettingCellTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self addMySubView];
        [self makeConstraints];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.whiteColor;
    }
    
    return self;
}

-(void)addMySubView
{
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.deTitleLabel];
    [self.contentView addSubview:self.rightArrowImg];
    [self.contentView addSubview:self.monitoringBtn];
}

-(void)makeConstraints
{
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(15);
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.contentView.mas_centerY).offset(0);
    }];
    [self.rightArrowImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@6.4);
        make.height.equalTo(@11.3);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-10);
        make.centerY.mas_equalTo(self.contentView.mas_centerY).offset(0);
        
    }];
    [self.deTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.rightArrowImg.mas_left).offset(-5);
        make.left.mas_equalTo(self.titleLabel.mas_right).offset(15);
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.contentView.mas_centerY).offset(0);
        
    }];
    [self.monitoringBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(37);
        make.height.mas_equalTo(20);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-15);
        make.centerY.mas_equalTo(self.contentView.mas_centerY).offset(0);
    }];
    
}

- (void)btnClick:(UIButton *)sender
{
    NSLog(@"开关被点击1");
    if (_delegate && [_delegate respondsToSelector:@selector(clickPirBtn:)]) {
        [_delegate clickPirBtn:sender];
    }
}

- (void)setModel:(CateyeSetModel *)model{
    _model = model;
    self.titleLabel.text = model.titleName;
    if (model.value) {
        self.deTitleLabel.hidden = NO;
        self.deTitleLabel.text = model.value;
        self.monitoringBtn.hidden = YES;
    }else{
        self.deTitleLabel.hidden = YES;
        self.monitoringBtn.hidden = YES;

    }
    if ([model.titleName isEqualToString:Localized(@"Doorbell PIR switch")]) {///智能监测
        self.rightArrowImg.hidden = YES;
        self.deTitleLabel.hidden = YES;
        self.monitoringBtn.hidden = NO;
        if ([model.value isEqualToString:@"1"]) {
            self.monitoringBtn.selected = YES;
        }else{
            self.monitoringBtn.selected = NO;
        }
    }else if ([model.titleName isEqualToString:@"SD卡"]){
        self.rightArrowImg.hidden = YES;
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

#pragma mark --Lazy load

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = ({
            UILabel * titleLb = [UILabel new];
            titleLb.font = [UIFont systemFontOfSize:13];
            titleLb.textColor = KDSRGBColor(51, 51, 51);
            titleLb.textAlignment = NSTextAlignmentLeft;
            titleLb;
        });
    }
    
    return _titleLabel;
}
- (UILabel *)deTitleLabel
{
    if (!_deTitleLabel) {
        _deTitleLabel = ({
            UILabel * deLb = [UILabel new];
            deLb.font = [UIFont systemFontOfSize:12];
            deLb.textColor = KDSRGBColor(153, 153, 153);
            deLb.textAlignment = NSTextAlignmentRight;
            deLb;
        });
    }
    return _deTitleLabel;
}

-(UIImageView *)rightArrowImg
{
    if (!_rightArrowImg) {
        _rightArrowImg = ({
            UIImageView * rImg = [UIImageView new];
            rImg.image = [UIImage imageNamed:@"rightArrow"];
            rImg.contentMode = UIViewContentModeScaleAspectFit;
            rImg;
        });
    }
    return _rightArrowImg;
}

- (UIButton *)monitoringBtn
{
    if (!_monitoringBtn) {
        _monitoringBtn = [UIButton new];
        [_monitoringBtn setBackgroundImage:[UIImage imageNamed:@"btnNormalImg"] forState:UIControlStateNormal];
        [_monitoringBtn setBackgroundImage:[UIImage imageNamed:@"btnSelecteImg"] forState:UIControlStateSelected];
        [_monitoringBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _monitoringBtn;
}

+ (NSString *)ID{
    return @"KDSCatEyeMoreSettingCellTableViewCell";
}

@end
