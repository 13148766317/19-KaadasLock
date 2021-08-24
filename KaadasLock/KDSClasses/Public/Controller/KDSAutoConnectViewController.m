//
//  KDSAutoConnectViewController.m
//  xiaokaizhineng
//
//  Created by orange on 2019/3/1.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSAutoConnectViewController.h"
#import "KDSDBManager.h"
#import "KDSHttpManager+Ble.h"

@interface KDSAutoConnectViewController ()

///记录上一个蓝牙工具的代理。
@property (nonatomic, weak, nullable) id<KDSBluetoothToolDelegate> preDelegate;
///标记是否是长时间不操作导致断开蓝牙连接。
@property (nonatomic, assign) BOOL isLongtimeNoOp;

@end

@implementation KDSAutoConnectViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.autoConnect = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.lock.bleTool)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLongtimeNoOperation:) name:KDSUserLongtimeNoOperationNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userActivateOperationNotification:) name:KDSUserActivateOperationNotification object:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.lock.bleTool)
    {
        if (!self.lock.bleTool.connectedPeripheral && self.autoConnect)
        {
            [self.lock.bleTool beginScanForPeripherals];
            self.lock.state = KDSLockStateInitial;
        }
        if (self.autoConnect)
        {
            if (!self.preDelegate) self.preDelegate = self.lock.bleTool.delegate;
            self.lock.bleTool.delegate = self;
        }
    }
}

- (void)dealloc
{
    if (self.preDelegate) self.lock.bleTool.delegate = self.preDelegate;
}

#pragma mark - KDSBluetoothToolDelegate
- (void)didDiscoverPeripheral:(CBPeripheral *)peripheral
{
    if ([peripheral.advDataLocalName isEqualToString:self.lock.device.lockName]
        ||[peripheral.identifier.UUIDString isEqualToString:self.lock.device.peripheralId])
    {
        NSLog(@"--{Kaadas}--beginConnectPeripheral--Auto1");
        [self.lock.bleTool beginConnectPeripheral:peripheral];
    }
}

- (void)didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self.lock.bleTool stopScanPeripherals];
    if (self.lock.device.bleVersion.intValue == 1)
    {
        self.lock.connected = YES;
        self.lock.state = KDSLockStateNormal;
    }
}

- (void)centralManagerDidStopScan:(CBCentralManager *)cm
{
    if (!self.lock.bleTool.connectedPeripheral)
    {
        self.lock.state = KDSLockStateBleNotFound;
    }
}

- (void)didGetSystemID:(CBPeripheral *)peripheral
{
    
    __weak typeof(self) weakSelf = self;
    [self.lock.bleTool authenticationWithPwd1:self.lock.device.password1 pwd2:self.lock.device.password2 completion:^(KDSBleError error) {
        
        if (error == KDSBleErrorDuplOrAuthenticating) return;
        if (error == KDSBleErrorSuccess)
        {
            weakSelf.lock.connected = YES;
            weakSelf.lock.state = KDSLockStateNormal;
            if (weakSelf.authenticateSuccess)
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    weakSelf.authenticateSuccess();
                });
            }
            
            if (peripheral.bleVersion > weakSelf.lock.device.bleVersion.intValue)
            {
                [[KDSHttpManager sharedManager] updateBleVersion:peripheral.bleVersion withUid:[KDSUserManager sharedManager].user.uid bleName:weakSelf.lock.device.lockName success:nil error:nil failure:nil];
                ///更新过蓝牙模块版本号之后发出通知，刷新数据源
                [[NSNotificationCenter defaultCenter] postNotificationName:KDSLockUpdateBleVersionNotification object:nil userInfo:nil];
            }
            return;
        }
        weakSelf.lock.state = KDSLockStateUnauth;
    }];
}
- (void)didGetFunctionSet:(CBPeripheral *)peripheral
{
    if (!self.lock.device.functionSet) {
        //服务器不存在门锁功能集，则更新
        [[KDSHttpManager sharedManager] updateFunctionSet:peripheral.functionSet withUid:[KDSUserManager sharedManager].user.uid bleName:self.lock.device.lockName success:nil error:nil failure:nil];
    }
}

- (void)didReceiveDeviceElctInfo:(int)elct
{
    self.lock.connected = YES;
    self.lock.power = elct;
    [[KDSDBManager sharedManager] updatePower:elct withBleName:self.lock.device.lockName];
    [[KDSDBManager sharedManager] updatePowerTime:NSDate.date withBleName:self.lock.device.lockName];
    [[NSNotificationCenter defaultCenter] postNotificationName:KDSDeviceSyncNotification object:nil userInfo:nil];
}

- (void)didDisConnectPeripheral:(CBPeripheral *)peripheral
{
    self.lock.connected = NO;
    if (self.isLongtimeNoOp)
    {
        self.lock.state = KDSLockStateBleNotFound;
        return;
    }
    self.lock.state = KDSLockStateInitial;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"--{Kaadas}--beginConnectPeripheral--Auto2");
        [self.lock.bleTool beginConnectPeripheral:peripheral];
    });
}

#pragma mark - 通知
///用户长时间没操作，断开蓝牙连接。
- (void)userLongtimeNoOperation:(NSNotification *)noti
{
    if (self.lock.bleTool.connectedPeripheral)
    {
        self.isLongtimeNoOp = YES;
        [self.lock.bleTool endConnectPeripheral:self.lock.bleTool.connectedPeripheral];
    }
}

///用户激活操作，重新连接蓝牙。
- (void)userActivateOperationNotification:(NSNotification *)noti
{
    if (self.lock.bleTool && self.isLongtimeNoOp)
    {
        self.isLongtimeNoOp = NO;
        if (!self.lock.bleTool.connectedPeripheral)
        {
            self.lock.state = KDSLockStateInitial;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.lock.bleTool beginScanForPeripherals];
            });
        }
    }
}

@end
