//
//  KDSMyMessageCell.m
//  KaadasLock
//
//  Created by zhaona on 2019/3/31.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSMyMessageCell.h"

@interface KDSMyMessageCell ()

///右箭头
@property (nonatomic,readwrite,strong)UIImageView * rightArrowImageView;
///背景图
@property (nonatomic,readwrite,strong)UIImageView * bgImageView;
///头像点击手势
@property (nonatomic,readwrite,strong)UITapGestureRecognizer *iconTap;

@end

@implementation KDSMyMessageCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:self.iconTap];
        [self addMySubViews];
        [self addMakeContrants];
       
    }
    
    return self;
}

-(void)addMySubViews
{
    [self addSubview:self.bgImageView];
    [self addSubview:self.heardImageView];
    [self addSubview:self.rightArrowImageView];
    [self addSubview:self.nickNameLabel];
}

-(void)addMakeContrants
{
    [self.heardImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.mas_left).offset(13);
        make.height.width.mas_equalTo(80);
        make.centerY.mas_equalTo(self.mas_centerY);
        
    }];
    
    [self.rightArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(self.mas_right).offset(-16);
        make.height.mas_equalTo(13);
        make.width.mas_equalTo(8);
        make.centerY.mas_equalTo(self.heardImageView.mas_centerY);
    }];
    
    [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.heardImageView.mas_right).offset(15);
        make.right.mas_equalTo(self.rightArrowImageView.mas_left).offset(-15);
        make.centerY.mas_equalTo(self.heardImageView.mas_centerY);
    }];
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.left.right.bottom.mas_equalTo(0);
        
    }];
    
}

#pragma mark -- private methods
-(void)iconTapAction:(UITapGestureRecognizer *)tap{
    if (self.block) {
        self.block(@"");
    }
}


#pragma mark --Lazy load

-(UIImageView *)heardImageView
{
    if (!_heardImageView) {
        
        _heardImageView = ({
            
            UIImageView * heardImg = [UIImageView new];
            heardImg.image = [UIImage imageNamed:@"头像"];
            heardImg.layer.borderWidth = 1;
            heardImg.layer.borderColor = [UIColor whiteColor].CGColor;
            heardImg.layer.masksToBounds = YES;
            heardImg.layer.cornerRadius = 40;
            heardImg;
        });
      
        
    }
    
    return _heardImageView;
}

- (UIImageView *)rightArrowImageView
{
    if (!_rightArrowImageView) {
        
        _rightArrowImageView = ({
            
            UIImageView * rightImag = [UIImageView new];
            rightImag.image = [UIImage imageNamed:@"右箭头"];
            
            rightImag;
        });
    }
    
    return _rightArrowImageView;
}
-(UIImageView *)bgImageView
{
    if (!_bgImageView) {
        _bgImageView = ({
            
            UIImageView *bgImg = [UIImageView new];
            bgImg.image = [UIImage imageNamed:@"My_bg"];
            bgImg;
        });
    }
    
    return _bgImageView;
}
-(UILabel *)nickNameLabel
{
    if (!_nickNameLabel) {
        _nickNameLabel = ({
            
            UILabel * nL = [UILabel new];
            nL.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
            nL.textColor = KDSRGBColor(255, 255, 255);
            nL.textAlignment = NSTextAlignmentLeft;
            nL.numberOfLines = 0;
            nL.text = @"壮壮家的守护者";
            nL;
        });
    }
    return _nickNameLabel;
}
-(UITapGestureRecognizer *)iconTap{
    if (!_iconTap) {
        _iconTap = ({
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconTapAction:)];
            
            tap;
        });
    }
    return _iconTap;
}
@end
