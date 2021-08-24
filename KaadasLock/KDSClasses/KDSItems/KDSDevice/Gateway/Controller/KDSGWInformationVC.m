//
//  KDSGWInformationVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/5/20.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSGWInformationVC.h"
#import "KDSCatEyeMoreSettingCellTableViewCell.h"
#import "CateyeSetModel.h"
#import "MBProgressHUD+MJ.h"
#import "KDSMQTT.h"
#import "KDSDBManager.h"
//#import "MJExtension.h"
#import "UIView+Extension.h"



@interface KDSGWInformationVC ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)NSMutableArray *dataArray;
@property(nonatomic,strong)UITableView * tableView;

///删除网关
@property(nonatomic,strong)UIButton * delGWBtn;

@end

@implementation KDSGWInformationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.navigationTitleLabel.text = Localized(@"deviceInfo");
    self.view.backgroundColor = KDSPublicBackgroundColor;
    
    [self setDataSource];
    
    [self setUI];
}

-(void)setDataSource
{
    CateyeSetModel *model1 = [CateyeSetModel setWithName:Localized(@"gateway:") andValue:self.gw.model.deviceSN];
    CateyeSetModel *model2 = [CateyeSetModel setWithName:Localized(@"Firmware version:") andValue:self.gw.netSetting.SW];
    CateyeSetModel *model3 = [CateyeSetModel setWithName:Localized(@"wifiName:") andValue:self.gw.wifiName];
    CateyeSetModel *model4 = [CateyeSetModel setWithName:Localized(@"wifiPwd:") andValue:self.gw.wifiPWD];
    CateyeSetModel *model5 = [CateyeSetModel setWithName:Localized(@"Gateway LAN IP:") andValue:self.gw.netSetting.lanIp];
    CateyeSetModel *model6 = [CateyeSetModel setWithName:Localized(@"Gateway WAN IP:") andValue:self.gw.netSetting.wanIp];
    CateyeSetModel *model7 = [CateyeSetModel setWithName:Localized(@"Gateway LAN Subnet Mask:") andValue:self.gw.netSetting.lanNetmask];
    CateyeSetModel *model8 = [CateyeSetModel setWithName:Localized(@"Gateway WAN Subnet Mask:") andValue:self.gw.netSetting.wanNetmask];
    CateyeSetModel * model9 = [CateyeSetModel setWithName:Localized(@"Gateway Coordinator Channel:") andValue:self.gw.channel];
    CateyeSetModel * model10 = [CateyeSetModel setWithName:Localized(@"gwNickName") andValue:self.gw.model.deviceNickName ?: self.gw.model.deviceSN];
    [self.dataArray removeAllObjects];
    if ([self.gw.model.model isEqualToString:@"6030"]) {//小网关
        [self.dataArray addObjectsFromArray:@[model10,model1,model2]];
    }else if([self.gw.model.model isEqualToString:@"6032"]){//小网关
        [self.dataArray addObjectsFromArray:@[model10,model1,model2,model9]];
    }else{
         [self.dataArray addObjectsFromArray:@[model10,model1,model2,model3,model4,model5,model6,model7,model8,model9]];
    }
   
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = KDSRGBColor(242, 242, 242);
    
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
    
    [[KDSMQTTManager sharedManager] gwGetNetSetting:self.gw.model completion:^(NSError * _Nullable error, KDSGWNetSetting * _Nullable setting) {
        
        if (setting) {
            [hud hideAnimated:YES];
            self.gw.netSetting = setting;
            [self setDataSource];
            [self.tableView reloadData];
        }else{
            [hud hideAnimated:YES];
            [MBProgressHUD showError:Localized(@"Gateway Acquisition Failure")];
        }
        
    }];
    
    [[KDSMQTTManager sharedManager] gwGetWifiSetting:self.gw.model completion:^(NSError * _Nullable error, NSString * _Nullable ssid, NSString * _Nullable pwd, NSString * _Nullable encryption) {
        
        [hud hideAnimated:YES];
        if (ssid) {
            
            self.gw.wifiName = ssid;
            self.gw.wifiPWD = pwd;
            self.gw.encryption = encryption;
            [self setDataSource];
            [self.tableView reloadData];
            
        }
    }];
    
    [[KDSMQTTManager sharedManager] gwGetChannel:self.gw.model completion:^(NSError * _Nullable error, BOOL success, int channel) {
        [hud hideAnimated:YES];
        if (success) {
            self.gw.channel = [NSString stringWithFormat:@"%d",channel];
            [self setDataSource];
            [self.tableView reloadData];
        }
    }];
}

-(void)setUI{
    
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.delGWBtn];
    
    [self.delGWBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-45);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.delGWBtn.mas_top).offset(-40);
    }];
}

#pragma mark 手势
-(void)delClick:(UIButton *)sender
{
    
    UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:Localized(@"ensureDeleteDevice") message:Localized(@"deviceDeleteAfter\nRestoreEquipmentfactorySettings") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancle = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:Localized(@"sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        
        ////删除设备
        MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
        [[KDSMQTTManager sharedManager] unbindGateway:self.gw.model completion:^(NSError * _Nullable error, BOOL success) {
            [hud hideAnimated:YES];
            if (success) {
                [MBProgressHUD showSuccess:Localized(@"deleteSuccess")];
                [[KDSUserManager sharedManager].gateways removeObject:self.gw];
                [[KDSUserManager sharedManager].cateyes enumerateObjectsUsingBlock:^(KDSCatEye * ce, NSUInteger idx, BOOL *stop) {
                    if ([ce.gatewayDeviceModel.gwId isEqualToString:self.gw.model.deviceSN]) {
                        *stop = YES;
                        if (*stop == YES) {
                            [[KDSUserManager sharedManager].cateyes removeObject:ce];
                        }
                    }
                }];
//                [[KDSUserManager sharedManager].locks enumerateObjectsUsingBlock:^(KDSLock * lc, NSUInteger idx, BOOL *stop) {
//                    if ([lc.gwDevice.gwId isEqualToString:self.gwModel.deviceSN]) {
//                        *stop = YES;
//                        if (*stop == YES) {
//                            [[KDSUserManager sharedManager].locks removeObject:lc];
//                        }
//                    }
//                }];
                KDSLock *lock = [KDSLock new];
                lock.gw = self.gw;
                [[NSNotificationCenter defaultCenter] postNotificationName:KDSLockHasBeenDeletedNotification object:nil userInfo:@{@"lock" : lock}];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }else{
                [MBProgressHUD showError:Localized(@"deleteFailed")];
            }
        }];
        
    }];
    //修改按钮
    [cancle setValue:KDSRGBColor(51, 51, 51) forKey:@"titleTextColor"];
    
    //修改message
    NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:Localized(@"deviceDeleteAfter\nRestoreEquipmentfactorySettings")];
    [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:KDSRGBColor(153, 153, 153) range:NSMakeRange(0, alertControllerMessageStr.length)];
    [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, alertControllerMessageStr.length)];
    [alerVC setValue:alertControllerMessageStr forKey:@"attributedMessage"];
    
    [alerVC addAction:cancle];
    [alerVC addAction:ok];
    [self presentViewController:alerVC animated:YES completion:nil];
    
}

///密码昵称文本输入框，长度不能超过16
- (void)textFieldTextDidChange:(UITextField *)sender
{
    [sender trimTextToLength:-1];
}

#pragma mark UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDSCatEyeMoreSettingCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KDSCatEyeMoreSettingCellTableViewCell.ID];
    if (indexPath.row != 0) {
        [cell.rightArrowImg mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.width.mas_equalTo(1);
            make.right.mas_equalTo(cell.mas_right).offset(0);
            make.centerY.mas_equalTo(cell.mas_centerY).offset(0);
        }];
    }else{
        [cell.rightArrowImg mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.width.mas_equalTo(15);
            make.right.mas_equalTo(cell.mas_right).offset(-15);
            make.centerY.mas_equalTo(cell.mas_centerY).offset(0);
            
        }];
    }
    cell.rightArrowImg.hidden = indexPath.row == 0 ? NO : YES;
    cell.model = self.dataArray[indexPath.row];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0://网关昵称
        {
            [self changeGwNickName];
        }
            break;
        case 2://wifi名称
        {
//            [self changeWifiName];
        }
            break;
        case 3://Wi-Fi密码
        {
//            [self changeWifiPwd];
        }
            break;
//        case 4://局域网IP
//        {
//            [self changeLanIP];
//        }
            break;
        case 8://协调器信道
        {
//            [self changeChannle];
            
        }
            break;
            
        default:
            break;
    }
}

#pragma mark cell点击事件
///更改wifi名称
-(void)changeWifiName
{
    UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:Localized(@"changeWifiName") message:Localized(@"changeWifiNameCanBinDingCateyeAgain") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancle = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    __weak typeof(self) ws = self;
    //定义第一个输入框；
    [alerVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = Localized(@"PleaseEnterWiFiName");
        textField.text = ws.gw.wifiName;
        textField.textAlignment = NSTextAlignmentLeft;
        textField.textColor = KDSRGBColor(199, 199, 204);
        textField.font = [UIFont systemFontOfSize:12];
        [textField addTarget:ws action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:Localized(@"sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *newWifiName = alerVC.textFields.firstObject.text;
        if(![KDSTool isValidateWiFi:newWifiName]){
            [MBProgressHUD showError:Localized(@"26 English letters, underscores or underscores")];
            return ;
        }
        else if ([self convertToByte:newWifiName] > 8.0) {
            [MBProgressHUD showError:Localized(@"WiFi name cannot be greater than 16 bytes")];
            return ;
        }
        else if([self convertToByte:newWifiName] == 0){
            [MBProgressHUD showError:Localized(@"WiFi name cannot be empty")];
            return ;
        }else if ([newWifiName isEqualToString:self.gw.wifiName]){
            
            [MBProgressHUD showError:Localized(@"Consistent with the original WiFi name")];
            return;
        }else{
            
            MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:ws.view];
            [[KDSMQTTManager sharedManager] gw:ws.gw.model setWiFiSSID:newWifiName pwd:self.gw.wifiPWD encryption:ws.gw.encryption completion:^(NSError * _Nullable error, BOOL success) {
                if (success) {
                    [hud hideAnimated:YES];
                    [MBProgressHUD showSuccess:Localized(@"Successful modification of WiFi name")];
                    ws.gw.wifiName = newWifiName;
                    [ws setDataSource];
                    [ws.tableView reloadData];
                }else{
                    [hud hideAnimated:YES];
                    [MBProgressHUD showError:Localized(@"Faild modification of WiFi name")];
                }
            }];
        }
     
        
    }];
    //修改按钮
    [cancle setValue:KDSRGBColor(51, 51, 51) forKey:@"titleTextColor"];
    
    //修改message
    NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:Localized(@"changeWifiNameCanBinDingCateyeAgain")];
    [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:KDSRGBColor(153, 153, 153) range:NSMakeRange(0, alertControllerMessageStr.length)];
    [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, alertControllerMessageStr.length)];
    [alerVC setValue:alertControllerMessageStr forKey:@"attributedMessage"];
    
    [alerVC addAction:cancle];
    [alerVC addAction:ok];
    [self presentViewController:alerVC animated:YES completion:nil];
    
}
///更改wifi密码
-(void)changeWifiPwd
{
    UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:Localized(@"changeWifiPwd") message:Localized(@"changeWifiPwdCanBinDingCateyeAgain") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancle = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    __weak typeof(self) ws = self;
    //定义第一个输入框；
    [alerVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = Localized(@"PleaseEnterWiFiPwd");
        textField.text = ws.gw.wifiPWD;
        textField.textAlignment = NSTextAlignmentLeft;
        textField.textColor = KDSRGBColor(199, 199, 204);
        textField.font = [UIFont systemFontOfSize:12];
        [textField addTarget:ws action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:Localized(@"sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *newWifiPwd = alerVC.textFields.firstObject.text;
        if(![KDSTool isValidateWiFi:newWifiPwd]){
            [MBProgressHUD showError:Localized(@"26 English letters, underscores or underscores")];
            return ;
        }
        else if ([ws convertToByte:newWifiPwd] < 4.0) {
            [MBProgressHUD showError:Localized(@"WiFi password cannot be less than 8 bytes")];
            return ;
        }
        else if ([ws convertToByte:newWifiPwd] > 12.0) {
            [MBProgressHUD showError:Localized(@"WiFi password cannot be greater than 24 bytes")];
            return ;
        }
        else if([ws convertToByte:newWifiPwd] == 0){
            [MBProgressHUD showError:Localized(@"WiFi password cannot be empty")];
            return ;
        }else if ([newWifiPwd isEqualToString:ws.gw.wifiPWD]){
            [MBProgressHUD showError:Localized(@"Consistent with the original WiFi password")];
            return;
        }else{
            
            MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:ws.view];
            [[KDSMQTTManager sharedManager] gw:ws.gw.model setWiFiSSID:ws.gw.wifiName pwd:newWifiPwd encryption:ws.gw.encryption completion:^(NSError * _Nullable error, BOOL success) {
                if (success) {
                    [hud hideAnimated:YES];
                    [MBProgressHUD showSuccess:Localized(@"Successful WiFi password modification")];
                    ws.gw.wifiPWD = newWifiPwd;
                    [ws setDataSource];
                    [ws.tableView reloadData];
                }else{
                    [hud hideAnimated:YES];
                    [MBProgressHUD showError:Localized(@"Faild WiFi password modification")];
                }
            }];
        }
        
    }];
    //修改按钮
    [cancle setValue:KDSRGBColor(51, 51, 51) forKey:@"titleTextColor"];
    
    //修改message
    NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:Localized(@"changeWifiPwdCanBinDingCateyeAgain")];
    [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:KDSRGBColor(153, 153, 153) range:NSMakeRange(0, alertControllerMessageStr.length)];
    [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, alertControllerMessageStr.length)];
    [alerVC setValue:alertControllerMessageStr forKey:@"attributedMessage"];
    
    [alerVC addAction:cancle];
    [alerVC addAction:ok];
    [self presentViewController:alerVC animated:YES completion:nil];
}
///更改局域网地址和网子网掩码
-(void)changeLanIP
{
    UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:Localized(@"changeLanIP") message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancle = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    __weak typeof(self) ws = self;
    //定义第一个输入框；
    [alerVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = Localized(@"Gateway LAN IP:");
        textField.text = ws.gw.netSetting.lanIp;
        textField.textAlignment = NSTextAlignmentLeft;
        textField.textColor = KDSRGBColor(199, 199, 204);
        textField.font = [UIFont systemFontOfSize:12];
        textField.tag = 10001;
        [textField addTarget:ws action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    }];
    //定义第二个输入框；
    [alerVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = Localized(@"Gateway LAN Subnet Mask:");
        textField.text = ws.gw.netSetting.lanNetmask;
        textField.textAlignment = NSTextAlignmentLeft;
        textField.textColor = KDSRGBColor(199, 199, 204);
        textField.font = [UIFont systemFontOfSize:12];
        textField.tag = 10002;
        [textField addTarget:ws action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:Localized(@"sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //得到文本信息
        NSString * lanIp;
        NSString * lanNetmask;
        for(UITextField *text in alerVC.textFields){
            if (text.tag == 10001) {
                 lanIp = text.text;
            }
            else if(text.tag == 10002){
                lanNetmask = text.text;
            }
        }
        //判断ip是否合法
        if(![KDSTool isValidateIP:lanIp]){
            [MBProgressHUD showError:Localized(@"Invalid IP address")];
            return ;
        }else if (![ws isValidateNetmask:lanNetmask]) {//判断子网掩码是否合法有效
            [MBProgressHUD showError:Localized(@"Invalid subnet mask address")];
            return ;
        }else if ([lanIp isEqualToString:ws.gw.netSetting.lanIp] && [lanNetmask isEqualToString:ws.gw.netSetting.lanNetmask]){
            
            [MBProgressHUD showError:Localized(@"Original IP and Subnet Mask")];
            return;
        }else{
            
            MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:ws.view];
            [[KDSMQTTManager sharedManager] gw:ws.gw.model setNetLan:lanIp mask:lanNetmask completion:^(NSError * _Nullable error, BOOL success) {
                if (success) {
                    [hud hideAnimated:YES];
                    [MBProgressHUD showSuccess:Localized(@"Successful configuration")];
                    ws.gw.netSetting.lanIp = lanIp;
                    ws.gw.netSetting.lanNetmask = lanNetmask;
                    [ws setDataSource];
                    [ws.tableView reloadData];
                }else{
                    [hud hideAnimated:YES];
                    [MBProgressHUD showError:Localized(@"The LAN configuration failed.")];
                }
            }];
            
        }
        
    }];
    
    
    //修改按钮
    [cancle setValue:KDSRGBColor(51, 51, 51) forKey:@"titleTextColor"];
    [alerVC addAction:cancle];
    [alerVC addAction:ok];
    [self presentViewController:alerVC animated:YES completion:nil];
}
//设置网关协调器信道
-(void)changeChannle
{
    UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:Localized(@"changeChanle") message:Localized(@"changeChanleCanBinDingCateyeAgain") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancle = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    __weak typeof(self) ws = self;
    //定义第一个输入框；
    [alerVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = Localized(@"Channel range 11-26");
        textField.text = ws.gw.channel;
        textField.textAlignment = NSTextAlignmentLeft;
        textField.textColor = KDSRGBColor(199, 199, 204);
        textField.font = [UIFont systemFontOfSize:12];
        [textField addTarget:ws action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:Localized(@"sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *newChannle = alerVC.textFields.firstObject.text;
        if(![ws isValidateChannel:newChannle]){
            [MBProgressHUD showError:Localized(@"Coordinator channel range 11 - 26")];
            return ;
        }else if (newChannle.length == 0){
            [MBProgressHUD showError:Localized(@"GWChannel Cannot Be Empty")];
            return;
        }
        else{
            MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:ws.view];
            [[KDSMQTTManager sharedManager] gw:ws.gw.model setChannel:newChannle.intValue completion:^(NSError * _Nullable error, BOOL success) {
                if (success) {
                    [hud hideAnimated:YES];
                    [MBProgressHUD showSuccess:Localized(@"Coordinator Channel Successfully")];
                    ws.gw.channel = newChannle;
                    [ws setDataSource];
                    [ws.tableView reloadData];
                }else{
                    [hud hideAnimated:YES];
                    [MBProgressHUD showError:Localized(@"Coordinator channel failedAgainLater")];
                }
            }];
        }
        
    }];
    //修改按钮
    [cancle setValue:KDSRGBColor(51, 51, 51) forKey:@"titleTextColor"];
    
    //修改message
    NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:Localized(@"changeChanleCanBinDingCateyeAgain")];
    [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:KDSRGBColor(153, 153, 153) range:NSMakeRange(0, alertControllerMessageStr.length)];
    [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, alertControllerMessageStr.length)];
    [alerVC setValue:alertControllerMessageStr forKey:@"attributedMessage"];
    
    [alerVC addAction:cancle];
    [alerVC addAction:ok];
    [self presentViewController:alerVC animated:YES completion:nil];
}

- (int)convertToByte:(NSString*)str {
    int strlength = 0;
    //去掉空格
    //    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    //去掉字符串头尾空格
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    char* p = (char*)[str cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[str lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return (strlength+1)/2;
}

//判断子网掩码是否合法有效
- (BOOL)isValidateNetmask:(NSString *)value{
    NSArray *array = [value componentsSeparatedByString:@"."]; //从字符.中分隔成4个元素的数组
    //    NSLog(@"array:%@",array);
    if (array.count == 4) {
        for (int i = 0; i < array.count; i++) {
            //判断是否为数字
            if (![KDSTool isNumber:array[i]]) {
                return NO;
            }
            
        }
        return YES;
    } else {
        return NO;
    }
}
//判断信道范围是否在11 - 26之间
- (BOOL)isValidateChannel:(NSString *)value{
    
    if (value.intValue >= 11 && value.intValue <= 26) {
        return YES;
    } else {
        return NO;
    }
}

-(void)changeGwNickName
{
    UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:Localized(@"Enter the gateway name") message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancle = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    
    __weak typeof(self) ws = self;
    //定义第一个输入框；
    [alerVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = ws.gw.model.deviceNickName ?: ws.gw.model.deviceSN;
        textField.textAlignment = NSTextAlignmentLeft;
        textField.textColor = KDSRGBColor(199, 199, 204);
        textField.font = [UIFont systemFontOfSize:12];
        [textField addTarget:ws action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:Localized(@"sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString * gwnickname = alerVC.textFields.firstObject.text;
        if (gwnickname.length == 0) {
            [MBProgressHUD showError:Localized(@"Nicknames are not empty")];
            return ;
        }else if ([gwnickname isEqualToString:ws.gw.model.deviceSN ?:ws.gw.model.deviceNickName]){
            [MBProgressHUD showError:Localized(@"No changes were made")];
            return ;
        }
        else{
            MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"doingNow") toView:ws.view];
            [[KDSMQTTManager sharedManager] updateGwNickNameWithGw:ws.gw.model nickName:gwnickname completion:^(NSError * _Nullable error, BOOL success) {
                if (success) {
                    [hud hideAnimated:YES];
                    [MBProgressHUD showSuccess:Localized(@"setSuccess")];
                    ws.gw.model.deviceNickName = gwnickname;
                    [ws setDataSource];
                    [ws.tableView reloadData];
                }else{
                    [hud hideAnimated:YES];
                    [MBProgressHUD showError:Localized(@"setFailed")];
                }
            }];
        }
        
    }];
    //修改按钮
    [cancle setValue:KDSRGBColor(51, 51, 51) forKey:@"titleTextColor"];
    [alerVC addAction:cancle];
    [alerVC addAction:ok];
    [self presentViewController:alerVC animated:YES completion:nil];
    
}

#pragma mark --Lazy load

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = ({
            UITableView *tv = [[UITableView alloc] initWithFrame:CGRectZero];
            tv.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            tv.tableFooterView = [UIView new];
            tv.delegate = self;
            tv.dataSource = self;
//            tv.scrollEnabled = NO;
            tv.rowHeight = 60;
            tv.backgroundColor = UIColor.clearColor;
            [tv registerClass:[KDSCatEyeMoreSettingCellTableViewCell class ] forCellReuseIdentifier:KDSCatEyeMoreSettingCellTableViewCell.ID];
            tv;
        });
    }
    return _tableView;
}

- (UIButton *)delGWBtn
{
    if (!_delGWBtn) {
        _delGWBtn = [UIButton new];
        [_delGWBtn setTitle:Localized(@"deleteDevice") forState:UIControlStateNormal];
        [_delGWBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _delGWBtn.backgroundColor = KDSRGBColor(255, 59, 48);
        _delGWBtn.layer.masksToBounds = YES;
        _delGWBtn.layer.cornerRadius = 22;
        [_delGWBtn addTarget:self action:@selector(delClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _delGWBtn;
}

- (NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
