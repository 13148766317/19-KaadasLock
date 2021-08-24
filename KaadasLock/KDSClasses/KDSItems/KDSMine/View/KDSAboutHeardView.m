//
//  KDSAboutHeardView.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/1.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSAboutHeardView.h"

@interface KDSAboutHeardView ()

///logo
@property (nonatomic,readwrite,strong)UIImageView * logoImageView;
///背景图
@property (nonatomic,readwrite,strong)UIImageView * bgImageView;
///343:159label----显示内容
@property (nonatomic,readwrite,strong)UILabel * label;


@end

@implementation KDSAboutHeardView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self addMySubViews];
        [self addMakeContrants];
        
    }
    
    return self;
}

-(void)addMySubViews
{
    [self addSubview:self.bgImageView];
    [self addSubview:self.logoImageView];
    [self addSubview:self.label];
    
}

-(void)addMakeContrants
{
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.left.right.bottom.mas_equalTo(0);
        
    }];
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.mas_top).offset(23);
        make.height.mas_equalTo(58);
        make.width.mas_equalTo(148);
        make.centerX.mas_equalTo(self.mas_centerX);
        
        
    }];

    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.mas_equalTo(self.mas_left).offset(15);
        make.right.mas_equalTo(self.mas_right).offset(-15);
        make.top.mas_equalTo(self.logoImageView.mas_bottom).offset(10);
        make.height.mas_equalTo(159);
    }];
   
    
}

#pragma mark --Lazy load

-(UIImageView *)logoImageView
{
    if (!_logoImageView) {
        
        _logoImageView = ({
            
            UIImageView * heardImg = [UIImageView new];
            heardImg.userInteractionEnabled = YES;
            heardImg.image = [UIImage imageNamed:@"LOGOAboutUs"];
            heardImg.backgroundColor = [UIColor clearColor];
            heardImg;
        });
        
        
    }
    
    return _logoImageView;
}

-(UIImageView *)bgImageView
{
    if (!_bgImageView) {
        _bgImageView = ({
            
            UIImageView *bgImg = [UIImageView new];
            bgImg.image = [UIImage imageNamed:@""];
            bgImg;
        });
    }
    
    return _bgImageView;
}

- (UILabel *)label
{
    if (!_label) {
        _label = ({
            UILabel * lab = [UILabel new];
            lab.font = [UIFont systemFontOfSize:14];
            lab.textColor = KDSRGBColor(51, 51, 51);
            lab.text = @"Kaadas凯迪仕专注于智能锁领域，是一家集产品研发、制造、销售、安装、售后于一体的全产业链公司，是国家级高新技术企业，总部位于中国深圳高新科技园——清华信息港。凯迪仕一直秉承“创新、智造、品质、诚信、工匠精神”做产品，为全球每一位消费者提供舒适，便捷，安全的高品质生活。目前凯迪仕有1000多名员工，上万家全球终端网点，销售规模位居全球前列。";
            lab.textAlignment = NSTextAlignmentLeft;
            lab.numberOfLines = 0;
            lab;
        });
    }
    return _label;
}

@end
