//
//  KDSBLEBindHelpVC.m
//  KaadasLock
//
//  Created by orange on 2019/4/10.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSBLEBindHelpVC.h"

@interface KDSBLEBindHelpVC ()

@end

@implementation KDSBLEBindHelpVC

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
    NSString *tips;
    if ([self.helpFromStr isEqualToString:@"ZigeBeeLock"]) {//网关锁
         tips = @"您无法添加您的网关设备，请按照以下步骤对设备进行检查：";
    }else{
         tips = @"您无法发现您的蓝牙设备，请按照以下步骤对设备进行检查：";
    }
    NSString *language = [KDSTool getLanguage];
    if ([language hasPrefix:JianTiZhongWen])
    {
        
    }
    else if ([language hasPrefix:FanTiZhongWen])
    {
        if ([self.helpFromStr isEqualToString:@"ZigeBeeLock"]) {
            tips = @"您無法添加您的網關設備，請按照以下步驟對設備進行檢查：";
        }else{
           tips = @"您無法發現您的藍牙設備，請按照以下步驟對設備進行檢查：";
        }
    }
    else if ([language hasPrefix:@"th"])
    {
        if ([self.helpFromStr isEqualToString:@"ZigeBeeLock"]) {
            tips = @"您無法添加您的網關設備，請按照以下步驟對設備進行檢查：";
        }else{
            tips = @"您無法發現您的藍牙設備，請按照以下步驟對設備進行檢查：";
        }
    }
    else
    {
        if ([self.helpFromStr isEqualToString:@"ZigeBeeLock"]) {
            tips = @"您無法添加您的網關設備，請按照以下步驟對設備進行檢查：";
        }else{
           tips = @"您無法發現您的藍牙設備，請按照以下步驟對設備進行檢查：";
        }
        
    }
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
    NSString *tips1;
    NSString *tips2;
    NSString *tips3;
    NSString *tips4;
    NSString *tips5;
    NSString *tips6;
    
    if ([self.helpFromStr isEqualToString:@"ZigeBeeLock"]) {
        tips1 = @"检查网关离门锁的距离，建议使用距离为可视距离8米内，若距离过长或有墙遮挡，会导致信号衰减， 影响使用；";
        tips2 = @"唤醒门锁键盘按两次【*】，输入管理员密码，按【#】进入管理模式，按【4】进入扩展功能，按键【2】退出网络，若提示操作失败，说明扩展模块松动，请打开电池盖， 将扩展模块拔出，再插入；";
        tips3 = @"若锁上提示入网成功，App提示超时失败， 请刷新设备页面；";
        tips4 = @"锁提示入网失败，说明信号很弱，请拉近网关距离；";
        tips5 = @"";
        tips6 = @"";
    }else{
        tips1 = @"请保证您的设备已经接通电源，或电池电量充足。";
        tips2 = @"请打开您手机的蓝牙。";
        tips3 = @"保持待添加的设备与手机的距离不超过5米，从而保证设备间的通信。";
        tips4 = @"您需要确保您的设备处于待添加的状态下，具体方法如下：";
        tips5 = @"对于没有任何按键的设备，您可以尝试以1秒为间隙，反复对设备进行上电操作。";
        tips6 = @"对于有一个按键或有重置孔的设备，您可以尝试长按按键或长按重置孔。进入待添加状态后，通常会有一个特殊的指示灯效果。";
    }
    NSString *language = [KDSTool getLanguage];
    if ([language hasPrefix:JianTiZhongWen])
    {
        
    }
    else if ([language hasPrefix:FanTiZhongWen])
    {
        if ([self.helpFromStr isEqualToString:@"ZigeBeeLock"]) {
            tips1 = @"檢查網關離門鎖的距離，建議使用距離為可視距離8米內，若距離過長或有墻遮擋，會導致信號衰減， 影響使用；";
            tips2 = @"喚醒門鎖鍵盤按兩次【*】，輸入管理員密碼，按【#】進入管理模式，按【4】進入擴展功能，按鍵【2】退出網絡，若提示操作失敗，說明擴展模塊松動，請打開電池蓋， 將擴展模塊拔出，再插入；";
            tips3 = @"若鎖上提示入網成功，App提示超時失敗， 請刷新設備頁面；";
            tips4 = @"鎖提示入網失敗，說明信號很弱，請拉近網關距離；";
            tips5 = @"";
            tips6 = @"";
        }else{
            tips1 = @"請保證您的設備已經接通電源，或電池電量充足。";
            tips2 = @"請打開您手機的藍牙。";
            tips3 = @"保持待添加的設備與手機的距離不超過5米，從而保證設備間的通信。";
            tips4 = @"您需要確保您的設備處於待添加的狀態下，具體方法如下：";
            tips5 = @"對於沒有任何按鍵的設備，您可以嘗試以1秒為間隙，反復對設備進行上電操作。";
            tips6 = @"對於有一個按鍵或有重置孔的設備，您可以嘗試長按按鍵或長按重置孔。進入待添加狀態后，通常會有一個特殊的指示燈效果。";
        }
        
        
    }
    else if ([language hasPrefix:@"th"])
    {
        if ([self.helpFromStr isEqualToString:@"ZigeBeeLock"]) {
            tips1 = @"檢查網關離門鎖的距離，建議使用距離為可視距離8米內，若距離過長或有墻遮擋，會導致信號衰減， 影響使用；";
            tips2 = @"喚醒門鎖鍵盤按兩次【*】，輸入管理員密碼，按【#】進入管理模式，按【4】進入擴展功能，按鍵【2】退出網絡，若提示操作失敗，說明擴展模塊松動，請打開電池蓋， 將擴展模塊拔出，再插入；";
            tips3 = @"若鎖上提示入網成功，App提示超時失敗， 請刷新設備頁面；";
            tips4 = @"鎖提示入網失敗，說明信號很弱，請拉近網關距離；";
            tips5 = @"";
            tips6 = @"";
        }else{
            tips1 = @"請保證您的設備已經接通電源，或電池電量充足。";
            tips2 = @"請打開您手機的藍牙。";
            tips3 = @"保持待添加的設備與手機的距離不超過5米，從而保證設備間的通信。";
            tips4 = @"您需要確保您的設備處於待添加的狀態下，具體方法如下：";
            tips5 = @"對於沒有任何按鍵的設備，您可以嘗試以1秒為間隙，反復對設備進行上電操作。";
            tips6 = @"對於有一個按鍵或有重置孔的設備，您可以嘗試長按按鍵或長按重置孔。進入待添加狀態后，通常會有一個特殊的指示燈效果。";
        }
        
    }
    else
    {
        if ([self.helpFromStr isEqualToString:@"ZigeBeeLock"]) {
            tips1 = @"檢查網關離門鎖的距離，建議使用距離為可視距離8米內，若距離過長或有墻遮擋，會導致信號衰減， 影響使用；";
            tips2 = @"喚醒門鎖鍵盤按兩次【*】，輸入管理員密碼，按【#】進入管理模式，按【4】進入擴展功能，按鍵【2】退出網絡，若提示操作失敗，說明擴展模塊松動，請打開電池蓋， 將擴展模塊拔出，再插入；";
            tips3 = @"若鎖上提示入網成功，App提示超時失敗， 請刷新設備頁面；";
            tips4 = @"鎖提示入網失敗，說明信號很弱，請拉近網關距離；";
            tips5 = @"";
            tips6 = @"";
        }else{
            tips1 = @"請保證您的設備已經接通電源，或電池電量充足。";
            tips2 = @"請打開您手機的藍牙。";
            tips3 = @"保持待添加的設備與手機的距離不超過5米，從而保證設備間的通信。";
            tips4 = @"您需要確保您的設備處於待添加的狀態下，具體方法如下：";
            tips5 = @"對於沒有任何按鍵的設備，您可以嘗試以1秒為間隙，反復對設備進行上電操作。";
            tips6 = @"對於有一個按鍵或有重置孔的設備，您可以嘗試長按按鍵或長按重置孔。進入待添加狀態后，通常會有一個特殊的指示燈效果。";
        }
        
    }
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
    if ([self.helpFromStr isEqualToString:@"ZigeBeeLock"]) {
      t2Label.frame = CGRectMake(57, CGRectGetMaxY(line1.frame), cornerViewWidth - 72, 105);
    }else{
      t2Label.frame = CGRectMake(57, CGRectGetMaxY(line1.frame), cornerViewWidth - 72, 75);
    }
    
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
    if ([self.helpFromStr isEqualToString:@"ZigeBeeLock"] && KDSScreenWidth > 375) {
        l4.frame = CGRectMake(23, CGRectGetMaxY(line3.frame) + 20, 17, 17);
    }else{
        l4.frame = CGRectMake(23, CGRectGetMaxY(line3.frame) + 29, 17, 17);
    }
    
    [cornerView2 addSubview:l4];
    UILabel *t4Label = [self createLabelWithText:tips4 color:nil font:nil width:cornerViewWidth - 72];
    t4Label.frame = (CGRect){57, CGRectGetMaxY(line3.frame) + 20, t4Label.bounds.size};
    [cornerView2 addSubview:t4Label];
    
    UIImageView *starIV1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blueStar"]];
    starIV1.frame = (CGRect){60, CGRectGetMaxY(t4Label.frame) + 20, starIV1.image.size};
    
    UILabel *t5Label = [self createLabelWithText:tips5 color:KDSRGBColor(0x99, 0x99, 0x99) font:[UIFont systemFontOfSize:12] width:cornerViewWidth - 98];
    t5Label.frame = (CGRect){CGRectGetMaxX(starIV1.frame) + 10, starIV1.frame.origin.y, t5Label.bounds.size};
   
    UIImageView *starIV2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blueStar"]];
    starIV2.frame = (CGRect){60, CGRectGetMaxY(t5Label.frame) + 17, starIV2.image.size};
    
    UILabel *t6Label = [self createLabelWithText:tips6 color:KDSRGBColor(0x99, 0x99, 0x99) font:[UIFont systemFontOfSize:12] width:cornerViewWidth - 98];
    t6Label.frame = (CGRect){CGRectGetMaxX(starIV2.frame) + 10, starIV2.frame.origin.y, t6Label.bounds.size};
    
    if ([self.helpFromStr isEqualToString:@"ZigeBeeLock"]) {
        cornerView2.bounds = CGRectMake(0, 0, cornerViewWidth, CGRectGetMaxY(t4Label.frame) + 20);
    }else{
        cornerView2.bounds = CGRectMake(0, 0, cornerViewWidth, CGRectGetMaxY(t6Label.frame) + 20);
        [cornerView2 addSubview:starIV1];
        [cornerView2 addSubview:t5Label];
        [cornerView2 addSubview:starIV2];
        [cornerView2 addSubview:t6Label];
    }
    return cornerView2;
}

- (UIView *)createCornerView3
{
    NSString *tips;
    if ([self.helpFromStr isEqualToString:@"ZigeBeeLock"]) {
        
        tips = @"如果您已经完成以上操作，仍然无法成功添加设备，可以在“我的-用户反馈”向我们的工作人员进行反馈。";
    }else{
        tips = @"如果您已经完成以上操作，您仍然无法成功添加设备，可以在”我的-用户反馈“向我们的工作人员进行反馈。";
    }
    
    NSString *language = [KDSTool getLanguage];
    if ([language hasPrefix:JianTiZhongWen])
    {
        
    }
    else if ([language hasPrefix:FanTiZhongWen])
    {
        if ([self.helpFromStr isEqualToString:@"ZigeBeeLock"]) {
            tips = @"如果您已經完成以上操作，仍然無法成功添加設備，可以在“我的-用戶反饋”向我們的工作人員進行反饋。";
        }else{
            tips = @"如果您已經完成以上操作，您仍然無法成功添加設備，可以在”我的-用戶反饋“向我們的工作人員進行反饋。";
        }
       
    }
    else if ([language hasPrefix:@"th"])
    {
        if ([self.helpFromStr isEqualToString:@"ZigeBeeLock"]) {
            tips = @"如果您已經完成以上操作，仍然無法成功添加設備，可以在“我的-用戶反饋”向我們的工作人員進行反饋。";
        }else{
            tips = @"如果您已經完成以上操作，您仍然無法成功添加設備，可以在”我的-用戶反饋“向我們的工作人員進行反饋。";
        }
        
    }
    else
    {
        if ([self.helpFromStr isEqualToString:@"ZigeBeeLock"]) {
            tips = @"如果您已經完成以上操作，仍然無法成功添加設備，可以在“我的-用戶反饋”向我們的工作人員進行反饋。";
        }else{
            tips = @"如果您已經完成以上操作，您仍然無法成功添加設備，可以在”我的-用戶反饋“向我們的工作人員進行反饋。";
        }
        
    }
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
