//
//  KDSFaceEnergyModeVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/5/13.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSFaceEnergyModeVC.h"

@interface KDSFaceEnergyModeVC ()

@end

///label之间多行显示的行间距
#define labelWidth  10

@implementation KDSFaceEnergyModeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = @"节能模式";
    UIView *headerView = [UIView new];
    
    UIView *cornerView1 = [self createCornerView1];
    cornerView1.frame = (CGRect){15, 15, cornerView1.bounds.size};
    [headerView addSubview:cornerView1];
    
    UIView *cornerView2 = [self createCornerView2];
    cornerView2.frame = (CGRect){15, CGRectGetMaxY(cornerView1.frame) + 15, cornerView2.bounds.size};
    [headerView addSubview:cornerView2];
    
    UIView *cornerView3 = [self createCornerView3];
    cornerView3.frame = (CGRect){15, CGRectGetMaxY(cornerView2.frame) + 15, cornerView3.bounds.size};
    [headerView addSubview:cornerView3];
    
    headerView.frame = CGRectMake(0, 0, kScreenWidth, CGRectGetMaxY(cornerView3.frame) + 15);
    headerView.backgroundColor = self.view.backgroundColor;
    self.tableView.tableHeaderView = headerView;
}

- (UIView *)createCornerView1
{
    UIView *cornerView1 = [UIView new];
    cornerView1.backgroundColor = UIColor.whiteColor;
    cornerView1.layer.cornerRadius = 4;
    CGFloat cornerViewWidth = kScreenWidth - 30;
    
    UILabel * titleLb = [self createLabelWithText:@"Kaadas 2代操作菜单" color:KDSRGBColor(51, 51, 51) font:[UIFont systemFontOfSize:14] width:cornerViewWidth - 16];
    [cornerView1 addSubview:titleLb];
    [titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cornerView1.mas_top).offset(15);
        make.left.mas_equalTo(cornerView1.mas_left).offset(11);
        make.right.mas_equalTo(cornerView1.mas_right).offset(-5);
    }];
        
    UILabel *tLabel = [self createLabelWithText:@"门锁如何开启节能模式" color:KDSRGBColor(51, 51, 51) font:[UIFont systemFontOfSize:16] width:cornerViewWidth - 16];
    [cornerView1 addSubview:tLabel];
    [tLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLb.mas_bottom).offset(25);
        make.left.mas_equalTo(cornerView1.mas_left).offset(11);
        make.right.mas_equalTo(cornerView1.mas_right).offset(-5);
    }];
    
    UILabel *t1Label = [self createLabelWithText:@"① 按键区输入“*”两次" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView1 addSubview:t1Label];
    [t1Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView1.mas_left).offset(11);
        make.right.mas_equalTo(cornerView1.mas_right).offset(-5);
    }];
    UILabel *t2Label = [self createLabelWithText:@"② 输入已修改的管理密码“********”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView1 addSubview:t2Label];
    [t2Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t1Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView1.mas_left).offset(11);
        make.right.mas_equalTo(cornerView1.mas_right).offset(-5);
    }];
    UILabel *t3Label = [self createLabelWithText:@"③ 按“#”确认，" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView1 addSubview:t3Label];
    [t3Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t2Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView1.mas_left).offset(11);
        make.right.mas_equalTo(cornerView1.mas_right).offset(-5);
    }];
    UILabel *t4Label = [self createLabelWithText:@"④ 语音播报：“已进入管理模式”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView1 addSubview:t4Label];
    [t4Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t3Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView1.mas_left).offset(11);
        make.right.mas_equalTo(cornerView1.mas_right).offset(-5);
    }];
    UILabel *t5Label = [self createLabelWithText:@"⑤ 根据语音提示,按“1”，在按“9”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView1 addSubview:t5Label];
    [t5Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t4Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView1.mas_left).offset(11);
        make.right.mas_equalTo(cornerView1.mas_right).offset(-5);
    }];

    UILabel *t6Label = [self createLabelWithText:@"⑥ 语音播报“设置成功，节能模式已开启”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView1 addSubview:t6Label];
    [t6Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t5Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView1.mas_left).offset(11);
        make.right.mas_equalTo(cornerView1.mas_right).offset(-5);
    }];
    
    UILabel *tLabel2 = [self createLabelWithText:@"门锁如何关闭节能模式" color:KDSRGBColor(51, 51, 51) font:[UIFont systemFontOfSize:16] width:cornerViewWidth - 16];
    [cornerView1 addSubview:tLabel2];
    [tLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t6Label.mas_bottom).offset(30);
        make.left.mas_equalTo(cornerView1.mas_left).offset(11);
        make.right.mas_equalTo(cornerView1.mas_right).offset(-5);
    }];
    
    UILabel *t1Label2 = [self createLabelWithText:@"① 按键区输入“*”两次" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView1 addSubview:t1Label2];
    [t1Label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tLabel2.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView1.mas_left).offset(11);
        make.right.mas_equalTo(cornerView1.mas_right).offset(-5);
    }];
    UILabel *t2Label2 = [self createLabelWithText:@"② 输入已修改的管理密码“********”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView1 addSubview:t2Label2];
    [t2Label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t1Label2.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView1.mas_left).offset(11);
        make.right.mas_equalTo(cornerView1.mas_right).offset(-5);
    }];
    UILabel *t3Label3 = [self createLabelWithText:@"③ 按“#”确认，" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView1 addSubview:t3Label3];
    [t3Label3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t2Label2.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView1.mas_left).offset(11);
        make.right.mas_equalTo(cornerView1.mas_right).offset(-5);
    }];
    UILabel *t4Label4 = [self createLabelWithText:@"④ 语音播报：“已进入管理模式”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView1 addSubview:t4Label4];
    [t4Label4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t3Label3.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView1.mas_left).offset(11);
        make.right.mas_equalTo(cornerView1.mas_right).offset(-5);
    }];
    UILabel *t5Label5 = [self createLabelWithText:@"⑤ 根据语音提示,按“1”，在按“9”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView1 addSubview:t5Label5];
    [t5Label5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t4Label4.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView1.mas_left).offset(11);
        make.right.mas_equalTo(cornerView1.mas_right).offset(-5);
    }];
    UILabel *t6Label6 = [self createLabelWithText:@"⑥ 语音播报“设置成功，节能模式已关闭”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView1 addSubview:t6Label6];
    [t6Label6 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t5Label5.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView1.mas_left).offset(11);
        make.right.mas_equalTo(cornerView1.mas_right).offset(-5);
    }];
    
    cornerView1.bounds = CGRectMake(0, 0, kScreenWidth - 30, 460);
    
    return cornerView1;
}
- (UIView *)createCornerView2
{
    UIView *cornerView2 = [UIView new];
    cornerView2.backgroundColor = UIColor.whiteColor;
    cornerView2.layer.cornerRadius = 4;
    CGFloat cornerViewWidth = kScreenWidth - 30;
    
    UILabel * titleLb = [self createLabelWithText:@"Kaadas 1代操作菜单" color:KDSRGBColor(51, 51, 51) font:[UIFont systemFontOfSize:14] width:cornerViewWidth - 16];
    [cornerView2 addSubview:titleLb];
    [titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cornerView2.mas_top).offset(15);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
        
    UILabel *tLabel = [self createLabelWithText:@"门锁如何开启节能模式" color:KDSRGBColor(51, 51, 51) font:[UIFont systemFontOfSize:16] width:cornerViewWidth - 16];
    [cornerView2 addSubview:tLabel];
    [tLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLb.mas_bottom).offset(25);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    
    UILabel *t1Label = [self createLabelWithText:@"① 按键区输入“*”两次" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t1Label];
    [t1Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    UILabel *t2Label = [self createLabelWithText:@"② 输入已修改的管理密码“********”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t2Label];
    [t2Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t1Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    UILabel *t3Label = [self createLabelWithText:@"③ 按“#”确认，" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t3Label];
    [t3Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t2Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    UILabel *t4Label = [self createLabelWithText:@"④ 语音播报：“已进入管理模式”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t4Label];
    [t4Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t3Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    UILabel *t5Label = [self createLabelWithText:@"⑤ 根据语音提示,按“6”，在按“1”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t5Label];
    [t5Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t4Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    UILabel *t6Label = [self createLabelWithText:@"⑥ 语音播报“设置成功”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t6Label];
    [t6Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t5Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    
    UILabel *tLabel2 = [self createLabelWithText:@"门锁如何关闭节能模式" color:KDSRGBColor(51, 51, 51) font:[UIFont systemFontOfSize:16] width:cornerViewWidth - 16];
    [cornerView2 addSubview:tLabel2];
    [tLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t6Label.mas_bottom).offset(30);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    
    UILabel *t1Label2 = [self createLabelWithText:@"① 按键区输入“*”两次" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t1Label2];
    [t1Label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tLabel2.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    UILabel *t2Label2 = [self createLabelWithText:@"② 输入已修改的管理密码“********”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t2Label2];
    [t2Label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t1Label2.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    UILabel *t3Label3 = [self createLabelWithText:@"③ 按“#”确认，" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t3Label3];
    [t3Label3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t2Label2.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    UILabel *t4Label4 = [self createLabelWithText:@"④ 语音播报：“已进入管理模式”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t4Label4];
    [t4Label4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t3Label3.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    UILabel *t5Label5 = [self createLabelWithText:@"⑤ 根据语音提示,按“6”，在按“2”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t5Label5];
    [t5Label5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t4Label4.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    UILabel *t6Label6 = [self createLabelWithText:@"⑥ 语音播报“设置成功”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t6Label6];
    [t6Label6 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t5Label5.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    
    cornerView2.bounds = CGRectMake(0, 0, kScreenWidth - 30, 460);
    
    return cornerView2;
}
- (UIView *)createCornerView3
{
    UIView *cornerView3 = [UIView new];
    cornerView3.backgroundColor = UIColor.whiteColor;
    cornerView3.layer.cornerRadius = 4;
    CGFloat cornerViewWidth = kScreenWidth - 30;
        //  ② 当电池低于预调的电量时，为保障
    UILabel *tLabel = [self createLabelWithText:@"注：节能模式说明" color:KDSRGBColor(51, 51, 51) font:[UIFont systemFontOfSize:16] width:cornerViewWidth - 16];
    [cornerView3 addSubview:tLabel];
    [tLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cornerView3.mas_top).offset(20);
        make.left.mas_equalTo(cornerView3.mas_left).offset(11);
        make.right.mas_equalTo(cornerView3.mas_right).offset(-5);
    }];
    
    UILabel *t1Label = [self createLabelWithText:@"① 节能模式开启后，关闭人脸识别功能；节能模式关闭后，开启人脸识别功能；" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView3 addSubview:t1Label];
    [self setLabelSpace:t1Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t1Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView3.mas_left).offset(11);
        make.right.mas_equalTo(cornerView3.mas_right).offset(-5);
    }];
    UILabel *t2Label = [self createLabelWithText:@"② 当电池低于预调的电量时，为保障您更持续长久的智能进出体验，智能锁会把人脸识别功能关闭，进入节能模式，用户的指纹、密码、卡等开启方式可正常使用。若需要重新开启人脸识别功能，只需要重新更换充满的电池即可恢复。" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView3 addSubview:t2Label];
    [self setLabelSpace:t2Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t2Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t1Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView3.mas_left).offset(11);
        make.right.mas_equalTo(cornerView3.mas_right).offset(-5);
    }];
    
    
    cornerView3.bounds = CGRectMake(0, 0, kScreenWidth - 30, KDSScreenHeight > 667 ? 220 : 240);
    
    return cornerView3;
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
