//
//  KDSAddDeviceCell.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/24.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSAddDeviceCell.h"

@interface KDSAddDeviceCell ()


///”添加“两个字
@property (nonatomic,readwrite,strong)UILabel *addwordsLabel;

@end

@implementation KDSAddDeviceCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        [self.contentView addSubview:self.deviceTypeIconImg];
        [self.contentView addSubview:self.deviceTypeNameLabel];
        [self.contentView addSubview:self.detailLabel];
        [self.contentView addSubview:self.addwordsLabel];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        self.contentView.backgroundColor = UIColor.whiteColor;
        self.contentView.layer.cornerRadius = 4;
        self.contentView.clipsToBounds = YES;
        [self makeMyConstrains];
    }
    return self;
}
-(void)makeMyConstrains
{
    [self.deviceTypeIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.height.mas_equalTo(37);
        make.left.mas_equalTo(self.mas_left).offset(22);
        make.centerY.mas_equalTo(self.mas_centerY).offset(0);
    }];
    [self.addwordsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.bottom.right.mas_equalTo(0);
        make.width.mas_equalTo(69);
        
    }];
    [self.deviceTypeNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.deviceTypeIconImg.mas_right).offset(40);
        make.height.mas_equalTo(20);
        make.top.mas_equalTo(self.mas_top).offset(33);
        make.right.mas_equalTo(self.addwordsLabel.mas_right).offset(-20);
    }];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.deviceTypeIconImg.mas_right).offset(40);
        make.height.mas_equalTo(17);
        make.top.mas_equalTo(self.deviceTypeNameLabel.mas_bottom).offset(7);
        make.right.mas_equalTo(self.addwordsLabel.mas_right).offset(-20);
    }];
}

- (void)setFrame:(CGRect)frame{
    frame.origin.x += 15;
    frame.origin.y += 11;
    frame.size.height -= 11;
    frame.size.width -= 30;
    [super setFrame:frame];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)ID{
    return @"KDSAddDeviceCell";
}

#pragma mark --Lazy load

- (UIImageView *)deviceTypeIconImg
{
    if (!_deviceTypeIconImg) {
        _deviceTypeIconImg = ({
            UIImageView * img = [UIImageView new];
            img.backgroundColor = UIColor.clearColor;
            img.image = [UIImage imageNamed:@"addDeviceZb"];
            img;
        });
    }
    
    return _deviceTypeIconImg;
}

- (UILabel *)deviceTypeNameLabel
{
    if (!_deviceTypeNameLabel) {
        _deviceTypeNameLabel = ({
            UILabel * Lb = [UILabel new];
            Lb.font = [UIFont fontWithName:@"PingFang-SC-Heavy" size:15];
            Lb.textColor = KDSRGBColor(0, 0, 0);
            Lb.textAlignment = NSTextAlignmentLeft;
            Lb;
        });
    }
    return _deviceTypeNameLabel;
}
- (UILabel *)detailLabel
{
    if (!_detailLabel) {
        _detailLabel = ({
            UILabel * deLb = [UILabel new];
            deLb.textColor = KDSRGBColor(102, 102, 102);
            deLb.font = [UIFont systemFontOfSize:11];
            deLb.textAlignment = NSTextAlignmentLeft;
            deLb;
        });
    }
    return _detailLabel;
}
- (UILabel *)addwordsLabel
{
    if (!_addwordsLabel) {
        _addwordsLabel = ({
            UILabel * addWLb = [UILabel new];
            addWLb.textColor = KDSRGBColor(255, 255, 255);
            addWLb.font = [UIFont systemFontOfSize:13];
            addWLb.textAlignment = NSTextAlignmentCenter;
            addWLb.backgroundColor = KDSRGBColor(96, 180, 249);
            addWLb.text = Localized(@"add");
           
            addWLb;
        });
    }
    return _addwordsLabel;
}

@end
