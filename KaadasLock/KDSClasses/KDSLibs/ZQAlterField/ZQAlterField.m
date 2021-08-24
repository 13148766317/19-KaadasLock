//
//  ZQAlterField.m
//  ZQAlterFieldDemo
//
//  Created by 肖兆强 on 2018/2/6.
//  Copyright © 2018年 ZQ. All rights reserved.
//

#import "ZQAlterField.h"
#import "ZQUtil.h"
#import "UIView+Extension.h"


#define kZLPhotoBrowserBundle [NSBundle bundleForClass:[self class]]

#define ZQWindow [UIApplication sharedApplication].keyWindow

@interface ZQAlterField ()<UITextFieldDelegate>

/**
 回调block
 */
@property (nonatomic, copy) ensureCallback ensureBlock;

/**
 蒙板
 */
@property (nonatomic, weak) UIView *becloudView;

@end



@implementation ZQAlterField

+ (instancetype)alertView
{
    return [[kZLPhotoBrowserBundle loadNibNamed:@"ZQAlterField" owner:self options:nil] lastObject];;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setCornerRadius:self];
    [self setCornerRadius:self.ensureBtn];
    [self setCornerRadius:self.textFieldBG];
    [self.plaintextBtn setImage:[UIImage imageNamed:@"眼睛闭Default"] forState:UIControlStateSelected];
    [self.plaintextBtn setImage:[UIImage imageNamed:@"眼睛开Default"] forState:UIControlStateNormal];
    
    // 添加点击手势
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(exitKeyboard)];
    [self addGestureRecognizer:tapGR];
    self.textFieldBG.backgroundColor = UIColor.whiteColor;
    self.textField.delegate = self;
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.textAlignment = NSTextAlignmentCenter;
    self.textField.textColor = KDSRGBColor(0x10, 0x10, 0x10);
    self.textField.font = [UIFont systemFontOfSize:13];
    self.textField.layer.shadowColor = KDSRGBColor(244, 244, 244).CGColor;
    self.textField.layer.shadowOffset = CGSizeMake(2, 2);
    [self.textField addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.textField.layer.shadowOpacity = 1.0;
    self.ensureBtn.backgroundColor =UIColor.clearColor;
}
///关联锁的密码昵称输入框，长度不能超过16.
- (void)textFieldTextDidChange:(UITextField *)sender
{
    if (sender.text.length > 16) {
        sender.text = [sender.text substringToIndex:16];
    }
}

#pragma mark - 设置控件圆角
- (void)setCornerRadius:(UIView *)view
{
    
    view.layer.cornerRadius = 5.0;
    view.layer.masksToBounds = YES;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = [placeholder copy];
    self.textField.placeholder = self.placeholder;
}

- (void)setEnsureBgColor:(UIColor *)ensureBgColor
{
    _ensureBgColor = ensureBgColor;
    self.ensureBtn.backgroundColor = ensureBgColor;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}


- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    self.textField.textColor = textColor;
}


-(void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    self.titleLabel.textColor = titleColor;
}


- (void)setTextFieldBgColor:(UIColor *)textFieldBgColor
{
    _textFieldBgColor = textFieldBgColor;
    self.textFieldBG.backgroundColor = textFieldBgColor;
}

- (void)show
{
    // 蒙版
    UIView *becloudView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    becloudView.backgroundColor = [UIColor blackColor];
    becloudView.layer.opacity = 0.5;
    //点击蒙版是否消失弹出框
//    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAlertView:)];
//    [becloudView addGestureRecognizer:tapGR];
    
    [ZQWindow addSubview:becloudView];
    self.becloudView = becloudView;
    // 弹出框
    self.frame = CGRectMake(0, 0, KDSScreenWidth-100, 180);
    self.center = CGPointMake(becloudView.center.x, becloudView.frame.size.height * 0.4);
    [ZQWindow addSubview:self];
    
}

- (void)exitKeyboard
{
    [self endEditing:YES];
}

#pragma mark - 移除ZYInputAlertView
- (void)dismiss
{
    [self removeFromSuperview];
    [self.becloudView removeFromSuperview];
}

#pragma mark - 点击关闭按钮
- (IBAction)closeAlertView:(UIButton *)sender {
    [self dismiss];
}

#pragma mark - 接收传过来的block

- (void)ensureClickBlock:(ensureCallback)block

{
    self.ensureBlock = block;
}

#pragma mark - 点击确认按钮
- (IBAction)ensureBtnClick:(UIButton *)sender {
    [self dismiss];
    if (self.ensureBlock) {
        self.ensureBlock(self.textField.text);
    }
}

- (IBAction)plainttextBtn:(id)sender {
    
    self.plaintextBtn.selected = !self.plaintextBtn.selected;
    if (self.plaintextBtn.selected) {
        self.textField.secureTextEntry = YES;
    }else{
        self.textField.secureTextEntry = NO;
    }
}

@end
