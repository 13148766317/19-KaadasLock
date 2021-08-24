//
//  KDSAlertView.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/10/26.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAlertView.h"

@interface KDSAlertView ()
///title
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation KDSAlertView

#pragma mark - class methods
+ (instancetype)alertControllerWithTitle:(NSString *)title
{
    KDSAlertView *controller = [[KDSAlertView alloc] init];
    controller.title = title;
    return controller;
}

#pragma mark - getter setter
- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
//    CGFloat tHeight = ceil([title sizeWithAttributes:@{NSFontAttributeName : self.titleLabel.font}].height);
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self);
//        make.height.equalTo(@(tHeight));
    }];
}

- (NSString *)title
{
    return self.titleLabel.text;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor ?: UIColor.blackColor;
    self.titleLabel.textColor = _titleColor;
}

#pragma mark - life cycle and ui relevant methods
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.7];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 6;
        self.tintColor = UIColor.whiteColor;
        self.titleLabel = [UILabel new];
        self.titleLabel.textColor = UIColor.whiteColor;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.equalTo(self);
        }];
        
        
    }
    return self;
}

@end
