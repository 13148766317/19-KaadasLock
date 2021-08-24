//
//  KDSMyMessageContentView.m
//  KaadasLock
//
//  Created by zhaona on 2019/3/30.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSMyMessageContentView.h"


@interface KDSMyMessageContentView ()

///暂无消息的logo
@property (nonatomic,readwrite,strong)UIImageView * imgV;
///暂无消息
@property (nonatomic,readwrite,strong)UILabel * lbL;
///第一种样式的cell：title、detail、icone、time、GXuan
@property (nonatomic,readwrite,strong)UIView * styleCellOne;
///第二种cell：title、icone、time
@property (nonatomic,readwrite,strong)UIView * styleCellTwo;

@end


@implementation KDSMyMessageContentView


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self addMySubViews];
        [self makeMyConstraints];
    }
    
    return self;
}

#pragma private methods

-(void)addMySubViews
{
    [self addSubview:self.imgV];
    [self addSubview:self.lbL];
}

-(void)makeMyConstraints
{
    [self.imgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(79);
        make.centerX.mas_equalTo(self.mas_centerX).offset(0);
        make.width.mas_equalTo(160);
        make.height.mas_equalTo(165);

    }];
    
    [self.lbL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.imgV.mas_bottom).offset(35);
        make.centerX.mas_equalTo(self.mas_centerX).offset(0);
//        make.width.mas_equalTo(51);
        make.height.mas_equalTo(13);
        
    }];
    
}

#pragma mark --Lazy load

- (UIImageView *)imgV
{
    if (!_imgV) {
        
        _imgV = ({
            UIImageView * img = [UIImageView new];
            img.image = [UIImage imageNamed:@"NoMessage_picture"];
            img.backgroundColor = [UIColor clearColor];
            img;
            
        });
    }
    
    return _imgV;
}

- (UILabel *)lbL
{
    
    if (!_lbL) {
        _lbL = ({
            
            UILabel * ll = [UILabel new];
            ll.font = [UIFont systemFontOfSize:13];
            ll.textColor = KDSRGBColor(153, 153, 153);
//            ll.text = Localized(@"noData");
            ll.textAlignment = NSTextAlignmentCenter;
            ll.hidden = YES;
            ll;
        });
    }
    
    return _lbL;
}

@end
