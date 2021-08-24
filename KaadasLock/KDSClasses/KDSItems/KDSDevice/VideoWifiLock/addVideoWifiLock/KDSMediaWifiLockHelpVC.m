//
//  KDSMediaWifiLockHelpVC.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/11/9.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSMediaWifiLockHelpVC.h"

@interface KDSMediaWifiLockHelpVC ()

@end

///label之间多行显示的行间距
#define labelWidth  10

@implementation KDSMediaWifiLockHelpVC


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
    
    UIView *cornerView22 = [self createCornerView22];
    cornerView22.frame = (CGRect){15, CGRectGetMaxY(cornerView2.frame) + 15, cornerView22.bounds.size};
    [headerView addSubview:cornerView22];
    
    UIView *cornerView33 = [self createCornerView33];
    cornerView33.frame = (CGRect){15, CGRectGetMaxY(cornerView22.frame) + 15, cornerView33.bounds.size};
    [headerView addSubview:cornerView33];
    
    UIView *cornerView3 = [self createCornerView3];
    cornerView3.frame = (CGRect){15, CGRectGetMaxY(cornerView33.frame) + 15, cornerView3.bounds.size};
    [headerView addSubview:cornerView3];
    
    UIView *cornerView44 = [self createCornerView44];
    cornerView44.frame = (CGRect){15, CGRectGetMaxY(cornerView3.frame) + 15, cornerView44.bounds.size};
    [headerView addSubview:cornerView44];
    
    UIView *cornerView5 = [self createCornerView5];
    cornerView5.frame = (CGRect){15, CGRectGetMaxY(cornerView44.frame) + 15, cornerView5.bounds.size};
    [headerView addSubview:cornerView5];
    
    UIView *cornerView6 = [self createCornerView6];
    cornerView6.frame = (CGRect){15, CGRectGetMaxY(cornerView5.frame) + 15, cornerView6.bounds.size};
    [headerView addSubview:cornerView6];
    
    headerView.frame = CGRectMake(0, 0, kScreenWidth, CGRectGetMaxY(cornerView6.frame) + 15);
    headerView.backgroundColor = self.view.backgroundColor;
    self.tableView.tableHeaderView = headerView;
}

- (UIView *)createCornerView1
{
    NSString *tips = @"我是新手，怎么配置凯迪仕Wi-Fi 门锁? ";
    UIView *cornerView1 = [UIView new];
    cornerView1.backgroundColor = UIColor.whiteColor;
    cornerView1.layer.cornerRadius = 4;
    
    UILabel *t1Label = [self createLabelWithText:tips color:nil font:nil width:kScreenWidth - 78];
    t1Label.frame = (CGRect){11, 20, t1Label.bounds.size};
    [cornerView1 addSubview:t1Label];
    
    cornerView1.bounds = CGRectMake(0, 0, kScreenWidth - 30, t1Label.bounds.size.height + 40);
    
    return cornerView1;
}

- (UIView *)createCornerView2
{
    UIView *cornerView2 = [UIView new];
    cornerView2.backgroundColor = UIColor.whiteColor;
    cornerView2.layer.cornerRadius = 4;
    CGFloat cornerViewWidth = kScreenWidth - 30;
    
    UILabel *t1Label = [self createLabelWithText:@"配置前确认: " color:KDSRGBColor(51, 51, 51) font:[UIFont systemFontOfSize:16] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t1Label];
    [t1Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cornerView2.mas_top).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    
    UILabel *t2Label = [self createLabelWithText:@"① 确认门锁已安装" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t2Label];
    [t2Label mas_makeConstraints:^(MASConstraintMaker *make) {
           make.top.mas_equalTo(t1Label.mas_bottom).offset(10);
           make.left.mas_equalTo(cornerView2.mas_left).offset(11);
           make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
       }];
    
    UILabel *t3Label = [self createLabelWithText:@"② 推开门锁后面板电池盖（后面板上方位置，用力向上推开），安装上随包配送的锂电池；" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [self setLabelSpace:t3Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [cornerView2 addSubview:t3Label];
    [t3Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t2Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    
    UILabel *t4Label = [self createLabelWithText:@"③ 请确保锂电池电量充足，请按电池指向确保电池正负安装正确；" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [self setLabelSpace:t4Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [cornerView2 addSubview:t4Label];
    [t4Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t3Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    
    UILabel *t5Label = [self createLabelWithText:@"④ 当门锁出现低电量报警时，请及时更换电池；" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t5Label];
    [t5Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t4Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
                                
    UILabel *t66Label = [self createLabelWithText:@"⑤ 请确保家里的WiFi网络（仅支持2.4G网络，后缀是_5G的不支持）能正常使用，请将手机连接到该WiFi网络;" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [self setLabelSpace:t66Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [cornerView2 addSubview:t66Label];
    [t66Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t5Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
          
    cornerView2.bounds = CGRectMake(0, 0, cornerViewWidth, KDSScreenHeight > 667 ? 250 : 270);
    
    return cornerView2;
}
- (UIView *)createCornerView22
{
    UIView *cornerView2 = [UIView new];
    cornerView2.backgroundColor = UIColor.whiteColor;
    cornerView2.layer.cornerRadius = 4;
    CGFloat cornerViewWidth = kScreenWidth - 30;
    
    UILabel *t1Label = [self createLabelWithText:@"第一步：进行门锁的激活操作：" color:KDSRGBColor(51, 51, 51) font:[UIFont systemFontOfSize:16] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t1Label];
    [t1Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cornerView2.mas_top).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
            
    UILabel *t2Label = [self createLabelWithText:@"① 微信搜索【凯迪仕智能锁】公众号并关注" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t2Label];
    [t2Label mas_makeConstraints:^(MASConstraintMaker *make) {
           make.top.mas_equalTo(t1Label.mas_bottom).offset(10);
           make.left.mas_equalTo(cornerView2.mas_left).offset(11);
           make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
       }];
    
    UILabel *t3Label = [self createLabelWithText:@"② 进入公众号－【售后服务】，点击【产品激活】" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t3Label];
    [t3Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t2Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    
    UILabel *t4Label = [self createLabelWithText:@"③ 扫描包装盒产品序列号，获取激活码" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t4Label];
    [t4Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t3Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    
    UILabel *t5Label = [self createLabelWithText:@"④ 唤醒门锁，输入激活码，按“＃”确认" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t5Label];
    [t5Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t4Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    
          
    cornerView2.bounds = CGRectMake(0, 0, cornerViewWidth, 150);
    
    return cornerView2;
}
- (UIView *)createCornerView33
{
    UIView *cornerView2 = [UIView new];
    cornerView2.backgroundColor = UIColor.whiteColor;
    cornerView2.layer.cornerRadius = 4;
    CGFloat cornerViewWidth = kScreenWidth - 30;
    
    UILabel *t1Label = [self createLabelWithText:@"第二步：修改初始管理员密码：" color:KDSRGBColor(51, 51, 51) font:[UIFont systemFontOfSize:16] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t1Label];
    [t1Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cornerView2.mas_top).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
            
    UILabel *t2Label = [self createLabelWithText:@"① 用手触碰按键区，唤醒门锁，确保门锁数字键盘灯亮" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [self setLabelSpace:t2Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [cornerView2 addSubview:t2Label];
    [t2Label mas_makeConstraints:^(MASConstraintMaker *make) {
           make.top.mas_equalTo(t1Label.mas_bottom).offset(10);
           make.left.mas_equalTo(cornerView2.mas_left).offset(11);
           make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
       }];
    
    UILabel *t3Label = [self createLabelWithText:@"② 按键区，输入“*”两次，即“**”；" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t3Label];
    [t3Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t2Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    UILabel *t4Label = [self createLabelWithText:@"③ 输入初始管理员密码“12345678”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
//    [self setLabelSpace:t4Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [cornerView2 addSubview:t4Label];
    [t4Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t3Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    
    UILabel *t5Label = [self createLabelWithText:@"④ 按“#”确认" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
//    [self setLabelSpace:t5Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [cornerView2 addSubview:t5Label];
    [t5Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t4Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    
    UILabel *t6Label = [self createLabelWithText:@"⑤ 语音播报“已进入管理模式，请修改管理密码”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [self setLabelSpace:t6Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [cornerView2 addSubview:t6Label];
    [t6Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t5Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    
    UILabel *t7Label = [self createLabelWithText:@"⑥ 输入新设定的管理密码，按“#”确认；" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
       [cornerView2 addSubview:t7Label];
       [t7Label mas_makeConstraints:^(MASConstraintMaker *make) {
           make.top.mas_equalTo(t6Label.mas_bottom).offset(10);
           make.left.mas_equalTo(cornerView2.mas_left).offset(11);
           make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
       }];
    UILabel *t8Label = [self createLabelWithText:@"⑦ 再次输入刚才的管理员密码，按“#”完成修改；" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
       [cornerView2 addSubview:t8Label];
       [t8Label mas_makeConstraints:^(MASConstraintMaker *make) {
           make.top.mas_equalTo(t7Label.mas_bottom).offset(10);
           make.left.mas_equalTo(cornerView2.mas_left).offset(11);
           make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
       }];
    
    cornerView2.bounds = CGRectMake(0, 0, cornerViewWidth, KDSScreenHeight > 667 ? 220 : 230);
    
    return cornerView2;
}

- (UIView *)createCornerView3
{
    UIView *cornerView3 = [UIView new];
    cornerView3.backgroundColor = UIColor.whiteColor;
    cornerView3.layer.cornerRadius = 4;
    CGFloat cornerViewWidth = kScreenWidth - 30;
        
    UILabel *tLabel = [self createLabelWithText:@"第三步：门锁首次配网" color:KDSRGBColor(51, 51, 51) font:[UIFont systemFontOfSize:16] width:cornerViewWidth - 16];
    [cornerView3 addSubview:tLabel];
    [tLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cornerView3.mas_top).offset(10);
        make.left.mas_equalTo(cornerView3.mas_left).offset(11);
        make.right.mas_equalTo(cornerView3.mas_right).offset(-5);
    }];
                                
    UILabel *t1Label = [self createLabelWithText:@"① 在APP添加设备页面，选择K20-V可视猫眼智能锁或点击右上角扫描图标，扫描对应门锁后面板的配网二维码，进行配网；" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView3 addSubview:t1Label];
    [self setLabelSpace:t1Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t1Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView3.mas_left).offset(11);
        make.right.mas_equalTo(cornerView3.mas_right).offset(-5);
    }];
    UILabel *t22Label = [self createLabelWithText:@"② 进入门锁配网准备页面，点击“门锁安装好，去配网”按钮" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView3 addSubview:t22Label];
    [self setLabelSpace:t22Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t22Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t1Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView3.mas_left).offset(11);
        make.right.mas_equalTo(cornerView3.mas_right).offset(-5);
    }];
    UILabel *t2Label = [self createLabelWithText:@"③ 点击“门锁已激活”按钮（未激活请参考门锁的激活操作）" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView3 addSubview:t2Label];
    [self setLabelSpace:t2Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t2Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t22Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView3.mas_left).offset(11);
        make.right.mas_equalTo(cornerView3.mas_right).offset(-5);
    }];
    UILabel *t3Label = [self createLabelWithText:@"④ 根据提示，进入管理模式，按“4”进入配网状态；" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView3 addSubview:t3Label];
    [self setLabelSpace:t3Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t3Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t2Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView3.mas_left).offset(11);
        make.right.mas_equalTo(cornerView3.mas_right).offset(-5);
    }];
    UILabel *t4Label = [self createLabelWithText:@"⑤ 输入WiFi密码（确保此WiFi是2.4G频段，暂时不支持5G频段），点击下一步；" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView3 addSubview:t4Label];
    [self setLabelSpace:t4Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t4Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t3Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView3.mas_left).offset(11);
        make.right.mas_equalTo(cornerView3.mas_right).offset(-5);
    }];
    UILabel *t5Label = [self createLabelWithText:@"⑥ 将生成的二维码放到门锁前面板的镜头前10-15CM扫描，等听到“扫描成功，配网中” 语音后，根据语音提示，点击下一步（若提示配网失败，请重新进入管理模式，按4配网）" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView3 addSubview:t5Label];
    [self setLabelSpace:t5Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t5Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t4Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView3.mas_left).offset(11);
        make.right.mas_equalTo(cornerView3.mas_right).offset(-5);
    }];
    UILabel *t6Label = [self createLabelWithText:@"⑦ WiFi连接成功后，请输入管理员密码，用于开启临时密码功能；" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView3 addSubview:t6Label];
    [self setLabelSpace:t6Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t6Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t5Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView3.mas_left).offset(11);
        make.right.mas_equalTo(cornerView3.mas_right).offset(-5);
    }];
    UILabel *t7Label = [self createLabelWithText:@"⑧ 管理员密码验证成功后，可以给门锁起一个名字，完成门锁配网。" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView3 addSubview:t7Label];
    [self setLabelSpace:t7Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t7Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t6Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView3.mas_left).offset(11);
        make.right.mas_equalTo(cornerView3.mas_right).offset(-5);
    }];
    
    cornerView3.bounds = CGRectMake(0, 0, kScreenWidth - 30, KDSScreenHeight > 667 ? 440 : 510);
    
    return cornerView3;
}

-(UIView *)createCornerView44
{
    UIView *cornerView44 = [UIView new];
    cornerView44.backgroundColor = UIColor.whiteColor;
    cornerView44.layer.cornerRadius = 4;
    CGFloat cornerViewWidth = kScreenWidth - 30;
    UILabel *tLabel = [self createLabelWithText:@"门锁都支持哪些Wi-Fi ? " color:KDSRGBColor(51, 51, 51) font:[UIFont systemFontOfSize:16] width:cornerViewWidth - 16];
    [cornerView44 addSubview:tLabel];
    [tLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cornerView44.mas_top).offset(10);
        make.left.mas_equalTo(cornerView44.mas_left).offset(11);
        make.right.mas_equalTo(cornerView44.mas_right).offset(-5);
    }];
                                
    UILabel *t1Label = [self createLabelWithText:@"① 门锁目前支持2.4G的WiFi，暂不支持5G频段的WiFi" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView44 addSubview:t1Label];
    [t1Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView44.mas_left).offset(11);
        make.right.mas_equalTo(cornerView44.mas_right).offset(-5);
    }];
    UILabel *t2Label = [self createLabelWithText:@"② 如果您的路由器同时打开了2.4G和5G的WiFi，建议两者使用不同的WiFi名称，以免影响门锁联网效果和视频对讲效果" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView44 addSubview:t2Label];
    [self setLabelSpace:t2Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t2Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t1Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView44.mas_left).offset(11);
        make.right.mas_equalTo(cornerView44.mas_right).offset(-5);
    }];
    UILabel *t3Label = [self createLabelWithText:@"③ 门锁暂不支持同一WiFi名称漫游的公共WiFi环境，比如很多公司、酒店等公共场合的WiFi环境" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView44 addSubview:t3Label];
    [self setLabelSpace:t3Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t3Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t2Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView44.mas_left).offset(11);
        make.right.mas_equalTo(cornerView44.mas_right).offset(-5);
    }];
    UILabel *t4Label = [self createLabelWithText:@"④ 如果需要在上述公共WiFi环境下使用，可以安装一台拥有独立WiFi名称的路由器，并将该路由器接入公共WiFi网络" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView44 addSubview:t4Label];
    [self setLabelSpace:t4Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t4Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t3Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView44.mas_left).offset(11);
        make.right.mas_equalTo(cornerView44.mas_right).offset(-5);
    }];
    UILabel *t5Label = [self createLabelWithText:@"⑤ 如使用连接的家庭WiFi无密码，将不允许配网，请设置密码后再添加门锁；" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView44 addSubview:t5Label];
    [self setLabelSpace:t5Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t5Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t4Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView44.mas_left).offset(11);
        make.right.mas_equalTo(cornerView44.mas_right).offset(-5);
    }];
    
    cornerView44.bounds = CGRectMake(0, 0, kScreenWidth - 30, KDSScreenHeight > 667 ? 280 : 330);
    
    
    return cornerView44;
}

-(UIView *)createCornerView5
{
    UIView *cornerView5 = [UIView new];
    cornerView5.backgroundColor = UIColor.whiteColor;
    cornerView5.layer.cornerRadius = 4;
    CGFloat cornerViewWidth = kScreenWidth - 30;
    UILabel *tLabel = [self createLabelWithText:@"检查路由器设置 " color:KDSRGBColor(51, 51, 51) font:[UIFont systemFontOfSize:16] width:cornerViewWidth - 16];
    [cornerView5 addSubview:tLabel];
    [tLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cornerView5.mas_top).offset(10);
        make.left.mas_equalTo(cornerView5.mas_left).offset(11);
        make.right.mas_equalTo(cornerView5.mas_right).offset(-5);
    }];
    
    UILabel *t1Label = [self createLabelWithText:@"① 确认路由器设置的Wi-Fi名称及密码没有使用特殊字符" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView5 addSubview:t1Label];
    [self setLabelSpace:t1Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t1Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView5.mas_left).offset(11);
        make.right.mas_equalTo(cornerView5.mas_right).offset(-5);
    }];
    UILabel *t2Label = [self createLabelWithText:@"② 确认路由器的Wi-Fi网络的安全认证类型是WPA-PSK或WPA2-PSK，若不是请修改为WPA-PSK或WPA2-PSK" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView5 addSubview:t2Label];
    [self setLabelSpace:t2Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t2Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t1Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView5.mas_left).offset(11);
        make.right.mas_equalTo(cornerView5.mas_right).offset(-5);
    }];
    UILabel *t3Label = [self createLabelWithText:@"③ 确认路由器的Wi-Fi网络是否设置了白名单、黑名单、MAC地址过滤" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView5 addSubview:t3Label];
    [self setLabelSpace:t3Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t3Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t2Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView5.mas_left).offset(11);
        make.right.mas_equalTo(cornerView5.mas_right).offset(-5);
    }];
    UILabel *t4Label = [self createLabelWithText:@"④ 如果您的路由器已经长时间工作，建议重启路由器后重试" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView5 addSubview:t4Label];
    [self setLabelSpace:t4Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t4Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t3Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView5.mas_left).offset(11);
        make.right.mas_equalTo(cornerView5.mas_right).offset(-5);
    }];
    
    cornerView5.bounds = CGRectMake(0, 0, kScreenWidth - 30, KDSScreenHeight > 667 ? 200 : 270);
    
    return cornerView5;
    
}
-(UIView *)createCornerView6
{
    UIView *cornerView6 = [UIView new];
    cornerView6.backgroundColor = UIColor.whiteColor;
    cornerView6.layer.cornerRadius = 4;
    CGFloat cornerViewWidth = kScreenWidth - 30;
    UILabel *tLabel = [self createLabelWithText:@"以上步骤都正常，仍配网失败 " color:KDSRGBColor(51, 51, 51) font:[UIFont systemFontOfSize:16] width:cornerViewWidth - 16];
    [cornerView6 addSubview:tLabel];
    [tLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cornerView6.mas_top).offset(10);
        make.left.mas_equalTo(cornerView6.mas_left).offset(11);
        make.right.mas_equalTo(cornerView6.mas_right).offset(-5);
    }];
                                
    UILabel *t1Label = [self createLabelWithText:@"① 尝试关闭手机Wi-Fi并再次打开后重试" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView6 addSubview:t1Label];
    [t1Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView6.mas_left).offset(11);
        make.right.mas_equalTo(cornerView6.mas_right).offset(-5);
    }];
    UILabel *t2Label = [self createLabelWithText:@"② 重新启动手机系统后重试" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView6 addSubview:t2Label];
    [t2Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t1Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView6.mas_left).offset(11);
        make.right.mas_equalTo(cornerView6.mas_right).offset(-5);
    }];
    cornerView6.bounds = CGRectMake(0, 0, kScreenWidth - 30, 90);
    return cornerView6;
    
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
