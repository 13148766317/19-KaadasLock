//
//  KDSAddWiFiLockFatherVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/5/26.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAddWiFiLockFatherVC.h"
#import "KDSWifiLockHelpVC.h"
#import "RHScanViewController.h"
#import "MBProgressHUD+MJ.h"
#import "KDSAddNewWiFiLockStep1VC.h"
#import "KDSAddBleAndWiFiLockStep1.h"
#import "KDSAddVideoWifiLockStep1VC.h"
#import "KDSAddDeviceVC.h"

@interface KDSAddWiFiLockFatherVC ()
///锁型号输入框
@property (nonatomic,strong)UITextField * devTextField;

@end

@implementation KDSAddWiFiLockFatherVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = @"选择配网";
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    
    [self setUI];
}

-(void)setUI
{
    UIView * topView = [UIView new];
    topView.backgroundColor = UIColor.whiteColor;
    topView.layer.cornerRadius = 5;
    topView.layer.masksToBounds = YES;
    [self.view addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.top.equalTo(self.view.mas_top).offset(10);
        make.height.equalTo(@147);
    }];
    
    UILabel * tipsLb1 = [UILabel new];
    tipsLb1.text = @"方式一（手动输入添加）";
    tipsLb1.textColor = KDSRGBColor(153, 153, 153);
    tipsLb1.font = [UIFont systemFontOfSize:13];
    [topView addSubview:tipsLb1];
    [tipsLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(topView.mas_left).offset(15);
        make.right.equalTo(topView.mas_right).offset(-15);
        make.top.equalTo(topView.mas_top).offset(5);
        make.height.equalTo(@20);
    }];
    
    UIView * searchView = [UIView new];
    searchView.backgroundColor = KDSRGBColor(247, 247, 247);
    searchView.layer.cornerRadius = 21;
    searchView.layer.masksToBounds = YES;
    [topView addSubview:searchView];
    [searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsLb1.mas_bottom).offset(10);
        make.height.equalTo(@40);
        make.left.equalTo(topView.mas_left).offset(13);
        make.right.equalTo(topView.mas_right).offset(-13);
    }];
    
    UIImageView * searchIconImg = [UIImageView new];
    searchIconImg.image = [UIImage imageNamed:@"searchIconImg"];
    [searchView addSubview:searchIconImg];
    [searchIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@16);
        make.left.equalTo(searchView.mas_left).offset(5);
        make.centerY.equalTo(searchView);
        
    }];
    _devTextField = [UITextField new];
    _devTextField.borderStyle = UITextBorderStyleNone;
    _devTextField.font = [UIFont systemFontOfSize:15];
    _devTextField.keyboardType = UIKeyboardTypeDefault; //UIKeyboardTypeASCIICapable;
    _devTextField.placeholder = @"请输入您的门锁型号";
    [searchView addSubview:_devTextField];
    [_devTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_devTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchIconImg.mas_right).offset(7);
        make.right.equalTo(searchView.mas_right).offset(0);
        make.top.equalTo(searchView.mas_top).offset(0);
        make.bottom.equalTo(searchView.mas_bottom).offset(0);
    }];
    
    UIButton * addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.backgroundColor = UIColor.clearColor;
    addBtn.layer.borderColor = KDSRGBColor(31, 150, 247).CGColor;
    addBtn.layer.borderWidth = 1;
    addBtn.layer.masksToBounds = YES;
    addBtn.layer.cornerRadius = 15;
    [addBtn setTitle:@"添加" forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    addBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [addBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    [topView addSubview:addBtn];
    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(topView.mas_bottom).offset(-20);
        make.width.equalTo(@80);
        make.height.equalTo(@30);
        make.centerX.equalTo(topView);
    }];
    
    UIView * bootomView = [UIView new];
    bootomView.layer.masksToBounds = YES;
    bootomView.layer.cornerRadius = 5;
    bootomView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:bootomView];
    [bootomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.height.equalTo(@173);
        make.top.equalTo(topView.mas_bottom).offset(15);
    }];
    
    UILabel * tipsLb = [UILabel new];
    tipsLb.text = @"方式二（扫码添加）";
    tipsLb.font = [UIFont systemFontOfSize:13];
    tipsLb.textAlignment = NSTextAlignmentLeft;
    tipsLb.textColor = KDSRGBColor(153, 153, 153);
    [bootomView addSubview:tipsLb];
    [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bootomView.mas_left).offset(15);
        make.right.equalTo(bootomView.mas_right).offset(-15);
        make.top.equalTo(bootomView.mas_top).offset(5);
        make.height.equalTo(@20);
    }];
    
    UIButton * scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [scanBtn setImage:[UIImage imageNamed:@"dms_img_code"] forState:UIControlStateNormal];
//    [scanBtn addTarget:self action:@selector(scanBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bootomView addSubview:scanBtn];
    [scanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@24);
        make.top.equalTo(bootomView.mas_top).offset(56);
        make.centerX.equalTo(bootomView);
    }];
    
    UILabel * tipsLb3 = [UILabel new];
    tipsLb3.text = @"门锁后面板上的二维码";
    tipsLb3.font = [UIFont systemFontOfSize:12];
    tipsLb3.textAlignment = NSTextAlignmentCenter;
    tipsLb3.textColor = KDSRGBColor(179, 179, 179);
    [bootomView addSubview:tipsLb3];
    [tipsLb3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bootomView.mas_left).offset(15);
        make.right.equalTo(bootomView.mas_right).offset(-15);
        make.bottom.equalTo(bootomView.mas_bottom).offset(-15);
        make.height.equalTo(@20);
    }];
    
    UIButton * scanCodeAdd = [UIButton buttonWithType:UIButtonTypeCustom];
    scanCodeAdd.backgroundColor = UIColor.clearColor;
    scanCodeAdd.layer.borderColor = KDSRGBColor(31, 150, 247).CGColor;
    scanCodeAdd.layer.borderWidth = 1;
    scanCodeAdd.layer.masksToBounds = YES;
    scanCodeAdd.layer.cornerRadius = 15;
    [scanCodeAdd setTitle:@"扫码添加" forState:UIControlStateNormal];
    [scanCodeAdd addTarget:self action:@selector(scanBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    scanCodeAdd.titleLabel.font = [UIFont systemFontOfSize:15];
    [scanCodeAdd setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    [bootomView addSubview:scanCodeAdd];
    [scanCodeAdd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(tipsLb3.mas_top).offset(-10);
        make.width.equalTo(@80);
        make.height.equalTo(@30);
        make.centerX.equalTo(bootomView);
    }];
}

#pragma mark 控件点击事件

-(void)navRightClick
{
    KDSWifiLockHelpVC * vc = [KDSWifiLockHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}
///扫描：扫面二维码适配配网方式
-(void)scanBtnClick:(UIButton *)sender
{
    ///鉴权相机权限
    RHScanViewController *vc = [RHScanViewController new];
    vc.isOpenInterestRect = YES;
    vc.isVideoZoom = YES;
    vc.fromWhereVC = @"AddDeviceVC";//添加设备
    [self.navigationController pushViewController:vc animated:YES];
}
///通过锁型号适配配网方式
-(void)addBtnClick:(UIButton *)sender
{
    //目前是客户端管理锁型号，每次发布新的锁（Wi-Fi/ble+wifi）记得在数组里面添加对应的锁型号-----目前是这种笨方法后期最好有服务器管理
    //WIFI锁
    NSArray * wifiLockModel = @[@"X1",@"F1",@"K11",@"S110",@"K9-W",@"K10-W",@"K100-W",@"K12",@"K13（兰博）",@"S118",@"A6",@"A7-W",@"A8-W",@"F1S",@"K13F",@"K20F",@"5500-A5P-W",@"5310-A5P-W",@"兰博基尼传奇3D人脸识别智能锁",@"兰博基尼传奇3D人脸识别",@"兰博基尼传奇3D",@"K20-F3D人脸识别智能锁",@"K20_F3D人脸识别智能锁",@"K20-F3D人脸识别智能锁",@"K20_F3D人脸识别智能锁",@"K20-F3D人脸识别",@"K20_F3D人脸识别",@"K20-F3D人脸识别",@"K20_F3D人脸识别",@"K20-F3D",@"K20_F3D",@"K20-F3D",@"K20_F3D",@"K11F",@"K11Face",@"K11Face",@"A6-W",@"a6-W",@"A6_W",@"a6_W",@"A6-w",@"a6-w",@"A6_w",@"a6_w",@"A6W",@"a6w",@"A6w",@"H7",@"h7",@"兰博基尼传奇1974",@"1974",@"5320-A5P-W",@"5320-A5P-w",@"5320-a5p-w",@"K20-W",@"K20-w",@"k20-w",@"k20-W",@"9321-F",@"9321-f",@"9321F",@"9321f",@"9321_F",@"9321_f",@"K9F",@"K9f",@"k9f",@"k9F",@"K9-F",@"K9-f",@"F200",@"F300",@"F500",@"X200",@"X500",@"K9W",@"K13",@"K15W",@"K15F",@"K15",@"S100-W",@"飞将",@"K13W"];
    //单火开关锁或蓝牙Wi-Fi锁
    NSArray * bleWifiLockModel = @[@"S110M",@"S110-D1",@"S110-D2",@"S110-D3",@"S110-D4",@"S110D",@"S110 D",@"S110_D",@"S110-D",@"x9",@"X9",@"k60",@"K60"];
    //视频锁 
    NSArray * videoWifiLockModel = @[@"K10V",@"K20-V",@"K20V",@"兰博基尼传奇可视猫眼智能锁",@"K13V",@"K60-V 可视猫眼智能锁",@"K60 VP 猫眼视屏智能锁",@"K60 FVP 3D人脸猫眼视屏智能锁",@"X9-V",@"X9 Pro 猫眼视屏智能锁",@"X9 Pro Max 3D人脸猫眼视屏智能锁",@"K20 Max 3D人脸可视猫眼智能锁"];
    
    
    if (self.devTextField.text.length >0) {
        for (int i = 0; i < wifiLockModel.count; i ++) {
            ///[string caseInsensitiveCompare:string2] == NSOrderedSame
             if ([self.devTextField.text caseInsensitiveCompare:wifiLockModel[i]] == NSOrderedSame) {
               //wifi配网
                 KDSAddNewWiFiLockStep1VC * vc = [KDSAddNewWiFiLockStep1VC new];
                 [self.navigationController pushViewController:vc animated:YES];
                 return;
            }
        }
        for (int k = 0; k < bleWifiLockModel.count; k ++) {
            if ([self.devTextField.text caseInsensitiveCompare:bleWifiLockModel[k]] == NSOrderedSame) {
                //ble+wifi
                KDSAddBleAndWiFiLockStep1 * vc = [KDSAddBleAndWiFiLockStep1 new];
                [self.navigationController pushViewController:vc animated:YES];
                return;
            }
        }
        for (int j = 0; j < videoWifiLockModel.count; j ++) {
            if ([self.devTextField.text caseInsensitiveCompare:videoWifiLockModel[j]] == NSOrderedSame) {
                //video+wifi
                KDSAddVideoWifiLockStep1VC * vc = [KDSAddVideoWifiLockStep1VC new];
                [self.navigationController pushViewController:vc animated:YES];
                return;
            }
        }
        
       MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
       hud.mode =MBProgressHUDModeText;
       hud.detailsLabel.text = @"请输入正确的门锁型号，或者\n扫码添加";
       hud.bezelView.backgroundColor = [UIColor blackColor];
       hud.detailsLabel.textColor = [UIColor whiteColor];
       hud.detailsLabel.font = [UIFont systemFontOfSize:15];
       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           [hud hideAnimated:YES];
       });
    }else{
        [MBProgressHUD showError:@"锁型号不能为空"];
    }
    
}


///设备型号输入框
- (void)textFieldDidChange:(UITextField *)textField{
   
}

@end
