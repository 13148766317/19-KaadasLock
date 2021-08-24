//
//  KDSFaceAMModelVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/5/13.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSFaceAMModelVC.h"

@interface KDSFaceAMModelVC ()

@end

///label之间多行显示的行间距
#define labelWidth  10

@implementation KDSFaceAMModelVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = @"A-M自动/手动模式";
    [self setUI];
}

-(void)setUI
{
    UIView *headerView = [UIView new];
    
    UIView *cornerView1 = [self createCornerView1];
    cornerView1.frame = (CGRect){15, 15, cornerView1.bounds.size};
    [headerView addSubview:cornerView1];
    
    UIView *cornerView2 = [self createCornerView2];
    cornerView2.frame = (CGRect){15, CGRectGetMaxY(cornerView1.frame) + 15, cornerView2.bounds.size};
    [headerView addSubview:cornerView2];
    
    headerView.frame = CGRectMake(0, 0, kScreenWidth, CGRectGetMaxY(cornerView2.frame) + 15);
    headerView.backgroundColor = self.view.backgroundColor;
    self.tableView.tableHeaderView = headerView;
    
}

- (UIView *)createCornerView1
{
    UIView *tipsView = [UIView new];
    tipsView.backgroundColor = UIColor.whiteColor;
    tipsView.layer.cornerRadius = 4;
    
    UILabel *titleLb1 = [self createLabelWithText:@"Kaadas 2代操作菜单" color:KDSRGBColor(0, 0, 0) font:[UIFont systemFontOfSize:14] width:kScreenWidth - 60];
    [tipsView addSubview:titleLb1];
    [titleLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tipsView.mas_left).offset(10);
        make.right.equalTo(tipsView.mas_right).offset(-10);
        make.top.equalTo(tipsView.mas_top).offset(15);
        make.height.equalTo(@20);
    }];
    UILabel *tipsLb = [self createLabelWithText:@"如何开启A-M自动模式（手动模式下）" color:KDSRGBColor(0, 0, 0) font:[UIFont systemFontOfSize:16] width:kScreenWidth - 60];
    [tipsView addSubview:tipsLb];
    [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tipsView.mas_left).offset(10);
        make.right.equalTo(tipsView.mas_right).offset(-10);
        make.top.equalTo(titleLb1.mas_bottom).offset(27);
        make.height.equalTo(@20);
    }];
    UILabel *tipsLb1 = [self createLabelWithText:@"① 按键区输入“*”两次\n② 输入已修改的管理密码“********”\n③ 按“#”确认，\n④ 语音播报：“已进入管理模式”\n⑤ 根据语音提示,按“1”，在按“8”\n⑥ 语音播报“设置成功，自动模式”" color:KDSRGBColor(96, 96, 96) font:[UIFont systemFontOfSize:14] width:kScreenWidth - 60];
    [self setLabelSpace:tipsLb1 withSpace:labelWidth withFont:[UIFont systemFontOfSize:14]];
    [tipsView addSubview:tipsLb1];
    [tipsLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tipsView.mas_left).offset(10);
        make.right.equalTo(tipsView.mas_right).offset(-10);
        make.top.equalTo(tipsLb.mas_bottom).offset(10);
    }];
    UILabel *tipsLb22 = [self createLabelWithText:@"如何开启A-M手动模式（自动模式下）" color:KDSRGBColor(0, 0, 0) font:[UIFont systemFontOfSize:16] width:kScreenWidth - 60];
    [tipsView addSubview:tipsLb22];
    [tipsLb22 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tipsView.mas_left).offset(10);
        make.right.equalTo(tipsView.mas_right).offset(-10);
        make.top.equalTo(tipsLb1.mas_bottom).offset(27);
        make.height.equalTo(@20);
    }];
    UILabel *tipsLb33 = [self createLabelWithText:@"① 按键区输入“*”两次\n② 输入已修改的管理密码“********”\n③ 按“#”确认，\n④ 语音播报：“已进入管理模式”\n⑤ 根据语音提示,按“1”，在按“8”\n⑥ 语音播报“设置成功，手动模式”" color:KDSRGBColor(96, 96, 96) font:[UIFont systemFontOfSize:14] width:kScreenWidth - 60];
    [self setLabelSpace:tipsLb33 withSpace:labelWidth withFont:[UIFont systemFontOfSize:14]];
    [tipsView addSubview:tipsLb33];
    [tipsLb33 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tipsView.mas_left).offset(10);
        make.right.equalTo(tipsView.mas_right).offset(-10);
        make.top.equalTo(tipsLb22.mas_bottom).offset(10);
    }];
    
    tipsView.bounds = CGRectMake(0, 0, kScreenWidth - 30, 470);
    
    return tipsView;
}

- (UIView *)createCornerView2
{
    UIView *tipsView1 = [UIView new];
    tipsView1.backgroundColor = UIColor.whiteColor;
    tipsView1.layer.cornerRadius = 4;
    
    UILabel *titleLb = [self createLabelWithText:@"Kaadas 1代操作菜单" color:KDSRGBColor(0, 0, 0) font:[UIFont systemFontOfSize:14] width:kScreenWidth - 60];
    [tipsView1 addSubview:titleLb];
    [titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tipsView1.mas_left).offset(10);
        make.right.equalTo(tipsView1.mas_right).offset(-10);
        make.top.equalTo(tipsView1.mas_top).offset(15);
        make.height.equalTo(@20);
    }];
                                
    UILabel *tipsLb2 = [self createLabelWithText:@"如何开启A-M自动模式" color:KDSRGBColor(0, 0, 0) font:[UIFont systemFontOfSize:16] width:kScreenWidth - 60];
    [tipsView1 addSubview:tipsLb2];
    [tipsLb2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tipsView1.mas_left).offset(10);
        make.right.equalTo(tipsView1.mas_right).offset(-10);
        make.top.equalTo(titleLb.mas_bottom).offset(27);
        make.height.equalTo(@20);
    }];
    
    UILabel *tipsLb3 = [self createLabelWithText:@"① 按键区输入“*”两次\n② 输入已修改的管理密码“********”\n③ 按“#”确认，\n④ 语音播报：“已进入管理模式”\n⑤ 根据语音提示,按“7”，在按“1”\n⑥ 语音播报“设置成功，自动模式”" color:KDSRGBColor(96, 96, 96) font:[UIFont systemFontOfSize:14] width:kScreenWidth - 60];
    [self setLabelSpace:tipsLb3 withSpace:labelWidth withFont:[UIFont systemFontOfSize:14]];
    [tipsView1 addSubview:tipsLb3];
    [tipsLb3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tipsView1.mas_left).offset(10);
        make.right.equalTo(tipsView1.mas_right).offset(-10);
        make.top.equalTo(tipsLb2.mas_bottom).offset(10);
    }];
   
    UILabel *tipsLb11 = [self createLabelWithText:@"如何开启A-M手动模式" color:KDSRGBColor(0, 0, 0) font:[UIFont systemFontOfSize:16] width:kScreenWidth - 60];
    [tipsView1 addSubview:tipsLb11];
    [tipsLb11 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tipsView1.mas_left).offset(10);
        make.right.equalTo(tipsView1.mas_right).offset(-10);
        make.top.equalTo(tipsLb3.mas_bottom).offset(27);
        make.height.equalTo(@20);
    }];
    
    UILabel *tipsLb12 = [self createLabelWithText:@"① 按键区输入“*”两次\n② 输入已修改的管理密码“********”\n③ 按“#”确认，\n④ 语音播报：“已进入管理模式”\n⑤ 根据语音提示,按“7”，在按“2”\n⑥ 语音播报“设置成功，手动模式”" color:KDSRGBColor(96, 96, 96) font:[UIFont systemFontOfSize:14] width:kScreenWidth - 60];
    [self setLabelSpace:tipsLb12 withSpace:labelWidth withFont:[UIFont systemFontOfSize:14]];
    [tipsView1 addSubview:tipsLb12];
    [tipsLb12 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tipsView1.mas_left).offset(10);
        make.right.equalTo(tipsView1.mas_right).offset(-10);
        make.top.equalTo(tipsLb11.mas_bottom).offset(10);
    }];
    
    tipsView1.bounds = CGRectMake(0, 0, kScreenWidth - 30, 470);
    
    return tipsView1;
    
}

- (UILabel *)createLabelWithText:(NSString *)text color:(nullable UIColor *)color font:(nullable UIFont *)font width:(CGFloat)width
{
    color = color ?: KDSRGBColor(0x33, 0x33, 0x33);
    font = font ?: [UIFont systemFontOfSize:13];
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.text = text;
    label.textColor = color;
    label.font = font;
    CGSize size = [text boundingRectWithSize:CGSizeMake(width, kScreenHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size;
    label.bounds = CGRectMake(0, 0, width, ceil(size.height));
    return label;
}


-(void)setLabelSpace:(UILabel*)label withSpace:(CGFloat)space withFont:(UIFont*)font  {
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = space; //设置行间距
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    //设置字间距 NSKernAttributeName:@1.5f
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@0.0f};
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:label.text attributes:dic];
    label.attributedText = attributeStr;
}

@end
