//
//  CateyePIRSilenceCell.m
//  lock
//
//  Created by zhaona on 2019/4/23.
//  Copyright © 2019 zhao. All rights reserved.
//

#import "CateyePIRSilenceCell.h"

@interface CateyePIRSilenceCell ()

///描述标签：监控pir周期、周期内触发次数、持续时长、静默单位时长
@property(nonatomic,readwrite,strong)UILabel * titleLabel;


@end


@implementation CateyePIRSilenceCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        [self addContentSubView];
        
    }
    return self;
}

-(void)addContentSubView
{
    self.titleLabel = [UILabel new];
    self.titleLabel.textColor = UIColor.blackColor;
    self.titleLabel.font = [UIFont systemFontOfSize:13];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).mas_equalTo(20);
        make.height.mas_equalTo(30);
        make.centerY.mas_equalTo(self.mas_centerY).mas_equalTo(0);
//        make.width.mas_equalTo(100);
    }];
    
    
    self.contentTf = [[UITextField alloc] init];
    self.contentTf.borderStyle = UITextBorderStyleNone;
    self.contentTf.backgroundColor = UIColor.clearColor;
    self.contentTf.textColor = KDSRGBColor(153, 153, 153);
    self.contentTf.keyboardType = UIKeyboardTypeNumberPad;
    self.contentTf.font = [UIFont systemFontOfSize:13];
    self.contentTf.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.contentTf];
    [self.contentTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.textLabel.mas_right).mas_equalTo(20);
        make.right.mas_equalTo(self.mas_right).mas_equalTo(-35);
        make.height.mas_equalTo(30);
        make.centerY.mas_equalTo(self.mas_centerY).mas_equalTo(0);
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

- (void)setModel:(CateyeSetModel *)model{
    _model = model;
    self.titleLabel.text = model.titleName;
    if (model.value) {
    self.contentTf.text = [NSString stringWithFormat:@"%@",model.value];
    }
   
    [self layoutSubviews];
}

+ (NSString *)ID{
    
    return @"CateyePIRSilenceCell";
}

@end
