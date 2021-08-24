//
//  KDSAlertController.m
//  KaadasLock
//
//  Created by orange on 2019/3/28.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSAlertController.h"
#import "Masonry.h"

@interface KDSAlertController ()

///corner view
@property (nonatomic, strong) UIView *cornerView;
///title label
@property (nonatomic, strong) UILabel *titleLabel;
///message label
@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation KDSAlertController

@dynamic title;

#pragma mark - class methods
+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message
{
    KDSAlertController *controller = [[KDSAlertController alloc] init];
    controller.title = title;
    controller.message = message;
    
    return controller;
}

#pragma mark - getter setter
- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
    if (!title.length)
    {
        [self.messageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self.cornerView).offset(20);
            make.bottom.right.equalTo(self.cornerView).offset(-20);
        }];
    }
    else if (title.length && self.message.length)
    {
        CGFloat tHeight = ceil([title sizeWithAttributes:@{NSFontAttributeName : self.titleLabel.font}].height);
        CGFloat mHeight = ceil([self.message boundingRectWithSize:CGSizeMake(self.cornerView.bounds.size.width - 40, 40) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.messageLabel.font} context:nil].size.height);
        CGFloat top = (self.cornerView.bounds.size.height - tHeight - 12 - mHeight) / 2.0;
        top = top < 10 ? 10 : top;
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.cornerView).offset(top);
            make.left.equalTo(self.cornerView).offset(20);
            make.right.equalTo(self.cornerView).offset(-20);
            make.height.equalTo(@(tHeight));
        }];
        [self.messageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(12);
            make.left.equalTo(self.cornerView).offset(20);
            make.right.equalTo(self.cornerView).offset(-20);
        }];
    }
}

- (NSString *)title
{
    return self.titleLabel.text;
}

- (void)setMessage:(NSString *)message
{
    self.messageLabel.text = message;
    if (!message.length)
    {
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self.cornerView).offset(20);
            make.bottom.right.equalTo(self.cornerView).offset(-20);
        }];
    }
    else if (message.length && self.title.length)
    {
        CGFloat tHeight = ceil([self.title sizeWithAttributes:@{NSFontAttributeName : self.titleLabel.font}].height);
        CGFloat mHeight = ceil([message boundingRectWithSize:CGSizeMake(self.cornerView.bounds.size.width - 40, 40) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.messageLabel.font} context:nil].size.height);
        CGFloat top = (self.cornerView.bounds.size.height - tHeight - 12 - mHeight) / 2.0;
        top = top < 10 ? 10 : top;
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.cornerView).offset(top);
            make.left.equalTo(self.cornerView).offset(20);
            make.right.equalTo(self.cornerView).offset(-20);
            make.height.equalTo(@(tHeight));
        }];
        [self.messageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(12);
            make.left.equalTo(self.cornerView).offset(20);
            make.right.equalTo(self.cornerView).offset(-20);
        }];
    }
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor ?: UIColor.blackColor;
    self.titleLabel.textColor = _titleColor;
}

- (void)setMessageColor:(UIColor *)messageColor
{
    _messageColor = messageColor ?: KDSRGBColor(0x99, 0x99, 0x99);
    self.messageLabel.textColor = _messageColor;
}

#pragma mark - life cycle and ui relevant methods
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        
        self.cornerView = [UIView  new];
        self.cornerView.bounds = CGRectMake(0, 0, 270, 95);
        self.cornerView.backgroundColor = UIColor.whiteColor;
        self.cornerView.layer.cornerRadius = 13;
        self.cornerView.layer.masksToBounds = YES;
        [self.view addSubview:self.cornerView];
        [self.cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
            //make.top.equalTo(self.view).offset((kScreenHeight - 95) / (201 + 372) * 201);
            make.center.equalTo(self.view);
            make.size.mas_equalTo(self.cornerView.bounds.size);
        }];
        
        self.titleLabel = [UILabel new];
        self.titleLabel.textColor = UIColor.blackColor;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.cornerView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self.cornerView).offset(20);
            make.right.equalTo(self.cornerView).offset(-20);
            make.height.equalTo(@15);
        }];
        
        self.messageLabel = [UILabel new];
        self.messageLabel.textColor = KDSRGBColor(0x99, 0x99, 0x99);
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        self.messageLabel.font = [UIFont systemFontOfSize:12];
        self.messageLabel.numberOfLines = 3;
        [self.cornerView addSubview:self.messageLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(12);
            make.left.equalTo(self.cornerView).offset(20);
            make.right.equalTo(self.cornerView).offset(-20);
        }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *translucentView = [[UIView alloc] initWithFrame:self.view.bounds];
    translucentView.backgroundColor = KDSRGBColorZA(0, 0, 0, 0.5);
    [self.view addSubview:translucentView];
}

@end
