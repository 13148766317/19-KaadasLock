//
//  KDSDeviceContentView.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/4.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSDeviceContentView.h"

@interface KDSDeviceContentView ()
///没有设备的时候默认的视图
@property (nonatomic,readwrite,strong)UIImageView * nodeviceImageView;



@end

@implementation KDSDeviceContentView

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
    [self addSubview:self.nodeviceImageView];
    [self addSubview:self.promptingLabel];
    [self addSubview:self.addDeviceBtn];
}

-(void)makeMyConstraints
{
    [self.nodeviceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(64);
        make.centerX.mas_equalTo(self.mas_centerX).offset(0);
        make.width.mas_equalTo(142);
        make.height.mas_equalTo(109);
    }];
    
    [self.promptingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nodeviceImageView.mas_bottom).offset(35);
        make.centerX.mas_equalTo(self.mas_centerX).offset(0);
        make.height.mas_equalTo(13);
        
    }];
    
    [self.addDeviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.mas_equalTo(self.mas_left).offset(55);
        make.right.mas_equalTo(self.mas_right).offset(-55);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-KDSSSALE_HEIGHT(145));
    }];
    
    
}

#pragma mark --Lazy load

- (UIImageView *)nodeviceImageView
{
    if (!_nodeviceImageView) {
        
        _nodeviceImageView = ({
            UIImageView * img = [UIImageView new];
            img.image = [UIImage imageNamed:@"No equipment_pic"];
            img.backgroundColor = [UIColor clearColor];
            img;
            
        });
    }
    
    return _nodeviceImageView;
}

- (UILabel *)promptingLabel
{
    
    if (!_promptingLabel) {
        _promptingLabel = ({
            
            UILabel * ll = [UILabel new];
            ll.font = [UIFont systemFontOfSize:13];
            ll.textColor = KDSRGBColor(153, 153, 153);
            ll.text = Localized(@"youNoDeviceNow");
            ll.textAlignment = NSTextAlignmentCenter;
            ll;
        });
    }
    
    return _promptingLabel;
}

-(UIButton *)addDeviceBtn
{
    if (!_addDeviceBtn) {
        _addDeviceBtn = ({
            UIButton * aBtn = [UIButton new];
            aBtn.backgroundColor = KDSRGBColor(31, 150, 247);
            [aBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            aBtn.layer.cornerRadius = 22;
            aBtn.titleLabel.font = [UIFont systemFontOfSize:15];
            [aBtn setTitle:Localized(@"buyItNow") forState:UIControlStateNormal];
            aBtn;
        });
    }
    
    return _addDeviceBtn;
}

@end
