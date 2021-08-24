//
//  KDSSingleSwithCell.m
//  KaadasLock
//
//  Created by zhaona on 2020/4/20.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSSingleSwithCell.h"

@interface KDSSingleSwithCell ()
///标示开关键位的图片
@property (nonatomic,strong) UIImageView * iconImg;
///右箭头
@property (nonatomic,strong) UIImageView * rightRowImg;

@end

@implementation KDSSingleSwithCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.whiteColor;
        
        self.iconImg = [UIImageView new];
        self.iconImg.image = [UIImage imageNamed:@"twoSingleSwithIconImg"];
        [self.contentView addSubview:self.iconImg];
        [self.iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@33.5);
            make.left.equalTo(self).offset(15);
            make.top.equalTo(self).offset(14);
        }];
        
        self.singleSwithNameLb = [UILabel new];
        self.singleSwithNameLb.text = @"玄关灯（键位1）";
        self.singleSwithNameLb.textColor = UIColor.blackColor;
        self.singleSwithNameLb.font = [UIFont systemFontOfSize:14];
        self.singleSwithNameLb.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.singleSwithNameLb];
        [self.singleSwithNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.bottom.equalTo(self).offset(-20);
            make.height.equalTo(@20);
            make.width.equalTo(@((KDSScreenWidth-60)/2));
            make.top.equalTo(self.iconImg.mas_bottom).offset(10);
            
        }];
        
        self.singleSwithBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.singleSwithBtn setImage:[UIImage imageNamed:@"off-powerStatusIcon"] forState:UIControlStateNormal];
        [self.singleSwithBtn setImage:[UIImage imageNamed:@"on-powerStatusIcon"] forState:UIControlStateSelected];
        self.singleSwithBtn.selected = YES;
        [self.singleSwithBtn addTarget:self action:@selector(singleSwithBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.singleSwithBtn];
        [self.singleSwithBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@42);
            make.height.equalTo(@21);
            make.right.equalTo(self).offset(-19);
            make.top.equalTo(self).offset(14);
        }];
        
        self.rightRowImg = [UIImageView new];
        self.rightRowImg.image = [UIImage imageNamed:@"rightBackIcon"];
        [self.contentView addSubview:self.rightRowImg];
        [self.rightRowImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@11);
            make.height.equalTo(@10);
            make.right.equalTo(self).offset(-19);
            make.bottom.equalTo(self).offset(-25);
        }];
        
        self.timeLb = [UILabel new];
        self.timeLb.textColor = KDSRGBColor(190, 190, 190);
        self.timeLb.text = @"20:00-24:00";
        self.timeLb.font = [UIFont systemFontOfSize:13];
        self.timeLb.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.timeLb];
        [self.timeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@20);
            make.right.equalTo(self.rightRowImg.mas_left).offset(-5);
            make.bottom.equalTo(self).offset(-20);
        }];
        
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setFrame:(CGRect)frame
{
    frame.origin.x +=10;
    frame.size.width -= 20;
    [super setFrame:frame];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)singleSwithBtnClick:(UIButton *)btn
{
    self.singleSwithBtn.selected = !self.singleSwithBtn.selected;
    !self.selectedBtnClickBlock ?: self.selectedBtnClickBlock();
}

@end
