//
//  KDSAboutCell.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/1.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSAboutCell.h"

@interface KDSAboutCell ()



@end

@implementation KDSAboutCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
     
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
        
        make.top.mas_equalTo(self.mas_top).offset(20);
        make.left.mas_equalTo(self.mas_left).offset(16);
        make.width.mas_equalTo(160);
        make.height.mas_equalTo(20);
        
        
    }];
    
    [self.detail mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.mas_top).offset(20);
        make.right.mas_equalTo(self.mas_right).offset(-16);
        make.width.mas_equalTo(160);
        make.height.mas_equalTo(20);
        
    }];
}

#pragma mark --Lazy load

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = ({
        UILabel * lab = [UILabel new];
        lab = [[UILabel alloc] init];
        lab.font = [UIFont systemFontOfSize:15];
        lab.textColor = KDSRGBColor(51, 51, 51);
        lab.textAlignment = NSTextAlignmentLeft;
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
            de.font = [UIFont systemFontOfSize:15];
            de.textColor = KDSRGBColor(31, 150, 247);
            de.textAlignment = NSTextAlignmentRight;
            
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
