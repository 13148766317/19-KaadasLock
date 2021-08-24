//
//  KDSHomeRoutersCell.m
//  KaadasLock
//
//  Created by zhaona on 2019/12/12.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSHomeRoutersCell.h"

@implementation KDSHomeRoutersCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
     
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.detail];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self makeMyConstrains];
       
    }
    
    return self;
}
-(void)makeMyConstrains
{
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.left.bottom.mas_equalTo(0);
//        make.width.equalTo(@((KDSScreenWidth/3) * 2));
         make.width.equalTo(@(KDSScreenWidth/3));
        
        
    }];
    
    [self.detail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.mas_equalTo(0);
        make.width.equalTo(@(KDSScreenWidth/3));
        
    }];
}

- (void)setFrame:(CGRect)frame{
    frame.origin.x += 10;
    frame.size.width -= 10;
    [super setFrame:frame];
}

#pragma mark --Lazy load

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = ({
        UILabel * lab = [UILabel new];
        lab = [[UILabel alloc] init];
        lab.font = [UIFont systemFontOfSize:13];
        lab.textColor = KDSRGBColor(51, 51, 51);
        lab.textAlignment = NSTextAlignmentCenter;
        lab;
        });
    }
    
    return _titleLabel;
}

-(UILabel *)detail
{
    if (!_detail) {
        _detail = ({
            UILabel * de = [UILabel new];
            de.font = [UIFont systemFontOfSize:13];
            de.textColor = KDSRGBColor(54, 54, 54);
            de.textAlignment = NSTextAlignmentLeft;
            de.numberOfLines = 0;
            de;
        });
    }
    
    return _detail;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
