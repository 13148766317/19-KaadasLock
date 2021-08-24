//
//  KDSAddFaceRecognitionStep2VC.m
//  KaadasLock
//
//  Created by zhaona on 2020/5/12.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAddFaceRecognitionStep2VC.h"
#import "KDSWifiLockPwdListVC.h"

@interface KDSAddFaceRecognitionStep2VC ()

@end

///label之间多行显示的行间距
#define labelWidth  10

@implementation KDSAddFaceRecognitionStep2VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = @"添加面容识别";
    [self setUI];
}

-(void)setUI
{
    ///第一步
    UILabel * tipMsgLabe1 = [UILabel new];
    tipMsgLabe1.text = @"第二步：开始添加用户人脸";
    tipMsgLabe1.font = [UIFont systemFontOfSize:18];
    tipMsgLabe1.textColor = UIColor.blackColor;
    tipMsgLabe1.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe1];
    [tipMsgLabe1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(KDSScreenHeight > 667 ? 34 : 20);
        make.height.mas_equalTo(20);
        make.left.equalTo(self.view.mas_left).offset(30);
        make.right.equalTo(self.view.mas_right).offset(-30);
    }];
                                
    UILabel *tipsLb1 = [self createLabelWithText:@"① 根据语音提示，按“1”选择“用户设置”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:14] width:kScreenWidth - 60];
    [self.view addSubview:tipsLb1];
    [tipsLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipMsgLabe1.mas_bottom).offset(16);
        make.left.equalTo(self.view.mas_left).offset(30);
        make.right.equalTo(self.view.mas_right).offset(-30);
    }];
    UILabel *tipsLb2 = [self createLabelWithText:@"② 再按“1”选择“添加用户人脸”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:14] width:kScreenWidth - 60];
    [self.view addSubview:tipsLb2];
    [tipsLb2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsLb1.mas_bottom).offset(10);
        make.left.equalTo(self.view.mas_left).offset(30);
        make.right.equalTo(self.view.mas_right).offset(-30);
    }];
    UILabel *tipsLb3 = [self createLabelWithText:@"③ 根据语音提示，再输入2位编号，以“#”号确认" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:14] width:kScreenWidth - 60];
    [self.view addSubview:tipsLb3];
    [tipsLb3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsLb2.mas_bottom).offset(10);
        make.left.equalTo(self.view.mas_left).offset(30);
        make.right.equalTo(self.view.mas_right).offset(-30);
    }];
    UILabel *tipsLb4 = [self createLabelWithText:@"④ 开始录入，用户距离门锁60~80cm(约一臂距离)的位置站立，并请正视门锁，稍等片刻即可“添加成功”;" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:14] width:kScreenWidth - 60];
    [self setLabelSpace:tipsLb4 withSpace:labelWidth withFont:[UIFont systemFontOfSize:14]];
    [self.view addSubview:tipsLb4];
    [tipsLb4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsLb3.mas_bottom).offset(10);
        make.left.equalTo(self.view.mas_left).offset(30);
        make.right.equalTo(self.view.mas_right).offset(-30);
    }];
    UILabel *tipsLb5 = [self createLabelWithText:@"⑤ 若添加失败，请再次添加录入，并根据语音提示，调整站立位置，稍等片刻即可“添加成功”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:14] width:kScreenWidth - 60];
    [self setLabelSpace:tipsLb5 withSpace:labelWidth withFont:[UIFont systemFontOfSize:14]];
    [self.view addSubview:tipsLb5];
    [tipsLb5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsLb4.mas_bottom).offset(10);
        make.left.equalTo(self.view.mas_left).offset(30);
        make.right.equalTo(self.view.mas_right).offset(-30);
    }];
    
    UIImageView * tipImg = [UIImageView new];
    tipImg.image = [UIImage imageNamed:@"lockOperateKeyboard"];
    [self.view addSubview:tipImg];
    [tipImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsLb5.mas_bottom).offset(34);
        make.centerX.equalTo(self.view.mas_centerX);
        make.size.equalTo(@(tipImg.image.size));
    }];
    
    UIButton * completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [completeBtn setTitle:@"完成" forState:UIControlStateNormal];
    [completeBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [completeBtn addTarget:self action:@selector(completeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    completeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    completeBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    completeBtn.layer.masksToBounds = YES;
    completeBtn.layer.cornerRadius = 20;
    [self.view addSubview:completeBtn];
    [completeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(KDSScreenHeight <= 667 ? -46 : -66);
    }];
    
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


-(void)completeBtnClick:(UIButton *)sender
{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[KDSWifiLockPwdListVC class]]) {
            KDSWifiLockPwdListVC *A =(KDSWifiLockPwdListVC *)controller;
            [self.navigationController popToViewController:A animated:YES];
        }
    }
    
}

@end
