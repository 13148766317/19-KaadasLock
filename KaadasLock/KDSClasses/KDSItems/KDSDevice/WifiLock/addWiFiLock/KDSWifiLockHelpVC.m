//
//  KDSWifiLockHelpVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/1/14.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSWifiLockHelpVC.h"

@interface KDSWifiLockHelpVC ()

@end

///label之间多行显示的行间距
#define labelWidth  10

@implementation KDSWifiLockHelpVC

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
    
    UIView *cornerView4 = [self createCornerView4];
    cornerView4.frame = (CGRect){15, CGRectGetMaxY(cornerView3.frame) + 15, cornerView4.bounds.size};
    [headerView addSubview:cornerView4];
    
    UIView *cornerView44 = [self createCornerView44];
    cornerView44.frame = (CGRect){15, CGRectGetMaxY(cornerView4.frame) + 15, cornerView44.bounds.size};
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
    
    UILabel *t3Label = [self createLabelWithText:@"② 建议在门锁后面板装入用本产品配置的碱性电池或其他符合规格的干电 池4节或8节，确保门锁正常使用Wi-Fi联网功能" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [self setLabelSpace:t3Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [cornerView2 addSubview:t3Label];
    [t3Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t2Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    
    UILabel *t4Label = [self createLabelWithText:@"③ 当门锁出现低电量报警时，请及时更换掉电池，确保电池正负极安装正确" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [self setLabelSpace:t4Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [cornerView2 addSubview:t4Label];
    [t4Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t3Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    
    UILabel *t5Label = [self createLabelWithText:@"④ 确认门锁后面板Wi-Fi 模块已插紧，不松动" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t5Label];
    [t5Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t4Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
                                
    UILabel *t66Label = [self createLabelWithText:@"⑤ 确保手机蓝牙已打开，家里Wi-Fi网络(2.4G网络) 可正常使用，并且手机已经连接该网络" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [self setLabelSpace:t66Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [cornerView2 addSubview:t66Label];
    [t66Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t5Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
          
    cornerView2.bounds = CGRectMake(0, 0, cornerViewWidth, KDSScreenHeight > 667 ? 270 : 270);
    
    return cornerView2;
}
- (UIView *)createCornerView22
{
    UIView *cornerView2 = [UIView new];
    cornerView2.backgroundColor = UIColor.whiteColor;
    cornerView2.layer.cornerRadius = 4;
    CGFloat cornerViewWidth = kScreenWidth - 30;
    
    UILabel *t1Label = [self createLabelWithText:@"进行门锁的激活操作: " color:KDSRGBColor(51, 51, 51) font:[UIFont systemFontOfSize:16] width:cornerViewWidth - 16];
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
    
    UILabel *t1Label = [self createLabelWithText:@"门锁首次配网: " color:KDSRGBColor(51, 51, 51) font:[UIFont systemFontOfSize:16] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t1Label];
    [t1Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cornerView2.mas_top).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
            
    UILabel *t2Label = [self createLabelWithText:@"① 在[添加设备页面]， 点击右上角图标，扫描对应电池盖上的配网二维码，进行配网" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [self setLabelSpace:t2Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [cornerView2 addSubview:t2Label];
    [t2Label mas_makeConstraints:^(MASConstraintMaker *make) {
           make.top.mas_equalTo(t1Label.mas_bottom).offset(10);
           make.left.mas_equalTo(cornerView2.mas_left).offset(11);
           make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
       }];
    
    UILabel *t3Label = [self createLabelWithText:@"② 请确保手机已打开蓝牙,并优先连接上2.4G Wi-Fi，" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView2 addSubview:t3Label];
    [t3Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t2Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    UILabel *t4Label = [self createLabelWithText:@"③ 用手触碰按键区，唤醒门锁 ，确保门锁数字键盘灯亮，请将手机尽量靠近门锁（手机、门锁、路由器的最佳适配范围是5米)，手机蓝牙与门锁蓝牙配对中" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [self setLabelSpace:t4Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [cornerView2 addSubview:t4Label];
    [t4Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t3Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    
    UILabel *t5Label = [self createLabelWithText:@"④ 门锁验证-输入配置门锁当前管理密码进行验证，验证通过，跳转下一步" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [self setLabelSpace:t5Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [cornerView2 addSubview:t5Label];
    [t5Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t4Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    
    UILabel *t6Label = [self createLabelWithText:@"⑤ 输入Wi-Fi 密码， (确保此处选择的Wi-Fi与手机已连接的Wi-Fi是同一个2.4G Wi-Fi网络)，点击[下一步]" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [self setLabelSpace:t6Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [cornerView2 addSubview:t6Label];
    [t6Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t5Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView2.mas_left).offset(11);
        make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
    }];
    
    UILabel *t7Label = [self createLabelWithText:@"⑥ 在 [连接设备]，等待设备连接成功" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
       [cornerView2 addSubview:t7Label];
       [t7Label mas_makeConstraints:^(MASConstraintMaker *make) {
           make.top.mas_equalTo(t6Label.mas_bottom).offset(10);
           make.left.mas_equalTo(cornerView2.mas_left).offset(11);
           make.right.mas_equalTo(cornerView2.mas_right).offset(-5);
       }];
    
          
    cornerView2.bounds = CGRectMake(0, 0, cornerViewWidth, KDSScreenHeight > 667 ? 330 : 340);
    
    return cornerView2;
}

- (UIView *)createCornerView3
{
    UIView *cornerView3 = [UIView new];
    cornerView3.backgroundColor = UIColor.whiteColor;
    cornerView3.layer.cornerRadius = 4;
    CGFloat cornerViewWidth = kScreenWidth - 30;
        
    UILabel *tLabel = [self createLabelWithText:@"无法发现待配网门锁? " color:KDSRGBColor(51, 51, 51) font:[UIFont systemFontOfSize:16] width:cornerViewWidth - 16];
    [cornerView3 addSubview:tLabel];
    [tLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cornerView3.mas_top).offset(10);
        make.left.mas_equalTo(cornerView3.mas_left).offset(11);
        make.right.mas_equalTo(cornerView3.mas_right).offset(-5);
    }];
                                
    UILabel *t1Label = [self createLabelWithText:@"① 用手触碰按键区，唤醒门锁 ，确保门锁数字键盘灯亮" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView3 addSubview:t1Label];
    [self setLabelSpace:t1Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t1Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView3.mas_left).offset(11);
        make.right.mas_equalTo(cornerView3.mas_right).offset(-5);
    }];
    UILabel *t22Label = [self createLabelWithText:@"② 确保手机蓝牙已打开" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView3 addSubview:t22Label];
    [t22Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t1Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView3.mas_left).offset(11);
        make.right.mas_equalTo(cornerView3.mas_right).offset(-5);
    }];
    UILabel *t2Label = [self createLabelWithText:@"③ 门锁后面板Wi-Fi 模块已插紧，不松动" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView3 addSubview:t2Label];
    [t2Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t22Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView3.mas_left).offset(11);
        make.right.mas_equalTo(cornerView3.mas_right).offset(-5);
    }];
    UILabel *t3Label = [self createLabelWithText:@"③ 为门锁配网过程中，针对苹果手机，App会根据系统情况弹窗提示您打开“Wi-Fi开关”， “系统位置服务”和“应用定位权限”，请务必打开以保证完成配网过程" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView3 addSubview:t3Label];
    [self setLabelSpace:t3Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t3Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t2Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView3.mas_left).offset(11);
        make.right.mas_equalTo(cornerView3.mas_right).offset(-5);
    }];
    UILabel *t4Label = [self createLabelWithText:@"④ 对于安卓手机，如果没有任何弹窗提示，请手动检查并打开:“系统位置服务”在:设置->高级(更多)设置->系统安全->位置信息,“应用定位权限”在系统的应用权限管理界面" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView3 addSubview:t4Label];
    [self setLabelSpace:t4Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t4Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t3Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView3.mas_left).offset(11);
        make.right.mas_equalTo(cornerView3.mas_right).offset(-5);
    }];
    
    cornerView3.bounds = CGRectMake(0, 0, kScreenWidth - 30, KDSScreenHeight > 667 ? 290 : 300);
    
    return cornerView3;
}
-(UIView *)createCornerView4
{
    UIView *cornerView4 = [UIView new];
    cornerView4.backgroundColor = UIColor.whiteColor;
    cornerView4.layer.cornerRadius = 4;
    CGFloat cornerViewWidth = kScreenWidth - 30;
    UILabel *tLabel = [self createLabelWithText:@"选择其他配网方式 " color:KDSRGBColor(51, 51, 51) font:[UIFont systemFontOfSize:16] width:cornerViewWidth - 16];
    [cornerView4 addSubview:tLabel];
    [tLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cornerView4.mas_top).offset(10);
        make.left.mas_equalTo(cornerView4.mas_left).offset(11);
        make.right.mas_equalTo(cornerView4.mas_right).offset(-5);
    }];
    
    UILabel *t1Label = [self createLabelWithText:@"触摸门锁前面数字面板，唤醒门锁，门锁进入配网模式:" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView4 addSubview:t1Label];
    [t1Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView4.mas_left).offset(11);
        make.right.mas_equalTo(cornerView4.mas_right).offset(-5);
    }];
    UILabel *t2Label = [self createLabelWithText:@"① 按键区先输入“*”两次" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView4 addSubview:t2Label];
    [t2Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t1Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView4.mas_left).offset(11);
        make.right.mas_equalTo(cornerView4.mas_right).offset(-5);
    }];
    UILabel *t3Label = [self createLabelWithText:@"② 输入门锁管理密码：“******* ”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView4 addSubview:t3Label];
    [t3Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t2Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView4.mas_left).offset(11);
        make.right.mas_equalTo(cornerView4.mas_right).offset(-5);
    }];
    UILabel *t4Label = [self createLabelWithText:@"③ 按“#”确认，语音播报“已进入管理模式”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView4 addSubview:t4Label];
    [t4Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t3Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView4.mas_left).offset(11);
        make.right.mas_equalTo(cornerView4.mas_right).offset(-5);
    }];
    UILabel *t5Label = [self createLabelWithText:@"④ 根据语音提示：按[4] 选择 “扩展模式”，再按[1] 选择 “加入网络”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView4 addSubview:t5Label];
    [self setLabelSpace:t5Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t5Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t4Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView4.mas_left).offset(11);
        make.right.mas_equalTo(cornerView4.mas_right).offset(-5);
    }];
    UILabel *t6Label = [self createLabelWithText:@"⑤ 语音播报：“配网中，请稍后”" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView4 addSubview:t6Label];
    [self setLabelSpace:t6Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t6Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t5Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView4.mas_left).offset(11);
        make.right.mas_equalTo(cornerView4.mas_right).offset(-5);
    }];
    
    cornerView4.bounds = CGRectMake(0, 0, kScreenWidth - 30, 220);
    
    return cornerView4;
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
                                
    UILabel *t1Label = [self createLabelWithText:@"① 门锁目前支持2.4G Wi-Fi， 暂不支持5G Wi-Fi" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView44 addSubview:t1Label];
    [t1Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView44.mas_left).offset(11);
        make.right.mas_equalTo(cornerView44.mas_right).offset(-5);
    }];
    UILabel *t2Label = [self createLabelWithText:@"② 如果您的路由器同时打开了2.4G和5G的Wi-Fi，建议两者使用不同的Wi-Fi名称，以免影响门锁联网效果" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView44 addSubview:t2Label];
    [self setLabelSpace:t2Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t2Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t1Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView44.mas_left).offset(11);
        make.right.mas_equalTo(cornerView44.mas_right).offset(-5);
    }];
    UILabel *t3Label = [self createLabelWithText:@"③ 门锁暂不支持同一Wi-Fi名称漫游的公共Wi-Fi环境，比如很多公司、酒店等公共场合的Wi-Fi环境" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView44 addSubview:t3Label];
    [self setLabelSpace:t3Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t3Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t2Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView44.mas_left).offset(11);
        make.right.mas_equalTo(cornerView44.mas_right).offset(-5);
    }];
    UILabel *t4Label = [self createLabelWithText:@"④ 如果需要在上述公共Wi-Fi环境下使用，可以安装一台拥有独立Wi-Fi名称的路由器，并将该路由器接入公共Wi-Fi 网络" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView44 addSubview:t4Label];
    [self setLabelSpace:t4Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t4Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t3Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView44.mas_left).offset(11);
        make.right.mas_equalTo(cornerView44.mas_right).offset(-5);
    }];
    UILabel *t5Label = [self createLabelWithText:@"⑤ 如使用连接的家庭Wi-Fi无密码，可在App端输入密码12345678，进行连网" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:13] width:cornerViewWidth - 16];
    [cornerView44 addSubview:t5Label];
    [self setLabelSpace:t5Label withSpace:labelWidth withFont:[UIFont systemFontOfSize:13]];
    [t5Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(t4Label.mas_bottom).offset(10);
        make.left.mas_equalTo(cornerView44.mas_left).offset(11);
        make.right.mas_equalTo(cornerView44.mas_right).offset(-5);
    }];
    
    cornerView44.bounds = CGRectMake(0, 0, kScreenWidth - 30, KDSScreenHeight > 667 ? 290 : 300);
    
    
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
    
    cornerView5.bounds = CGRectMake(0, 0, kScreenWidth - 30, KDSScreenHeight > 667 ? 255 : 250);
    
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
