//
//  KDSOldBLEMoreSettingVC.m
//  KaadasLock
//
//  Created by orange on 2019/5/6.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSOldBLEMoreSettingVC.h"
#import "KDSLockMoreSettingCell.h"
#import "MBProgressHUD+MJ.h"
#import "UIView+Extension.h"
#import "KDSHttpManager+Ble.h"
#import "KDSOADVC.h"
#import "KDSDFUVC.h"
#import "KDSBleAssistant.h"

@interface KDSOldBLEMoreSettingVC () <UITableViewDataSource, UITableViewDelegate>
///bleVersion=3时，蓝牙接口返回的型号。
@property (nonatomic, strong) NSString *model;
///bleVersion=3时，蓝牙接口返回的锁硬件版本号。
@property (nonatomic, strong) NSString *hardware;
///bleVersion=3时，蓝牙接口返回的锁软件版本号。
@property (nonatomic, strong) NSString *software;

@end

@implementation KDSOldBLEMoreSettingVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationTitleLabel.text = Localized(@"deviceInfo");
    self.tableView.rowHeight = 60;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIView new];
    if (self.lock.device.bleVersion.intValue >= 3){
        __weak typeof(self) weakSelf = self;
        [self.lock.bleTool getLockParam:2 completion:^(KDSBleError error, id  _Nullable value) {
            if (error == KDSBleErrorSuccess)
            {
                weakSelf.model = value;
                [weakSelf.tableView reloadData];
            }
            [weakSelf.lock.bleTool getLockParam:4 completion:^(KDSBleError error, id  _Nullable value) {
                if (error == KDSBleErrorSuccess)
                {
                    weakSelf.hardware = value;
                    [weakSelf.tableView reloadData];
                }
                [weakSelf.lock.bleTool getLockParam:3 completion:^(KDSBleError error, id  _Nullable value) {
                    if (error == KDSBleErrorSuccess)
                    {
                        weakSelf.software = value;
                        [weakSelf.tableView reloadData];
                    }
                    
                }];
            }];
        }];
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
    KDSLockMoreSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell)
    {
        cell = [[KDSLockMoreSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
//    NSArray *titles = @[Localized(@"deviceName"), Localized(@"serialNumber"), Localized(@"deviceModel"), Localized(@"firmwareVer"), Localized(@"softwareVer"), Localized(@"BLEVer")];
    NSArray *titles = @[Localized(@"deviceName"), Localized(@"serialNumber"), Localized(@"deviceModel")/*,Localized(@"firmwareVer"),Localized(@"softwareVer")*/,Localized(@"蓝牙模块"), Localized(@"BLEVer")];
    cell.title = titles[indexPath.row];
    cell.hideSeparator = indexPath.row == titles.count - 1;
    cell.hideArrow = YES;
    switch (indexPath.row)
    {
        case 0://修改锁昵称
            cell.subtitle = self.lock.device.lockNickName;
            cell.hideArrow = NO;
            break;
            
        case 1://序列号
            cell.subtitle = self.lock.bleTool.connectedPeripheral.serialNumber;
            break;
            
        case 2://设备型号
        {///老锁型号全部显示
            NSString *model = self.lock.device.model;//换锁会造成不准确
//            NSRange range = [self.lock.device.model rangeOfString:@"V" options:NSBackwardsSearch];
//            if (range.location != NSNotFound)
//            {
//                model = [model substringToIndex:range.location];
//            }
            /*range = [model rangeOfString:@"0"];
            if (range.location != NSNotFound)
            {
                model = [model substringToIndex:range.location];
            }*/
            cell.subtitle = model;
        }
            break;
    /*
            
        case 3://固件版本号
        {
            if (self.lock.device.bleVersion.intValue < 3)
            {
                cell.subtitle = self.lock.bleTool.connectedPeripheral.hardwareVer;
            }
            else
            {
                if (self.hardware.length >0) {
                    cell.subtitle = self.hardware;
                }else{
                    cell.subtitle = [self.lock.bleTool.connectedPeripheral.hardwareVer componentsSeparatedByString:@"-"].lastObject;
                }
            }
            NSLog(@"--{Kaadas}--hardwareVer=%@",self.lock.bleTool.connectedPeripheral.hardwareVer);
            break;
        }
        case 4://软件版本号
        {
            if (self.lock.device.bleVersion.intValue < 3)
            {
                cell.subtitle = self.lock.bleTool.connectedPeripheral.lockModelType;
            }
            else
            {
                cell.subtitle = self.software ?: [self.lock.bleTool.connectedPeripheral.softwareVer componentsSeparatedByString:@"-"].lastObject;
            }
            NSLog(@"--{Kaadas}--softwareVer=%@",self.lock.bleTool.connectedPeripheral.softwareVer);
            break;
        }
     */
        case 3://模块代号
            cell.subtitle = self.lock.bleTool.connectedPeripheral.lockModelNumber;
            break;
        case 4://蓝牙版本号
        {
            if (!self.lock.bleTool.connectedPeripheral.softwareVer) {
                cell.subtitle = self.lock.device.softwareVersion;
            }else{
                if (self.lock.device.bleVersion.intValue < 3)
                {
                    cell.subtitle = self.lock.bleTool.connectedPeripheral.softwareVer;
                }
                else
                {
                    cell.subtitle = [self.lock.bleTool.connectedPeripheral.softwareVer componentsSeparatedByString:@"-"].firstObject;
                }
            }
            ///当为老模块时，只有bleversion == 2且为主用户才能ota升级
            if (self.lock.device.bleVersion.intValue > 1 && self.lock.device.is_admin.boolValue) {
                cell.hideArrow = NO;
            }
            break;
        }
        default:
            cell.subtitle = nil;
            cell.hideSwitch = YES;
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /******目前来说修改设备昵称不分主用户和授权用户，都可以修改，如果要限定可以打开下面的代码（根据条件）*****/
//    BOOL oldTag = self.lock.device.bleVersion.intValue < 3;
//    BOOL isoldLock = [self.lock.lockFunctionSet isEqualToString:@"0x00"];
//    if ((self.lock.device && !self.lock.device.is_admin.boolValue) && (oldTag && isoldLock))
//    {
//        [MBProgressHUD showError:Localized(@"noAuthorization")];
//        return;
//    }
    if (self.lock.bleTool && !self.lock.bleTool.connectedPeripheral && indexPath.row != 3 && indexPath.row != 0)
    {
        [MBProgressHUD showError:Localized(@"bleNotConnect")];
        return;
    }
    switch (indexPath.row)
    {
        case 0://修改锁昵称
            [self alterDeviceNickname];
            break;
            
        case 4://蓝牙版本，固件升级，TI方案
        {
            ///当为老模块时，只要蓝牙版本号不是1且是主用户都可以升级
            if (self.lock.device.bleVersion.intValue == 1 || !self.lock.device.is_admin.boolValue) {
                return;
            }
            if (self.lock.bleTool.isBinding) {
                
                if(self.lock.power < 20){
                    [MBProgressHUD showError:Localized(@"low power cannot OTA")];
                    return;
                }
                //蓝牙本地固件版本号
                NSString *softwareRev = [self parseBluetoothVersion];
                
                if ([self.lock.device.peripheralId isEqualToString:self.lock.bleTool.connectedPeripheral.identifier.UUIDString]
                    &&[self.lock.device.deviceSN isEqualToString:self.lock.bleTool.connectedPeripheral.serialNumber]
                    &&[self.lock.device.softwareVersion isEqualToString:softwareRev]) {
                    //蓝牙连接上才检查固件
                    [self checkBleOTA];
                }else{
                    //服务器无蓝牙UUID，需要更新服务器上蓝牙的UUID
                    [self updateSoftwareVersion];
                }
            }
            else{
                [MBProgressHUD showError:Localized(@"bleNotConnect")];
            }
            
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 控件等事件方法。
///锁昵称修改文本框文字改变后，限制长度不超过16个字节。
- (void)textFieldTextDidChange:(UITextField *)sender
{
    [sender trimTextToLength:-1];
}

#pragma mark - http请求相关
///修改锁昵称。
- (void)alterDeviceNickname
{
    __weak typeof(self) weakSelf = self;
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"inputDeviceName") message:nil preferredStyle:UIAlertControllerStyleAlert];
    [ac addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textAlignment = NSTextAlignmentCenter;
        textField.textColor = KDSRGBColor(0x10, 0x10, 0x10);
        textField.font = [UIFont systemFontOfSize:13];
        [textField addTarget:weakSelf action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *newNickname = ac.textFields.firstObject.text;
        if (newNickname.length && ![newNickname isEqualToString:weakSelf.lock.name])
        {
            MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"alteringLockNickname") toView:weakSelf.view];
            [[KDSHttpManager sharedManager] alterBindedDeviceNickname:newNickname withUid:[KDSUserManager sharedManager].user.uid bleName:weakSelf.lock.device.lockName success:^{
                [hud hideAnimated:YES];
                [MBProgressHUD showSuccess:Localized(@"saveSuccess")];
                weakSelf.lock.device.lockNickName = newNickname;
                [weakSelf.tableView reloadData];
            } error:^(NSError * _Nonnull error) {
                [hud hideAnimated:YES];
                [MBProgressHUD showError:[Localized(@"saveFailed") stringByAppendingFormat:@"%ld", (long)error.localizedDescription]];
            } failure:^(NSError * _Nonnull error) {
                [hud hideAnimated:YES];
                [MBProgressHUD showError:[Localized(@"saveFailed") stringByAppendingString:error.localizedDescription]];
            }];
        }
        
    }];
    [ac addAction:cancelAction];
    [ac addAction:okAction];
    [self presentViewController:ac animated:YES completion:nil];
    
}

/**
 解析蓝牙版本为存数字的字符串以便比较大小
 @return 蓝牙版本
 */
-(NSString *)parseBluetoothVersion{
    
    //截取出字符串后带了\u0000
    //NSString *bleVesion = [self.lock.bleTool.connectedPeripheral.softwareVer componentsSeparatedByString:@"-"].lastObject;
    NSString *bleVesion ;
    
    if (!self.lock.bleTool.connectedPeripheral.softwareVer.length) {
        bleVesion = [self.lock.device.softwareVersion componentsSeparatedByString:@"-"].firstObject;
    }else{
        bleVesion = [self.lock.bleTool.connectedPeripheral.softwareVer componentsSeparatedByString:@"-"].firstObject;
    }
    
    //去掉NSString中的\u0000
    if (bleVesion.length > 9) {
        //挽救K9S第一版本的字符串带\u0000错误
        bleVesion = [bleVesion substringToIndex:9];
    }
    //去掉NSString中的V
    bleVesion = [bleVesion stringByReplacingOccurrencesOfString:@"V" withString:@""];
    //带T为测试固件
    bleVesion = [bleVesion stringByReplacingOccurrencesOfString:@"T" withString:@""];
    
    return bleVesion;
}
//Unicode 转字符串
- (NSString *)replaceUnicode:(NSString *)unicodeStr
{
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}
///检查蓝牙固件是否需要升级
- (void)checkBleOTA{
    
    //蓝牙本地固件版本号
    NSString *softwareRev = [self parseBluetoothVersion];
    
    NSString *deviceSN ;
    if (!self.lock.device.deviceSN.length) {
        deviceSN = self.lock.bleTool.connectedPeripheral.serialNumber ;
    }else{
        deviceSN = self.lock.device.deviceSN ;
    }
    
    NSLog(@"--{Kaadas}--检查OTA的softwareRev:%@",softwareRev);
    NSLog(@"--{Kaadas}--检查OTA的deviceSN:%@",deviceSN);
    
    [[KDSHttpManager sharedManager] checkBleOTAWithSerialNumber:deviceSN withCustomer:1 withVersion:softwareRev withDevNum:1 success:^(NSString *URL) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"tips") message:Localized(@"newImage") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //            NSLog(@"--{Kaadas}--URL==%@",URL);
            [self chooseOTASolution:URL];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //            [self.lock.bleTool endConnectPeripheral:self.lock.bleTool.connectedPeripheral];
        }];
        [ac addAction:okAction];
        [ac addAction:cancelAction];
        [self presentViewController:ac animated:YES completion:nil];
        
    } error:^(NSError * _Nonnull error) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"Lock OTA upgrade") message:[NSString stringWithFormat:@"%@",error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [ac addAction:okAction];
        [self presentViewController:ac animated:YES completion:nil];
        
    } failure:^(NSError * _Nonnull error) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"Lock OTA upgrade") message:[NSString stringWithFormat:@"%@",error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [ac addAction:okAction];
        [self presentViewController:ac animated:YES completion:nil];
    }];
    
}
//修改设备固件版本
-(void)updateSoftwareVersion{
    
    NSString *softwareVer = self.lock.bleTool.connectedPeripheral.softwareVer;
    if (softwareVer.length > 9) {
        softwareVer = [self.lock.bleTool.connectedPeripheral.softwareVer substringWithRange:NSMakeRange(1,8)];
    }
    
    if (softwareVer
    && self.lock.device.lockName
    && [KDSUserManager sharedManager].user.uid
    && self.lock.bleTool.connectedPeripheral.serialNumber
    && self.lock.bleTool.connectedPeripheralWithIdentifier.UUIDString) {
        
    [[KDSHttpManager sharedManager] updateSoftwareVersion:softwareVer withDevname:self.lock.device.lockName withUser_id:[KDSUserManager sharedManager].user.uid withDeviceSN:self.lock.bleTool.connectedPeripheral.serialNumber withPeripheralId:self.lock.bleTool.connectedPeripheralWithIdentifier.UUIDString success:^{
        //蓝牙连接上才检查固件
        [self checkBleOTA];
        
    } error:^(NSError * _Nonnull error) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"NetworkCauseConnectionFailure") message:[NSString stringWithFormat:@"%@",error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [ac addAction:okAction];
        [self presentViewController:ac animated:YES completion:nil];
        
    } failure:^(NSError * _Nonnull error) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"NetworkCauseConnectionFailure") message:[NSString stringWithFormat:@"%@",error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [ac addAction:okAction];
        [self presentViewController:ac animated:YES completion:nil];
    }];
    }
    else{
        
        NSLog(@"--{Kaadas}--有数据为空--异常");
    }
}

#pragma mark - 选择OTA升级方案
///根据OTA启动服务FFD0和1802，来选择TI、Psco6升级方案
-(void)chooseOTASolution:(NSString *)url{
    
    BOOL hasResetOTAServer = NO;
    for (CBService *service in self.lock.bleTool.connectedPeripheral.services) {
        //检测到OAD启动服务:FFD0 ---> TI方案
        KDSLog(@"--{Kaadas}--service.UUID==%@",service.UUID.UUIDString);
        if ([service.UUID.UUIDString isEqualToString: OADResetServiceUUID]) {
            KDSLog(@"--{Kaadas}--检测到OAD启动服务:FFD0->TI方案");
            ///先检查是否有协议栈
            [self checkIsProtocolStackWthFirmwareUrl:url];
            hasResetOTAServer = YES;
        }
        else if ([service.UUID.UUIDString isEqualToString: DFUResetServiceUUID]) {
            KDSLog(@"--{Kaadas}--检测到DFU启动服务:1802->P6方案");
            //检测到DFU启动服务:1802->P6方案
            KDSDFUVC *dfuVC = [[KDSDFUVC alloc]init];
            dfuVC.url = url;
            dfuVC.isBootLoadModel = YES;
            dfuVC.lock = self.lock;
            hasResetOTAServer = YES;
            //[self.lock.bleTool.centralManager cancelPeripheralConnection: self.lock.bleTool.connectedPeripheral];
            [self.navigationController pushViewController:dfuVC animated:YES];
        }
    }
    //蓝牙升级服务未读取到
    hasResetOTAServer?:[MBProgressHUD showSuccess:@"蓝牙信息获取不完整，请稍后再试"];
}

-(void)checkIsProtocolStackWthFirmwareUrl:(NSString *)firmwareUrl{
    
    //蓝牙本地固件版本号
      NSString *softwareRev = [self parseBluetoothVersion];
      NSString *deviceSN ;
      if (!self.lock.device.deviceSN.length) {
          deviceSN = self.lock.bleTool.connectedPeripheral.serialNumber ;
      }else{
          deviceSN = self.lock.device.deviceSN ;
      }
    KDSOADVC *otaVC = [[KDSOADVC alloc]init];
    [[KDSHttpManager sharedManager] checkBleOTAWithSerialNumber:deviceSN withCustomer:1 withVersion:softwareRev withDevNum:4 success:^(NSString *URL) {
        otaVC.protocolStackUrl = URL;
        otaVC.url = firmwareUrl;
        otaVC.lock = self.lock;
        otaVC.isBootLoadModel = YES;
        [self.navigationController pushViewController:otaVC animated:YES];
                    
       } error:^(NSError * _Nonnull error) {
           otaVC.url = firmwareUrl;
           otaVC.lock = self.lock;
           otaVC.isBootLoadModel = YES;
           [self.navigationController pushViewController:otaVC animated:YES];
           
       } failure:^(NSError * _Nonnull error) {
           otaVC.url = firmwareUrl;
           otaVC.lock = self.lock;
           otaVC.isBootLoadModel = YES;
           [self.navigationController pushViewController:otaVC animated:YES];
       }];
}

@end
