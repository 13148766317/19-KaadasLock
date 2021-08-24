//
//  KDSCateyeHelpVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/5/8.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSCateyeHelpVC.h"

@interface KDSCateyeHelpVC ()

@end

@implementation KDSCateyeHelpVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationTitleLabel.text = Localized(@"help");
    
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
    NSString *tips = @"您无法添加您的猫眼，请按照以下步骤对设备进行检查： ";
    UIView *cornerView1 = [UIView new];
    cornerView1.backgroundColor = UIColor.whiteColor;
    cornerView1.layer.cornerRadius = 4;
    
    UILabel *t1Label = [self createLabelWithText:tips color:nil font:nil width:kScreenWidth - 78];
    t1Label.frame = (CGRect){24, 20, t1Label.bounds.size};
    [cornerView1 addSubview:t1Label];
    
    cornerView1.bounds = CGRectMake(0, 0, kScreenWidth - 30, t1Label.bounds.size.height + 40);
    
    return cornerView1;
}

- (UIView *)createCornerView2
{
    NSString *  tips1 = @"二维码扫描不出，请手动输 入SN和MAC；";
    NSString *  tips2 = @"如配网过程中猫眼一直语音提示配网失败，请将猫眼主机取下，靠近网关，再次添加猫眼；";
    NSString *  tips3 = @"猫眼提示配网成功，App提示配网超时，可能是配网成功消息丢失，请到设备页面刷新；";
    NSString *  tips4 = @"若出现猫眼呼叫不稳定，经常离线等现象，请检查网关、猫眼的固件版本号，进行升级版本；";
    
    UIView *cornerView2 = [UIView new];
    cornerView2.backgroundColor = UIColor.whiteColor;
    cornerView2.layer.cornerRadius = 4;
    
    CGFloat cornerViewWidth = kScreenWidth - 30;
    
    UILabel *l1 = [self createLabelWithText:@"1" color:UIColor.whiteColor font:nil width:17];
    l1.textAlignment = NSTextAlignmentCenter;
    l1.layer.masksToBounds = YES;
    l1.layer.cornerRadius = 8.5;
    l1.layer.backgroundColor = KDSRGBColor(0x1f, 0x96, 0xf7).CGColor;
    l1.frame = CGRectMake(23, 29, 17, 17);
    [cornerView2 addSubview:l1];
    UILabel *t1Label = [self createLabelWithText:tips1 color:nil font:nil width:cornerViewWidth - 72];
    t1Label.frame = CGRectMake(57, 0, cornerViewWidth - 72, 75);
    [cornerView2 addSubview:t1Label];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(57, CGRectGetMaxY(t1Label.frame), cornerViewWidth - 57, 1)];
    line1.backgroundColor = KDSRGBColor(0xea, 0xe9, 0xe9);
    [cornerView2 addSubview:line1];
    
    UILabel *l2 = [self createLabelWithText:@"2" color:UIColor.whiteColor font:nil width:17];
    l2.textAlignment = NSTextAlignmentCenter;
    l2.layer.masksToBounds = YES;
    l2.layer.cornerRadius = 8.5;
    l2.layer.backgroundColor = KDSRGBColor(0x1f, 0x96, 0xf7).CGColor;
    l2.frame = CGRectMake(23, CGRectGetMaxY(line1.frame) + 29, 17, 17);
    [cornerView2 addSubview:l2];
    UILabel *t2Label = [self createLabelWithText:tips2 color:nil font:nil width:cornerViewWidth - 72];
    t2Label.frame = CGRectMake(57, CGRectGetMaxY(line1.frame), cornerViewWidth - 72, 75);
    
    [cornerView2 addSubview:t2Label];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(57, CGRectGetMaxY(t2Label.frame), cornerViewWidth - 57, 1)];
    line2.backgroundColor = KDSRGBColor(0xea, 0xe9, 0xe9);
    [cornerView2 addSubview:line2];
    
    UILabel *l3 = [self createLabelWithText:@"3" color:UIColor.whiteColor font:nil width:17];
    l3.textAlignment = NSTextAlignmentCenter;
    l3.layer.masksToBounds = YES;
    l3.layer.cornerRadius = 8.5;
    l3.layer.backgroundColor = KDSRGBColor(0x1f, 0x96, 0xf7).CGColor;
    l3.frame = CGRectMake(23, CGRectGetMaxY(line2.frame) + 29, 17, 17);
    [cornerView2 addSubview:l3];
    UILabel *t3Label = [self createLabelWithText:tips3 color:nil font:nil width:cornerViewWidth - 72];
    t3Label.frame = CGRectMake(57, CGRectGetMaxY(line2.frame), cornerViewWidth - 72, 75);
    [cornerView2 addSubview:t3Label];
    
    UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(57, CGRectGetMaxY(t3Label.frame), cornerViewWidth - 57, 1)];
    line3.backgroundColor = KDSRGBColor(0xea, 0xe9, 0xe9);
    [cornerView2 addSubview:line3];
    
    UILabel *l4 = [self createLabelWithText:@"4" color:UIColor.whiteColor font:nil width:17];
    l4.textAlignment = NSTextAlignmentCenter;
    l4.layer.masksToBounds = YES;
    l4.layer.cornerRadius = 8.5;
    l4.layer.backgroundColor = KDSRGBColor(0x1f, 0x96, 0xf7).CGColor;
    l4.frame = CGRectMake(23, CGRectGetMaxY(line3.frame) + 29, 17, 17);
    
    [cornerView2 addSubview:l4];
    UILabel *t4Label = [self createLabelWithText:tips4 color:nil font:nil width:cornerViewWidth - 72];
    t4Label.frame = (CGRect){57, CGRectGetMaxY(line3.frame) + 20, t4Label.bounds.size};
    [cornerView2 addSubview:t4Label];
    
    cornerView2.bounds = CGRectMake(0, 0, cornerViewWidth, CGRectGetMaxY(t4Label.frame) + 20);
    
    return cornerView2;
}

- (UIView *)createCornerView3
{
    NSString *  tips = @"如果您已经完成以上操作，仍然无法成功添加设备，可以在“我的-用户反馈”向我们的工作人员进行反馈。";
    UIView *cornerView3 = [UIView new];
    cornerView3.backgroundColor = UIColor.whiteColor;
    cornerView3.layer.cornerRadius = 4;
    UILabel *tLabel = [self createLabelWithText:tips color:nil font:nil width:kScreenWidth - 78];
    tLabel.frame = (CGRect){24, 20, tLabel.bounds.size};
    [cornerView3 addSubview:tLabel];
    
    cornerView3.bounds = CGRectMake(0, 0, kScreenWidth - 30, tLabel.bounds.size.height + 40);
    
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



@end
