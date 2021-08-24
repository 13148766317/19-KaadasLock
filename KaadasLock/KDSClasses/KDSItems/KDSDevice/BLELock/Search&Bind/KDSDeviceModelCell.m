//
//  KDSDeviceModelCell.m
//  xiaokaizhineng
//
//  Created by orange on 2019/2/12.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSDeviceModelCell.h"
#import "Masonry.h"

@interface KDSDeviceModelCell ()

///容器
@property (nonatomic, strong) UIView *containerView;
///+号图片
@property (nonatomic, strong) UIImageView *plusIV;
///锁型号标题。
@property (nonatomic, strong) UILabel *modelLabel;
///锁型号图片。
@property (nonatomic, strong) UIImageView *modelIV;

@end

@implementation KDSDeviceModelCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = KDSRGBColor(0xee, 0xee, 0xee);
        
        self.containerView = [[UIView alloc] init];
        self.containerView.backgroundColor = UIColor.whiteColor;
        self.containerView.layer.cornerRadius = 5;
        [self.contentView addSubview:self.containerView];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.left.equalTo(self).offset(10);
            make.right.equalTo(self).offset(-10);
        }];
        
        self.plusIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"deviceAddModel"]];
        [self.containerView addSubview:self.plusIV];
        [self.plusIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.containerView);
            make.left.equalTo(self.containerView).offset(20);
            make.width.height.mas_equalTo(24);
        }];
        
        self.modelIV = [[UIImageView alloc] init];
        [self.containerView addSubview:self.modelIV];
        [self.modelIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.containerView);
            make.right.equalTo(self.containerView).offset(-20);
            make.width.height.mas_equalTo(110);
        }];
        
        self.modelLabel = [[UILabel alloc] init];
        self.modelLabel.textColor = KDSRGBColor(0x2b, 0x2f, 0x50);
        self.modelLabel.font = [UIFont systemFontOfSize:14];
        [self.containerView addSubview:self.modelLabel];
        [self.modelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.containerView);
            make.left.equalTo(self.plusIV.mas_right).offset(23);
            make.right.equalTo(self.modelIV.mas_left).offset(-20);
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

- (void)setModel:(KDSDeviceModel)model
{
    _model = model;
    switch (model) {
        case KDSDeviceModelT5:
            self.modelLabel.text = Localized(@"deviceModelT5");
            self.modelIV.image = [UIImage imageNamed:@"deviceModelT5"];
            break;
            
        case KDSDeviceModelX5:
            self.modelLabel.text = Localized(@"deviceModelX5");
            self.modelIV.image = [UIImage imageNamed:@"deviceModelX5"];
            break;
            
        default:
            break;
    }
}

@end
