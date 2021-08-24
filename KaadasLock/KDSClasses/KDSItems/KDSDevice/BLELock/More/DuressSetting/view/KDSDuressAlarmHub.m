//
//  KDSDuressAlarmHub.m
//  2021-Philips
//
//  Created by dangwanzhen on 2021/5/20.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSDuressAlarmHub.h"

@implementation KDSDuressAlarmHub

-(instancetype) initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        @autoreleasepool {
            [self setupMainView];
        }
    }
    return self;
}

#pragma mark - 初始化主视图
-(void) setupMainView{
    
    UIView *backView = [UIView new];
    backView.layer.cornerRadius = 5;
    backView.backgroundColor = [UIColor whiteColor];
    [self addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(0);
        make.right.equalTo(self).with.offset(0);
        make.top.equalTo(self).with.offset(0);
        make.bottom.equalTo(self).with.offset(-130);
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"什么是胁迫报警?";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [backView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(0);
        make.right.equalTo(self).with.offset(0);
        make.top.equalTo(self).with.offset(20);
        make.height.mas_equalTo(@20);
    }];
    
    UIImageView *markImageView = [UIImageView new];
    markImageView.image = [UIImage imageNamed:@"philips_alarm_img_referencefigure"];
    [self addSubview:markImageView];
    [markImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(40);
        make.right.equalTo(self).with.offset(-40);
        make.top.equalTo(titleLabel.mas_bottom).with.offset(35);
        make.bottom.equalTo(self.mas_centerY).with.offset(-10);
    }];
    
    UILabel *subTitle = [UILabel new];
    subTitle.textAlignment = NSTextAlignmentLeft;
    subTitle.numberOfLines = 0;
    subTitle.font = [UIFont systemFontOfSize:15];
    subTitle.text = @"将密码或指纹设置为胁迫密钥时，使用该胁迫密码或者指纹开门，已关联的通知账号将会收到胁迫报警信息.";
    [backView addSubview:subTitle];
    [subTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(15);
        make.right.equalTo(self).with.offset(-15);
        make.top.equalTo(self.mas_centerY).with.offset(40);
        make.height.mas_equalTo(@80);
    }];
    
    UIButton *removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [removeButton addTarget:self action:@selector(removaButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [removeButton setBackgroundImage:[UIImage imageNamed:@"philips_alarm_icon_close"] forState:UIControlStateNormal];
    [self addSubview:removeButton];
    [removeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_centerX).with.offset(-25);
        make.bottom.equalTo(self).with.offset(-40);
        make.height.mas_equalTo(@50);
        make.width.mas_equalTo(@50);
    }];
}

-(void) removaButtonClick:(UIButton *)btn{
    
    if ([self.duressAlarmHubDelegate respondsToSelector:@selector(removeDuressAlarmHub)]) {
        [self.duressAlarmHubDelegate removeDuressAlarmHub];
    }
}


@end
