//
//  KDSAddSmartHangerMainVC.m
//  KaadasLock
//
//  Created by Frank Hu on 2021/1/6.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSAddSmartHangerMainVC.h"

@interface KDSAddSmartHangerMainVC ()

@end

@implementation KDSAddSmartHangerMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = @"选择配网";
//    [self setRightButton];
//    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    
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
    _devTextField.placeholder = @"请输入您的晾衣机型号";
#ifdef DEBUG
    _devTextField.text = @"M8-E1";
#endif
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
    tipsLb3.text = @"请扫描说明书上的二维码，进行配网";
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
//    KDSWifiLockHelpVC * vc = [KDSWifiLockHelpVC new];
//    [self.navigationController pushViewController:vc animated:YES];
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
    //目前是客户端管理晾衣机型号，每次发布新的产品（Wi-Fi/ble+wifi）记得在数组里面添加对应的晾衣机型号-----目前是这种笨方法后期最好有服务器管理
    //晾衣机
    NSArray * SmartHangerModel = @[@"M8-E1",@"Q8-XHK"];
    
    if (self.devTextField.text.length >0) {
        for (int i = 0; i < SmartHangerModel.count; i ++) {

            if ([self.devTextField.text caseInsensitiveCompare:SmartHangerModel[i]] == NSOrderedSame) {

                KDSAddSmartHangerStep1VC * vc = [KDSAddSmartHangerStep1VC new];
                [self.navigationController pushViewController:vc animated:YES];
                return;
            }
        }

       MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
       hud.mode =MBProgressHUDModeText;
       hud.detailsLabel.text = @"请输入正确的晾衣机型号，或者\n扫码添加";
       hud.bezelView.backgroundColor = [UIColor blackColor];
       hud.detailsLabel.textColor = [UIColor whiteColor];
       hud.detailsLabel.font = [UIFont systemFontOfSize:15];
       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           [hud hideAnimated:YES];
       });
    }else{
        [MBProgressHUD showError:@"晾衣机型号不能为空"];
    }
    
}

///设备型号输入框
- (void)textFieldDidChange:(UITextField *)textField{
   
}

@end
