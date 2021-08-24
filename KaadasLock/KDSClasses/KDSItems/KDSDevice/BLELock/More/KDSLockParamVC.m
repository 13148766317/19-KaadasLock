//
//  KDSLockParamVC.m
//  xiaokaizhineng
//
//  Created by orange on 2019/2/14.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSLockParamVC.h"
#import "KDSLockParamCell.h"
#import "KDSMQTT.h"
#import "MBProgressHUD+MJ.h"
#import "UIView+Extension.h"
#import "KDSHttpManager+Ble.h"



@interface KDSLockParamVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,strong)NSMutableArray * gwlockParam;
///bleVersion=3时，蓝牙接口返回的型号。
@property (nonatomic, strong) NSString *model;
///bleVersion=3时，蓝牙接口返回的锁硬件版本号。
@property (nonatomic, strong) NSString *hardware;
///bleVersion=3时，蓝牙接口返回的锁软件版本号。
@property (nonatomic, strong) NSString *software;
///序列号
@property (nonatomic, strong) NSString * serialNumber;
///锁型号
@property (nonatomic, strong) NSString * lockModel;
///锁固件版本号
@property (nonatomic, strong) NSString * hardwareVer;
///锁软件版本号
@property (nonatomic, strong) NSString * lockModelType;
///锁蓝牙版本号
@property (nonatomic, strong) NSString * softwareVer;
///锁昵称
@property (nonatomic, strong) NSString * lockName;

@end

@implementation KDSLockParamVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"deviceInfo");
    self.tableView.rowHeight = 60;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    if (self.lock.gwDevice)
    {
        ////网关锁、蓝牙锁。如果是网关锁：设备型号、固件、软件版本号、蓝牙版本号从服务器获取
        MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
        [[KDSMQTTManager sharedManager] dlGetDeviceParams:self.lock.gwDevice completion:^(NSError * _Nullable error, KDSGWLockParam * _Nullable param) {
            [hud hideAnimated:YES];
            if (param) {
                
                ///8100的多一个lockversion由锁型号，锁功能集，锁软件版本，锁硬件版本之间是用分号隔开的<8100Z,8100A>字符串
                NSArray * tempArr = [param.lockversion componentsSeparatedByString:@";"];
                NSString * lockSoftwareVs;
                if (tempArr.count == 4) {
                    lockSoftwareVs = tempArr[2];
                }
                if (self.lock.gwDevice.isAdmin) {
                    [self.gwlockParam addObjectsFromArray:@[param.model,param.linkquality,param.firmware,lockSoftwareVs ?: param.swversion,param.hwversion,param.macaddr]];
                    NSLog(@"self.gwlockParam=%@",self.gwlockParam);
                }else{
                    [self.gwlockParam addObjectsFromArray:@[self.lock.gwDevice.nickName ?: self.lock.gwDevice.deviceId,param.model,param.linkquality,param.firmware,lockSoftwareVs ?: param.swversion,param.hwversion,param.macaddr]];
                }
                [self.tableView reloadData];
                
            }else{
                
                [MBProgressHUD showError:Localized(@"Failed to read data")];
                if (!self.lock.gwDevice.isAdmin) {
//                     [self.gwlockParam addObjectsFromArray:@[self.lock.gwDevice.nickName ?: self.lock.gwDevice.deviceId]];
                    [self.gwlockParam addObjectsFromArray:@[self.lock.gwDevice.nickName]];
                }
                [self.tableView reloadData];
            }
            
        }];
    }
    else if (self.lock.device.bleVersion.intValue >= 3)
    {
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
    BOOL iszbLock = [self.lock.gwDevice.device_type isEqualToString:@"kdszblock"];
    if (self.lock.device.is_admin.boolValue || self.lock.gwDevice.isAdmin) {
       
        return section = iszbLock ? 6 : 5;
    }
    return section = iszbLock ? 7 : 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
    KDSLockParamCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    [self setDetailTitle];
    
    if (!cell)
    {
        cell = [[KDSLockParamCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }

    if ([self.lock.gwDevice.device_type isEqualToString:@"kdszblock"]) {
        if (self.lock.gwDevice.isAdmin) {
            NSArray * titles = @[Localized(@"serialNumber"),Localized(@"Link signal"), Localized(@"firmwareVer"), Localized(@"softwareVer"), Localized(@"HardwareVersion"),Localized(@"macaddr")];
            cell.title = titles[indexPath.row];
            cell.hideArrow = YES;
            if (self.gwlockParam.count>0) {
                cell.content = self.gwlockParam[indexPath.row];
            }
         
        }else{
            NSArray * titles = @[Localized(@"deviceName"),Localized(@"serialNumber"),Localized(@"Link signal"), Localized(@"firmwareVer"), Localized(@"softwareVer"), Localized(@"HardwareVersion"),Localized(@"macaddr")];
            cell.title = titles[indexPath.row];
            cell.hideArrow = YES;
            if (self.gwlockParam.count > 0) {
                if (self.gwlockParam.count == 1) {
                    
                    //防止没网崩溃
                    switch (indexPath.row) {
                        case 0:
                            cell.content = self.gwlockParam[0];
                            break;
                            
                        default:
                            break;
                    }

                }
                else{
                    cell.content = self.gwlockParam[indexPath.row];
                }
            }
        }

    }else{
        NSArray *titles;
        NSArray * detailTitles;
        
        if (self.lock.device.is_admin.boolValue) {
            titles = @[Localized(@"serialNumber"), Localized(@"deviceModel"), Localized(@"firmwareVer"), Localized(@"softwareVer"), Localized(@"BLEVer")];
            detailTitles = @[self.serialNumber,self.lockModel,self.hardwareVer,self.lockModelType,self.softwareVer];
            cell.hideArrow = YES;
            cell.title = titles[indexPath.row];
            cell.content = detailTitles[indexPath.row];
           
        }else{
            titles = @[Localized(@"deviceName"),Localized(@"serialNumber"), Localized(@"deviceModel"), Localized(@"firmwareVer"), Localized(@"softwareVer"), Localized(@"BLEVer")];
            detailTitles = @[self.lockName,self.serialNumber,self.lockModel,self.hardwareVer,self.lockModelType,self.softwareVer];
            cell.hideArrow = YES;
            cell.title = titles[indexPath.row];
            cell.content = detailTitles[indexPath.row];
        }
    }

//    cell.hideSeparator = indexPath.row == 1;
    return cell;
}

-(void)setDetailTitle
{
    //设备名称
     self.lockName = self.lock.device.lockNickName ?: self.lock.device.lockName;
    
    //序列号
    if (!self.lock.bleTool.connectedPeripheral.serialNumber) {
        if (!self.serialNumber) {
            self.serialNumber = self.lock.device.deviceSN;
        }
    }else{
        self.serialNumber = self.lock.bleTool.connectedPeripheral.serialNumber;
        
    }
    
    //换锁会造成不准确
    NSString *model = self.lock.device.model;
    model = model.length>5 ? [model substringToIndex:5] : model;

    ///暂时不做过滤V
    //                NSRange range = [self.lock.device.model rangeOfString:@"V" options:NSBackwardsSearch];
    //                if (range.location != NSNotFound)
    //                {
    //                    model = [model substringToIndex:range.location];
    //                }
    //                range = [model rangeOfString:@"0"];
    //                if (range.location != NSNotFound)
    //                {
    //                    model = [model substringToIndex:range.location];
    //                }
    self.lockModel = self.model ?: model;
    
     //蓝牙版本
    if (self.lock.device.bleVersion.intValue < 3)
    {
        self.hardwareVer = self.lock.bleTool.connectedPeripheral.hardwareVer;
    }
    else
    {
        if (self.hardware.length >0) {
            self.hardwareVer = self.hardware;
        }else{
            if (!self.lock.bleTool.connectedPeripheral.hardwareVer) {
                self.hardwareVer = self.hardwareVer;
            } else {
                self.hardwareVer = [self.lock.bleTool.connectedPeripheral.hardwareVer componentsSeparatedByString:@"-"].lastObject;
            }
        }
    }
    //固件版本
    if (self.lock.device.bleVersion.intValue < 3)
    {
        self.lockModelType = self.lock.bleTool.connectedPeripheral.lockModelType;
    }
    else
    {
        if (self.software.length >0) {
            self.lockModelType = self.software;
        }else{
            
            if (!self.lock.bleTool.connectedPeripheral.softwareVer) {
                self.lockModelType = self.lockModelType;
            } else {
                self.lockModelType = [self.lock.bleTool.connectedPeripheral.softwareVer componentsSeparatedByString:@"-"].lastObject;
            }
        }
    }
  
   //软件版本
    if (!self.lock.bleTool.connectedPeripheral.softwareVer) {
        if (!self.softwareVer) {
            self.softwareVer = self.lock.device.softwareVersion;
        }
    }else{
        if (self.lock.device.bleVersion.intValue < 3)
        {
            self.softwareVer = self.lock.bleTool.connectedPeripheral.softwareVer;
        }
        else
        {
            self.softwareVer = [self.lock.bleTool.connectedPeripheral.softwareVer componentsSeparatedByString:@"-"].firstObject;
        }
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     if ([self.lock.gwDevice.device_type isEqualToString:@"kdszblock"]) {
         if (indexPath.row == 0) {
             if (!self.lock.gwDevice.isAdmin) {
              //修改网关锁锁昵称
              [self alterDeviceNickname];
             }
         }
     }else{
         if (!self.lock.device.is_admin.boolValue) {
             if (indexPath.row == 0) {
                 //蓝牙修改锁昵称
                 [self alterDeviceNickname];
             }
         }
     }
}

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
            if ([self.lock.gwDevice.device_type isEqualToString:@"kdszblock"]){
                NSString *nn = weakSelf.lock.gwDevice.nickName;
                weakSelf.lock.gwDevice.nickName = newNickname;
                [[KDSMQTTManager sharedManager] updateDeviceNickname:weakSelf.lock.gwDevice completion:^(NSError * _Nullable error, BOOL success) {
                    [hud hideAnimated:YES];
                    if (success)
                    {
                        [MBProgressHUD showSuccess:Localized(@"saveSuccess")];
                        weakSelf.lock.gwDevice.nickName = newNickname;
                        [self.gwlockParam replaceObjectAtIndex:0 withObject:self.lock.gwDevice.nickName];
                        [weakSelf.tableView reloadData];
                    }
                    else
                    {
                        [MBProgressHUD showError:Localized(@"saveFailed")];
                        weakSelf.lock.gwDevice.nickName = nn;
                    }
                }];
                return;
            }
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
    
    //修改按钮
    [cancelAction setValue:KDSRGBColor(51, 51, 51) forKey:@"titleTextColor"];
    
    [ac addAction:cancelAction];
    [ac addAction:okAction];
    [self presentViewController:ac animated:YES completion:nil];
}

///密码昵称文本输入框，长度不能超过16
- (void)textFieldTextDidChange:(UITextField *)sender
{
    [sender trimTextToLength:-1];
}

#pragma mark --Lazy load

- (NSMutableArray *)gwlockParam
{
    if (!_gwlockParam) {
        _gwlockParam = [NSMutableArray array];
    }
    return _gwlockParam;
}

@end
