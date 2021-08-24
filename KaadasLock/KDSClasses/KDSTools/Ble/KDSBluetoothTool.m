//
//  KDSBluetoothTool.m
//  BleTest
//
//  Created by zhaowz on 2017/6/8.
//  Copyright © 2017年 zhaowz. All rights reserved.
//


#import "KDSBluetoothTool.h"
#import "KDSBluetoothTool+Category.h"
#import "NSTimer+KDSBlock.h"
#import "KDSBleAssistant.h"

NSString * const KDSBleDidDisconnectNotification = @"KDSBleDidDisconnectNotification";
NSString * const KDSLockDidOpenNotification = @"KDSLockDidOpenNotification";
NSString * const KDSLockDidCloseNotification = @"KDSLockDidCloseNotification";
NSString * const KDSLockUsersDidUpdateNotification = @"KDSLockUsersDidUpdateNotification";
NSString * const KDSLockSchedulesDidUpdateNotification = @"KDSLockSchedulesDidUpdateNotification";
NSString * const KDSLockAuthFailedNotification = @"KDSLockAuthFailedNotification";
NSString * const KDSLockDidAlarmNotification = @"KDSLockDidAlarmNotification";
NSString * const KDSLockDidReportNotification = @"KDSLockDidReportNotification";

@interface KDSBluetoothTool ()
@property (nonatomic, strong) NSMutableArray *searchArray;//扫描的设备
/**以下的特征值保存是为了适配新的蓝牙锁的*/
@property (nonatomic, strong) CBCharacteristic *batteryCharacteristic; //电量
@property (nonatomic, strong) CBCharacteristic *systemIDCharacteristic; //系统ID
@property (nonatomic, strong) CBCharacteristic *modelNumCharacteristic; //
@property (nonatomic, strong) CBCharacteristic *seriaNumCharacteristic; //
@property (nonatomic, strong) CBCharacteristic *firmwareCharacteristic; //锁型号
@property (nonatomic, strong) CBCharacteristic *hardwareCharacteristic; //硬件版本
@property (nonatomic, strong) CBCharacteristic *softwareCharacteristic; //软件版本
@property (nonatomic, strong) CBCharacteristic *mfrNameCharacteristic;  //生产商
///锁状态特征(FFF0服务FFF3特征)，在心跳定时器中读此特征来更新锁的状态。
@property (nonatomic, strong) CBCharacteristic *lockStateCharacteristic;
@property (nonatomic, strong) CBCharacteristic *functionSetCharacteristic;//功能集
@property (nonatomic, strong) NSData *systemID;
/**传输序号,每次传输+1，到了255置为50 (为了区分心跳包 设置范围为50-255)*/
@property (nonatomic, assign) int tsn;
///心跳包tsn 1 - 49
@property (nonatomic, assign) NSInteger heartbeatTsn;
@property (nonatomic, weak) NSTimer *heartbeatTimer;

///当前正在搜索的用户id，应该小于锁能设置的最多密码数。初始化时=-1，如果在[0, maxUsers)之间，应该启动搜索。
@property (nonatomic, assign) NSInteger retrievingUserId;
///搜索到的用户类型数组。不管成功与否，每次回调执行时都应该添加一个对象进来。
@property (nonatomic, strong) NSMutableArray<KDSBleUserType *> *retrievedUsersArr;
///当前正在搜索的计划id，应该小于锁能设置的最大计划数。初始化时=-1，如果在[0, maxSchedules)之间，应该启动搜索
@property (nonatomic, assign) NSInteger retrievingScheduleId;
///搜索到的计划数组。不管成功与否，每次回调执行时都应该添加一个对象进来。
@property (nonatomic, strong) NSMutableArray<KDSBleScheduleModel *> *retrievedSchedulesArr;
///用于执行停止搜索蓝牙外设的block，在开始搜索外设时创建，10秒后执行。如果10秒不到又执行搜索外设，则先取消执行上一次创建的block。
@property (nonatomic, copy) dispatch_block_t stopScanPeripheralBlock;
///标记锁是否处于管理员模式。锁进入和退出管理员模式蓝牙会自动上报。
@property (nonatomic, assign) BOOL onAdminMode;

@end

#pragma mark - Singleton
static KDSBluetoothTool *bleTool = nil;
@implementation KDSBluetoothTool

#define DeviceAdvDataPrefix         @"PLP"//飞利浦

#pragma mark - getter setter 初始化方法
/*Control判断是否加密
 Tsn 传输序号
 Check校验帧（累加和，校验数据是否出错）
 Cmd命令码（用来说明这条命令是用来干嘛的）
 */

//搜索到的设备
- (NSMutableArray *)searchArray{
    if (_searchArray == nil) {
        _searchArray = [NSMutableArray array];
    }
    return _searchArray;
}

- (NSMutableDictionary<NSString *,KDSBleTunnelTask *> *)tasksMDict
{
    if (_tasksMDict == nil)
    {
        _tasksMDict = [NSMutableDictionary dictionary];
    }
    return _tasksMDict;
}

- (NSDateFormatter *)dateFormatter
{
    if (_dateFormatter == nil)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}

- (NSMutableArray<KDSBleUserType *> *)retrievedUsersArr
{
    if (_retrievedUsersArr == nil)
    {
        _retrievedUsersArr = [NSMutableArray array];
    }
    return _retrievedUsersArr;
}

- (NSArray<KDSBleUserType *> *)users
{
    NSMutableArray *arr = [NSMutableArray array];
    for (KDSBleUserType *user in self.retrievedUsersArr)
    {
        if (user.keyType != KDSBleKeyTypeInvalid) [arr addObject:user];
    }
    return arr.copy;
}

- (NSMutableArray<KDSBleScheduleModel *> *)retrievedSchedulesArr
{
    if (_retrievedSchedulesArr == nil)
    {
        _retrievedSchedulesArr = [NSMutableArray array];
    }
    return _retrievedSchedulesArr;
}

- (NSArray<KDSBleScheduleModel *> *)schedules
{
    NSMutableArray *arr = [NSMutableArray array];
    for (KDSBleScheduleModel *model in self.retrievedSchedulesArr)
    {
        if (model.keyType != KDSBleKeyTypeInvalid) [arr addObject:model];
    }
    return arr.copy;
}

- (instancetype)initWithVC:(id)viewController{
    if (self = [super init]) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        _delegate = viewController;
        self.tsn = 50;
        self.isAdmin = NO;
        self.heartbeatTsn = 1;
        _dataM = [NSMutableData data];
        _bleWiFiCRCData = [NSMutableData data];
        self.retrievingUserId = -1;
        self.retrievingScheduleId = -1;
    }
    return self;
}
- (instancetype)init{
    if (self = [super init]) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

- (void)setTsn:(int)tsn{
    tsn = tsn > 255 ? 50 : tsn;
    tsn = tsn < 50 ? 255 : tsn;
    _tsn = tsn;
}
- (void)setHeartbeatTsn:(NSInteger)heartbeatTsn{
    heartbeatTsn = heartbeatTsn < 1 ? 49 : heartbeatTsn;
    heartbeatTsn = heartbeatTsn > 49 ? 1 : heartbeatTsn;
    _heartbeatTsn = heartbeatTsn;
}
#pragma mark - 开始搜索蓝牙
- (void)beginScanForPeripherals{
    [self.searchArray removeAllObjects];
    //不过滤服务搜索蓝牙
    [_centralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    if (self.stopScanPeripheralBlock)
    {
        dispatch_block_cancel(self.stopScanPeripheralBlock);
        self.stopScanPeripheralBlock = nil;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_block_t block = dispatch_block_create(DISPATCH_BLOCK_ASSIGN_CURRENT, ^{
        if (weakSelf.centralManager.isScanning) {
            [weakSelf stopScan];
        }
    });
    self.stopScanPeripheralBlock = block;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        block();
    });
}
#pragma mark - 停止扫描蓝牙
- (void)stopScanPeripherals{
    if (_centralManager.isScanning)
    {
        [self stopScan];
        [self.searchArray removeAllObjects];
    }
}

- (void)stopScan
{
    [self.centralManager stopScan];
    if ([self.delegate respondsToSelector:@selector(centralManagerDidStopScan:)])
    {
        [self.delegate centralManagerDidStopScan:self.centralManager];
    }
}
#pragma mark - 开始连接蓝牙
- (void)beginConnectPeripheral:(CBPeripheral *)peripheral{
    
    //1.是相同的连接就返回
    if ([_connectedPeripheral.advDataLocalName isEqualToString:peripheral.advDataLocalName] || !peripheral) {
        
        return;
    }
    //2.不是连接相同的设备,就先断开.之前的设备,然后重新
    if (_connectedPeripheral.state == CBPeripheralStateConnected && ![_connectedPeripheral.advDataLocalName isEqualToString:peripheral.advDataLocalName]) {
        
        [self.centralManager cancelPeripheralConnection:_connectedPeripheral];
    }
    if (peripheral.state==CBPeripheralStateConnected) {
        
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
    
    [self.centralManager connectPeripheral:peripheral options:nil];
    
}
#pragma mark - 断开连接蓝牙设备
- (void)endConnectPeripheral:(CBPeripheral *)peripheral{
    if (peripheral.state == CBPeripheralStateConnected) {
        [self.centralManager cancelPeripheralConnection:peripheral];
        self.pwd1 = nil;
        self.pwd2 = nil;
    }
}

/**断开连接蓝牙设备*/
- (void)endConnectPeripheral {
    if (self.connectedPeripheral) {
        [self endConnectPeripheral:self.connectedPeripheral];
    }
}
#pragma mark - 重启OAD服务
- (void)resetOAD:(CBPeripheral *)peripheral{
    ///对FFD1写1，重启OAD服务
    Byte byte[1];
    byte[0] = 1;//写入<01>启动OAD复位服务
    NSData *data = [NSData dataWithBytes:byte length:sizeof(byte)];
    
    NSLog(@"--00--00--data===%@,%@,%@",data,self.OADCharacteristic,self);
    [self.connectedPeripheral writeValue:data forCharacteristic:self.OADCharacteristic type:CBCharacteristicWriteWithResponse];
    
}
#pragma mark - 重启DFU服务
- (void)resetDFU:(CBPeripheral *)peripheral{
    ///对2A06写ASCII码01，重启DFU服务
    Byte byte[1];
    byte[0] = 1;//写入<01>启动DFU复位服务
    NSData *data = [NSData dataWithBytes:byte length:sizeof(byte)];
    
    KDSLog(@"--{Kaadas}--data===%@,%@",data,self.DFUCharacteristic);
    ///对于P6平台的2A06，需要CBCharacteristicWriteWithoutResponse才能写入成功。
    [self.connectedPeripheral writeValue:data forCharacteristic:self.DFUCharacteristic type:CBCharacteristicWriteWithoutResponse];
    
}
#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if ([_delegate respondsToSelector:@selector(discoverManagerDidUpdateState:)]) {
        [_delegate discoverManagerDidUpdateState:central];
    }
    if (central.state == CBPeripheralManagerStatePoweredOn) {
        //蓝牙打开，开始搜索设备
        [self beginScanForPeripherals];
    }else{
        KDSLog(@"请打开手机蓝牙");
        self.pwd3 = nil;
        if ([_delegate respondsToSelector:@selector(didDisConnectPeripheral:)] && _connectedPeripheral) {
            
            [_delegate didDisConnectPeripheral:_connectedPeripheral];
            _connectedPeripheral = nil;
            _connectedPeripheralWithIdentifier = nil;
            
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    //NSLog(@"\n\n===peripheral名:%@ \n===广播名:%@\n ===设备uuid:%@\n  ===peripheral:%@\n ===设备广播数据:%@\n\n",peripheral.name,advertisementData[@"kCBAdvDataLocalName"],peripheral.identifier.UUIDString,peripheral,advertisementData);
    //解析广播包中的kCBAdvDataLocalName 区分凯迪仕的设备
    NSString *key = CBAdvertisementDataLocalNameKey;
    if ([advertisementData[key] hasPrefix:@"KdsLock"]
        || [advertisementData[key] hasPrefix:@"KDS"]
        || [advertisementData[key] containsString:@"Bootloader"]
        || [advertisementData[key] containsString:@"OAD"]
        //        || [advertisementData[key] containsString:@"ORG"]
        //        || [advertisementData[key] containsString:@"Philips"]
        || [advertisementData[key] containsString:@"XK"]
        || [advertisementData[key] containsString:@"Rexense"]//瑞瀛网关（测试）
        
        ) {
        if ([self.searchArray containsObject:peripheral]) {
            return;
        }
        peripheral.directBindable = NO;//默认设置为非直接绑定
        NSData *dd = advertisementData[@"kCBAdvDataManufacturerData"];
        if (dd && dd.length == 23) {//美标锁专用的蓝牙广播协议
            NSData *snData = [dd subdataWithRange:NSMakeRange(dd.length-18, 13)];
            //            NSData *modelTypeData = [dd subdataWithRange:NSMakeRange(3,2)];//产品类型
            NSData *lockModelTypeData = [dd subdataWithRange:NSMakeRange(dd.length-5,5)];
            NSData *bindData = [dd subdataWithRange:NSMakeRange(2, 1)];//支持的绑定方式
            NSString *snStr = [[NSString alloc] initWithData:snData encoding:NSASCIIStringEncoding];
            //            NSString *modelType = [[NSString alloc] initWithData:modelTypeData encoding:NSASCIIStringEncoding];
            NSString *lockModelType = [[NSString alloc] initWithData:lockModelTypeData encoding:NSASCIIStringEncoding];
            if (![advertisementData[key] containsString:@"Bootloader"]) {
                peripheral.serialNumber  = snStr;
                peripheral.lockModelType = lockModelType;
                unsigned bytes = *(unsigned*)(bindData.bytes);
                peripheral.menuBindable = bytes & 0x1;
                peripheral.directBindable = (bytes >> 1) & 0x1;
                peripheral.isBleAndWifi = (bytes >> 2) & 0x1;
            }
        }
        peripheral.connectable = [[advertisementData[@"kCBAdvDataIsConnectable"] stringValue] isEqual:@"1"]? YES:NO;
        peripheral.advDataLocalName = advertisementData[key];
        [self.searchArray addObject:peripheral];
        [self.searchArray addObject:peripheral];
        peripheral.advDataLocalName = advertisementData[key];
        if ([_delegate respondsToSelector:@selector(didDiscoverPeripheral:)]) {
            [_delegate didDiscoverPeripheral:peripheral];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    self.tsn = 50;
    self.heartbeatTsn = 1;
    _connectedPeripheral = peripheral;
    _connectedPeripheralWithIdentifier = peripheral.identifier;
    
    //判断创建的字符串内容是否以某个字符开始
    //    if ([peripheral.name hasPrefix:@"KDS"] || [peripheral.name hasPrefix:@"KdsLock"]) {
    ////        peripheral.isNewDevice = NO;
    //    }else{
    //        peripheral.isNewDevice = YES;
    NSLog(@"peripheral.advDataLocalName=%@",peripheral.advDataLocalName);
    NSInteger allLenth =peripheral.advDataLocalName.length;
    
    if (allLenth >= 12) {
        //取出mac码
        NSString *orgStr = [peripheral.advDataLocalName substringFromIndex:allLenth-12];
        NSData *password1 = [orgStr dataUsingEncoding:NSASCIIStringEncoding];
        
        //发布版本去掉 ：这个是测试版蓝牙使用的，和服务器返回的不一样，正式产品不能使用这个值做鉴权密码。
        //self.pwd1 = [KDSBleAssistant convertDataToHexStr:password1];
        NSLog(@"--{Kaadas}--mac赋值后self.pwd1=%@",self.pwd1);
    }
    
    //    }获取门锁信息失败
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    [self stopScan];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    KDSLog(@"连接蓝牙失败:%@",error);
    if ([self.delegate respondsToSelector:@selector(centralManager:didFailToConnectPeripheral:error:)])
    {
        [self.delegate centralManager:central didFailToConnectPeripheral:peripheral error:error];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    KDSLog(@"断开蓝牙%@ error:%@",peripheral.name,error);
    [[NSNotificationCenter defaultCenter] postNotificationName:KDSBleDidDisconnectNotification object:nil userInfo:@{@"peripheral" : peripheral}];
    _connectedPeripheral = nil;
    _connectedPeripheralWithIdentifier = nil;
    if (peripheral.isNewDevice) {
        self.pwd3 = nil;
        //        self.onAdminMode = NO;
        [_heartbeatTimer invalidate];
        _heartbeatTimer = nil;
    }
    
    if ([_delegate respondsToSelector:@selector(didDisConnectPeripheral:)]) {
        [_delegate didDisConnectPeripheral:peripheral];
    }
}

#pragma mark - CBPeripheralDelegate
///只要扫描到服务就会调用
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //默认是老蓝牙模块
        peripheral.isNewDevice = NO;
        peripheral.bleVersion = 1;
        for (CBService *sevice in peripheral.services) {
            //            KDSLog(@"--{Kaadas}--seviceUUIDString:%@",sevice.UUID.UUIDString);
            if ([sevice.UUID.UUIDString isEqualToString:OADResetServiceUUID]
                ||[sevice.UUID.UUIDString isEqualToString:DFUResetServiceUUID]) {
                //存在FFD0或1802服务，OAD复位服务
                peripheral.isNewDevice = YES;
                peripheral.bleVersion = 2;
                NSLog(@"--{Kaadas}--bleVersion:%d",peripheral.bleVersion);
            }
            [peripheral discoverCharacteristics:nil forService:sevice];//订阅服务下面所有的特征
        }
        
        if ([_delegate respondsToSelector:@selector(didConnectPeripheral:)]) {
            [_delegate didConnectPeripheral:peripheral];
        }
        
    });
}
///只要扫描到特征就会调用
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    
    if (error){
        KDSLog(@"获取服务:%@的特征失败: %@", service.UUID, error);
        return;
    }
    
    UInt64 uuid = strtoul(service.UUID.UUIDString.UTF8String, 0, 16);
    KDSBleService serviceType = (KDSBleService)uuid;
    KDSLog(@"读的服务-service===%@ %llx",service.characteristics, uuid);
    
    switch (serviceType)
    {
        case KDSBleServiceModule: //模块参数。该服务包含电量和时间2个特征。
            for (CBCharacteristic *characteristic in service.characteristics) {
                KDSLog(@"读的服务-模块信息 (电量 pwd3):severUUId:%@====charUUId:%@",service.UUID.UUIDString,characteristic.UUID.UUIDString);
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                if ([characteristic.UUID.UUIDString isEqualToString:batteryDUUID]) {
                    [peripheral readValueForCharacteristic:characteristic];
                    //电量特征值
                    _batteryCharacteristic = characteristic;
                }
            }
            break;
            
        case KDSBleServiceDevice: //设备信息参数。该服务包含设备MAC地址、模块代号、序列号、锁型号、硬件版本、软件版本6个特征。
            for (CBCharacteristic *characteristic in service.characteristics) {
                KDSLog(@"读的服务-BLE设备信息参数:severUUId:%@====charUUId:%@",service.UUID.UUIDString,characteristic.UUID.UUIDString);
                //监听characteristic值变化
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                if ([characteristic.UUID.UUIDString isEqualToString:systemIDUUID]) {
                    _systemIDCharacteristic = characteristic;
                    [peripheral readValueForCharacteristic:characteristic];
                }
                else if ([characteristic.UUID.UUIDString isEqualToString:modelNumUUID]) {
                    [peripheral readValueForCharacteristic:characteristic];
                    _modelNumCharacteristic = characteristic;
                }
                else if ([characteristic.UUID.UUIDString isEqualToString:seriaLNumUUID]) {
                    _seriaNumCharacteristic = characteristic;
                }
                else if ([characteristic.UUID.UUIDString isEqualToString:firmwareUUID]) {
                    _firmwareCharacteristic = characteristic;
                    [peripheral readValueForCharacteristic:characteristic];
                }
                else if ([characteristic.UUID.UUIDString isEqualToString:hardwareUUID]) {
                    _hardwareCharacteristic = characteristic;
                    [peripheral readValueForCharacteristic:characteristic];
                }
                else if ([characteristic.UUID.UUIDString isEqualToString:mfrNameUUID]) {
                    _mfrNameCharacteristic = characteristic;
                }
                else if ([characteristic.UUID.UUIDString isEqualToString:softwareUUID]) {
                    _softwareCharacteristic = characteristic;
                    [peripheral readValueForCharacteristic:characteristic];
                }
            }
            break;
            
        case KDSBleServiceLock:   // ///门锁参数。该服务包含锁的类型、功能、状态等特征。
            for (CBCharacteristic *characteristic in service.characteristics)
            {
                if ([characteristic.UUID.UUIDString isEqualToString:kLockStateUUID])
                {
                    self.lockStateCharacteristic = characteristic;
                }
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                [peripheral readValueForCharacteristic:characteristic];
            }
            break;
            
        case KDSBleServiceApp2BleTunnel:  // 晾衣机  BLE->APP 配网通道【服务 UUID:0xFFC5】
            for (CBCharacteristic *characteristic in service.characteristics) {
                //charUUId:FFE9 这个时候可以与蓝牙设备交互 记录此时的characteristic
                KDSLog(@"读的服务-APP-->BLE数据通道severUUId:%@====charUUId:%@",service.UUID.UUIDString,characteristic.UUID.UUIDString);
                //主动去读取一次外围设备的消息
                [peripheral readValueForCharacteristic:characteristic];
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                self.writeCharacteristic = characteristic;
                if (_delegate && [_delegate respondsToSelector:@selector(didReceiveWriteCharacteristic)]) {
                    [_delegate didReceiveWriteCharacteristic];
                }
                if (self.connectedPeripheral.isNewDevice) {
                    //获取SystemID
                    [self getDeviceInfoWithDevType:DeviceInfoSystemID];
                    //获取SN码
                    [self getDeviceInfoWithDevType:DeviceInfoSerialNum];
                    //发送心跳包
                    [self createHeartbeatTimer];
                }
            }
            break;
            
        case KDSBleServiceBle2AppTunnel: //APP->BLE 配网通道【服务 UUID:0xFFC0】
            for (CBCharacteristic *characteristic in service.characteristics) {
                KDSLog(@"读的服务-BLE-->APP数据通道:severUUId:%@====charUUId:%@",service.UUID.UUIDString,characteristic.UUID.UUIDString);
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                if ([characteristic.UUID.UUIDString isEqualToString:kFFE1])
                {
                    peripheral.bleVersion = 3;
                    NSLog(@"--{Kaadas}--bleVersion:%d",peripheral.bleVersion);
                    _functionSetCharacteristic = characteristic;
                    [peripheral readValueForCharacteristic:characteristic];
                }else if ([characteristic.UUID.UUIDString isEqualToString:kSmartHangerUUID]){
                    NSLog(@"zhu==晾衣机进入到蓝牙配网的通道");
                    peripheral.bleVersion = 3;
                    NSLog(@"--{Kaadas}--bleVersion:%d",peripheral.bleVersion);
                    _functionSetCharacteristic = characteristic;
                    [peripheral readValueForCharacteristic:characteristic];
                }
                
            }
            break;
            //APP->BLE配网通道 write without response
        case KDSApp2BleDisNetworkTunnel:
            for (CBCharacteristic * characteristic in service.characteristics) {
                KDSLog(@"写的服务APP-->BLE数据通道:severUUId:%@====charUUId:%@",service.UUID.UUIDString,characteristic.UUID.UUIDString);
                self.writeCharacteristic = characteristic;
                
                if (characteristic.properties & CBCharacteristicPropertyNotify || characteristic.properties & CBCharacteristicPropertyIndicate) {
                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                    KDSLog(@"%@ 订阅", characteristic.UUID.UUIDString);
                }
                
                if ([characteristic.UUID.UUIDString isEqualToString:bleAndWiFiFFC1UUID])
                {
                    peripheral.bleVersion = 3;
                    NSLog(@"--{Kaadas}--bleVersion:%d",peripheral.bleVersion);
                    _functionSetCharacteristic = characteristic;
                    [peripheral readValueForCharacteristic:characteristic];
                }else if ([characteristic.UUID.UUIDString isEqualToString:bleAndWiFiFunctionSetUUID]){
                    peripheral.bleVersion = 3;
                    _functionSetCharacteristic = characteristic;
                    [peripheral readValueForCharacteristic:characteristic];
                }
                
            }
            break;
            //BLE->APP配网通道
        case KDSBle2AppDisNetworkTunnel:
            
            for (CBCharacteristic * characteristic in service.characteristics) {
                KDSLog(@"读的服务BLE-->APP数据通道:severUUId:%@====charUUId:%@",service.UUID.UUIDString,characteristic.UUID.UUIDString);
                
                if (characteristic.properties & CBCharacteristicPropertyNotify || characteristic.properties & CBCharacteristicPropertyIndicate) {
                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                    KDSLog(@"%@ 订阅", characteristic.UUID.UUIDString);
                }else {
                    KDSLog(@"%@ 不支持通知，不订阅", characteristic.UUID.UUIDString);
                }
                
                
                if ([characteristic.UUID.UUIDString isEqualToString:bleAndWiFiFunctionSetUUID])
                {
                    peripheral.bleVersion = 3;
                    _functionSetCharacteristic = characteristic;
                    [peripheral readValueForCharacteristic:characteristic];
                }else if ([characteristic.UUID.UUIDString isEqualToString:wifiLockNotifyUUID]){
                    [peripheral readValueForCharacteristic:characteristic];
                }
                
            }
            break;
            
        default:
            break;
    }
    ///检测到TI方案 - OAD启动服务
    if ([service.UUID.UUIDString isEqualToString: OADResetServiceUUID]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID.UUIDString isEqualToString:OADResetServiceCharacteristicStartOrResetUUID]) {
                self.OADCharacteristic = characteristic;
            }
        }
    }
    ///检测到TI方案 - OAD服务
    if ([service.UUID.UUIDString isEqualToString: KDSOADService]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID.UUIDString isEqualToString:KDSOADServiceCharacteristicImageIdentify]) {
                self.OADTransImageCharacteristic = characteristic;
                if ( _delegate && [_delegate respondsToSelector:@selector(startOADProcess)]) {
                    [_delegate startOADProcess];
                }else if( _delegate && [_delegate respondsToSelector:@selector(hasInBootload:)]){
                    self.OADCharacteristic = characteristic;
                    [_delegate hasInBootload:peripheral];
                }else{
                    //                    [self.centralManager cancelPeripheralConnection:_connectedPeripheral];
                }
            }
        }
    }
    ///检测到P6方案 - DFU启动服务
    if ([service.UUID.UUIDString isEqualToString: DFUResetServiceUUID]) {
        KDSLog(@"--{Kaadas}--DFU启动服务=%@", service.UUID.UUIDString);
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID.UUIDString isEqualToString:DFUResetServiceCharacteristicStartOrResetUUID]&&![peripheral.advDataLocalName containsString:@"Bootloader"]) {
                KDSLog(@"--{Kaadas}--DFU启动服务的特征");
                self.DFUCharacteristic = characteristic;
            }
        }
    }
    ///检测到P6方案 - DFU服务
    if ([service.UUID.UUIDString isEqualToString: KDSDFUService]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            KDSLog(@"--{Kaadas}--DFU服务=%@",service.UUID.UUIDString);
            if ([characteristic.UUID.UUIDString isEqualToString:KDSDFUServiceCharacteristicCommand]) {
                self.DFUTransImageCharacteristic = characteristic;
                if ( _delegate && [_delegate respondsToSelector:@selector(startDFUProcess)]) {
                    [_delegate startDFUProcess];
                }else if( _delegate && [_delegate respondsToSelector:@selector(hasInBootload:)]){
                    self.DFUCharacteristic = characteristic;
                    [_delegate hasInBootload:peripheral];
                }else{
                    [self.centralManager cancelPeripheralConnection:_connectedPeripheral];
                }
            }
        }
    }
    //
    ///App发送数据到瑞瀛网关的服务通道
    if ([service.UUID.UUIDString isEqualToString: KDSRYGWBleServiceTunnel]) {
        
        for (CBCharacteristic *characteristic in service.characteristics) {
            
            if ([characteristic.UUID.UUIDString isEqualToString:KDSRYGWBle2WiFi]) {
                self.writeCharacteristic = characteristic;
            }
            //            if ([characteristic.UUID.UUIDString isEqualToString:KDSDFUServiceCharacteristicCommand]) {
            //                self.DFUTransImageCharacteristic = characteristic;
            //                if ( _delegate && [_delegate respondsToSelector:@selector(startDFUProcess)]) {
            //                    [_delegate startDFUProcess];
            //                }else if( _delegate && [_delegate respondsToSelector:@selector(hasInBootload:)]){
            //                    self.DFUCharacteristic = characteristic;
            //                    [_delegate hasInBootload:peripheral];
            //                }else{
            //                    [self.centralManager cancelPeripheralConnection:_connectedPeripheral];
            //                }
            //            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    //[peripheral readValueForCharacteristic:characteristic];//读取所有的特征值
}
#pragma mark 接收特征的数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) return;
    
    NSString *uuid = characteristic.UUID.UUIDString;
    NSLog(@"读取所有特征值的时候蓝牙UUID的值：%@ %d",uuid, peripheral.isNewDevice);
    if (!peripheral.isNewDevice)
    {
        NSLog(@"zhu --晾衣机是新的设备");
        if ([uuid isEqualToString:bleAndWiFiFunctionSetUUID]){
            NSString *FunctionSetKey = [NSString stringWithFormat:@"0x%@",[KDSBleAssistant convertDataToHexStr:characteristic.value]];
            NSData *functionSetData = characteristic.value;
            u_int8_t tt;
            // NSData转int
            [functionSetData getBytes:&tt length:sizeof(tt)];
            peripheral.functionSet = [NSString stringWithFormat:@"%d",tt];
            NSLog(@"--{Kaadas}---Wi-Fi锁功能集：%@",FunctionSetKey);
            
        }
        const unsigned char *bytes = (const unsigned char *)characteristic.value.bytes;
        unsigned char cmd = bytes[3];
        unsigned char tsn = bytes[1];
        unsigned char control = bytes[0];
        unsigned char checkNum = bytes[4];//校验的剩余次数(如果是92命令则是离线密码因子总长度)
        unsigned char psd_index = bytes[5];//Wi-Fi锁密码因子是分包发的（第六个字节表示是第几包，第五字节表示数据data总长度）
        NSLog(@"收到Wi-Fi锁蓝牙模块发来的数据的cmd：%d---value：%d第几包数据%d此时的tsn：%d当前完整数据：%@",(int)cmd,(int)checkNum,(int)psd_index,(int)tsn,characteristic.value);
        if (cmd == KDSReportResponseRemainingTimes || cmd == KDSBleAndWiFiCRCCheck
            || cmd == KDSBleTunnelOrderGetDisNetworkStatus || cmd == KDSBleTunnelOrderSendCipherFactor
            || cmd == KDSBleTunnelOrderSendPwd || cmd == KDSBleTunnelOrderSendSSID || cmd == KDSReportResponseRemainingTimes97) {
            switch (cmd) {
                case KDSReportResponseRemainingTimes:
                    self.checkNum = (int)checkNum;
                    NSLog(@"门锁配网验证管理员密码错误次数：%d",self.checkNum);
                    break;
                case KDSBleTunnelOrderSendCipherFactor:
                {
                    NSData *dat;
                    int pws_len = (int)checkNum;
                    if ((int)psd_index == (int)pws_len/14) {
                        dat= [characteristic.value subdataWithRange:NSMakeRange(6, pws_len%14)];
                        [self.bleWiFiCRCData appendData:dat];
                        NSLog(@"接受到的Wi-Fi锁的CRC数据1111：%@",characteristic.value);
                        if ([self.delegate respondsToSelector:@selector(replyBleAndWiFiACKWithValue:Cmd:tsn:)]) {
                            [self.delegate replyBleAndWiFiACKWithValue:(int)checkNum Cmd:cmd tsn:(int)tsn];
                        }
                        return;
                    }else{
                        dat= [characteristic.value subdataWithRange:NSMakeRange(6, 14)];
                        [self.bleWiFiCRCData appendData:dat];
                        NSLog(@"接受到的Wi-Fi锁的CRC数据：%@",characteristic.value);
                    }
                }
                    break;
                case KDSBleAndWiFiCRCCheck:
                case KDSBleTunnelOrderSendSSID:
                case KDSBleTunnelOrderSendPwd:
                case KDSBleTunnelOrderGetDisNetworkStatus:
                case KDSReportResponseRemainingTimes97:
                {
                    //下发秘钥因子校验结果0成功1失败
                    if ([self.delegate respondsToSelector:@selector(replyBleAndWiFiACKWithValue:Cmd:tsn:)]) {
                        if (cmd == KDSBleTunnelOrderGetDisNetworkStatus) {
                            if (self.bleAndWiFiLockTsn != (int)tsn) {
                                self.bleAndWiFiLockTsn = (int)tsn;
                                // 监听蓝牙数据的返回
                                NSLog(@"zhu=KDSBleTunnelOrderGetDisNetworkStatus=晾衣机监听数据返回--下发秘钥因子校验结果--");
                                [self.delegate replyBleAndWiFiACKWithValue:(int)checkNum Cmd:cmd tsn:(int)tsn];
                            }
                        }else if (cmd == KDSReportResponseRemainingTimes97)
                        {
                            self.bleAndWiFiLockTsn = (int)tsn;
                            //监听蓝牙数据的返回
                            NSLog(@"zhu=KDSReportResponseRemainingTimes97=晾衣机监听数据返回--下发秘钥因子校验结果--");
                            [self.delegate replyBleAndWiFiACKWithValue:checkNum Cmd:cmd tsn:(int)tsn];
                        }else{
                            self.bleAndWiFiLockTsn = (int)tsn;
                            //监听蓝牙数据的返回
                            NSLog(@"zhu=else=晾衣机监听数据返回--下发秘钥因子校验结果--");
                            [self.delegate replyBleAndWiFiACKWithValue:(int)checkNum Cmd:cmd tsn:(int)tsn];
                        }
                    }
                    return;
                }
                    break;
                default:
                    break;
            }
            [self sendBleAndWiFiResponseInOrOutNet:(int)control tsn:(int)tsn cmd:cmd value:0];
            return;
        }
        
        [self dealWithReceiveOldBleModelData:characteristic.value];
        return;
    }
    
    
    if ([uuid isEqualToString:batteryDUUID]) {//电量信息
        NSData *batteryData = characteristic.value;
        u_int8_t tt;
        [batteryData getBytes:&tt length:sizeof(tt)];
        int elct = tt;//0-100
        peripheral.power = elct;
        if ([_delegate respondsToSelector:@selector(didReceiveDeviceElctInfo:)]) {
            [_delegate didReceiveDeviceElctInfo:elct];
        }
    }
    else if ([uuid isEqualToString:seriaLNumUUID]) {//SN
        peripheral.serialNumber = characteristic.value.jk_UTF8String;
        if (_delegate && [_delegate respondsToSelector:@selector(didGetDeviceSN:)]) {
            [_delegate didGetDeviceSN:characteristic.value.jk_UTF8String];
        }
    }
    else if ([uuid isEqualToString:systemIDUUID]){//System ID
        //获取systemId
        _systemID = characteristic.value;
        NSString *systemIDStr = [KDSBleAssistant convertDataToHexStr:_systemID];
        if (!systemIDStr || strtol(systemIDStr.UTF8String, NULL, 16) == 0) {
            _systemID = [KDSBleAssistant extractSystemIDFromAdvName:peripheral.advDataLocalName];
        }
        if (peripheral.isNewDevice && [_delegate respondsToSelector:@selector(didGetSystemID:)]) {
            [_delegate didGetSystemID:peripheral];
        }
        
    }
    else if ([uuid isEqualToString:hardwareUUID])
    {
        peripheral.hardwareVer = characteristic.value.jk_UTF8String;
    }
    else if ([uuid isEqualToString:softwareUUID]){//softwareUUID
        //获取softwareUUID
        NSData *softwareData = characteristic.value;
        peripheral.softwareVer = softwareData.jk_UTF8String;
        if (peripheral.isNewDevice && _delegate && [_delegate respondsToSelector:@selector(didGetSoftwareWithPeripheral: softwareData:)]) {
            [_delegate didGetSoftwareWithPeripheral:peripheral softwareData:softwareData.jk_UTF8String];
        }
    }
    else if ([uuid isEqualToString:firmwareUUID])
    {
        //这种泻法会导致整个NSString产生异常，length不能正常计算
        //        NSString *model = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSString *model = [[NSString alloc] initWithCString:characteristic.value.bytes encoding:NSUTF8StringEncoding];
        
        self.connectedPeripheral.lockModelType = model;
        if ([self.delegate respondsToSelector:@selector(peripheral:didUpdateValueForCharacteristicOfLockModel:)])
        {
            [self.delegate peripheral:peripheral didUpdateValueForCharacteristicOfLockModel:model];
        }
    }
    else if ([uuid isEqualToString:modelNumUUID])
    {
        self.connectedPeripheral.lockModelNumber = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    }
    else if ([uuid isEqualToString:bleToAppDUUID]){//模块向App发送数据通道
        if (characteristic.value.length == 16) {
            NSData *pwd1Data = [characteristic.value subdataWithRange:NSMakeRange(0, 12)];
            NSData *pwd = [KDSBleAssistant convertHexStrToData:self.pwd1];
            if ([pwd1Data.description isEqualToString: pwd.description]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:KDSLockAuthFailedNotification object:nil userInfo:nil];
            }
            return;
        }
        if (characteristic.value.length < 20) {return;/**数据丢包了 */ }
        //新设备数据的处理
        [self dealWithNewDeviceReceiveData:characteristic.value];
    }else if ([uuid isEqualToString:wifiLockNotifyUUID]){
        
    }else if ([uuid isEqualToString:bleAndWiFiFFC1UUID]){
        
    }
    else if ([uuid isEqualToString:kLockStateUUID])//锁状态
    {
        peripheral.isAutoMode = ((*(int*)(characteristic.value.bytes)) >> 7) & 0x01;
        //        self.onAdminMode = ((*(int*)(characteristic.value.bytes)) >> 10) & 0x01;
        if ([self.delegate respondsToSelector:@selector(peripheral:didUpdateValueForCharacteristicOfLockState:)])
        {
            [self.delegate peripheral:peripheral didUpdateValueForCharacteristicOfLockState:characteristic.value];
        }
    }
    else if ([uuid isEqualToString:kLockVolumeUUID])//音量
    {
        peripheral.volume = *(char*)(characteristic.value.bytes);
    }
    else if ([uuid isEqualToString:kLockLanguageUUID])//语言
    {
        peripheral.language = @((char*)(characteristic.value.bytes));
    }
    else if ([uuid isEqualToString:kFFE1])//功能集
    {
        /*
         //测试转换
         // int转NSData
         int a = 32;
         u_int8_t ttt;
         NSData *data = [NSData dataWithBytes:&a length:sizeof(ttt)];
         NSLog(@"--{Kaadas}--功能集==%@",data);
         */
        //功能集
        NSLog(@"--{Kaadas}--功能集=锁上=%@",characteristic.value);
        NSString *FunctionSetKey = [NSString stringWithFormat:@"0x%@",[KDSBleAssistant convertDataToHexStr:characteristic.value]];
        if (KDSLockFunctionSet[FunctionSetKey]) {
            //存在功能集
            NSData *functionSetData = characteristic.value;
            u_int8_t tt;
            // NSData转int
            [functionSetData getBytes:&tt length:sizeof(tt)];
            peripheral.functionSet = [NSString stringWithFormat:@"%d",tt];
            NSLog(@"--{Kaadas}--功能集=转化=%@",peripheral.functionSet);
            if ([_delegate respondsToSelector:@selector(didGetFunctionSet:)]) {
                [_delegate didGetFunctionSet:peripheral];
            }
        }else {
            NSLog(@"--{Kaadas}--功能集=不存在=%@",FunctionSetKey);
            //不存在功能集
            if ([_delegate respondsToSelector:@selector(noFunctionSet:)]) {
                [_delegate noFunctionSet:FunctionSetKey];
            }
        }
        
    }
    else if ([uuid isEqualToString:KDSRYGWBle2WiFi])//功能集
    {
        NSLog(@"--{Kaadas}--KDSRYGWBle2WiFi=%@",characteristic.value);
        
    }
}
///发送消息的回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        KDSLog(@"向蓝牙设备:%@ 发送数据:%@ 失败:%@",peripheral.advDataLocalName,characteristic.value,error);
    }else{
        //        KDSLog(@"向蓝牙设备:%@发送数据成功 value:(%@)date :%@",peripheral,characteristic.value,[self getcurretenDate]);
    }
}

#pragma mark - 发送心跳包
- (void)createHeartbeatTimer{
    if (self.heartbeatTimer==nil) {
        //重复每3秒发送一次心跳包
        __weak typeof(self) weakSelf = self;
        NSTimer *timer = [NSTimer kdsScheduledTimerWithTimeInterval:3 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [weakSelf sendHeartbeatdata];
        }];
        self.heartbeatTimer = timer;
        [timer fire];
    }
}

- (void)sendHeartbeatdata{
    
    if (!self.connectedPeripheral.lockModelType)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.connectedPeripheral readValueForCharacteristic:self.firmwareCharacteristic];
        });
    }
    if (!self.connectedPeripheral.lockModelNumber)
    {
        int interval = self.connectedPeripheral.lockModelType ? 2 : 4;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.connectedPeripheral readValueForCharacteristic:self.modelNumCharacteristic];
        });
    }
    
    BOOL needRetrieveUser = -1<self.retrievingUserId && self.retrievingUserId<self.connectedPeripheral.maxUsers;
    BOOL needRetrieveSchedule = -1<self.retrievingScheduleId && self.retrievingScheduleId<5;
    if ((needRetrieveUser || needRetrieveSchedule) && self.pwd3)
    {
        if (needRetrieveUser)
        {
            [self retrieveUsers];
        }
        if (needRetrieveSchedule)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((needRetrieveUser ? 2 : 0) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self retrieveSchedules];
            });
        }
        return;
    }
    
    if (self.lockStateCharacteristic)
    {
        [self.connectedPeripheral readValueForCharacteristic:self.lockStateCharacteristic];
    }
    self.heartbeatTsn ++;
    Byte bytePayload[16] = {0xFF, 0};
    NSData *payloadData = [[NSData alloc] initWithBytes:bytePayload length:sizeof(bytePayload)];
    Byte byteHeader[] = {0x00,self.heartbeatTsn,0xff,0xAA};
    NSData *headerData = [[NSData alloc] initWithBytes:byteHeader length:sizeof(byteHeader)];
    NSMutableData *senderData = [NSMutableData data];
    [senderData appendData:headerData];
    [senderData appendData:payloadData];
    if (self.writeCharacteristic && self.connectedPeripheral ) {
        //        KDSLog(@"%ld %@发送了心跳包:%@ ",self.heartbeatTsn,[self getcurretenDate],senderData);
        [self.connectedPeripheral writeValue:senderData forCharacteristic:self.writeCharacteristic type:0];
    }
}
- (void)pauseTimer{
    self.heartbeatTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:3];
}
///处理模块发来的数据
- (void)dealWithNewDeviceReceiveData:(NSData *)data{
    
    KDSLog(@"--{Kaadas}--蓝牙--处理模块发来的数据==%@",data)
    const unsigned char* bytes = (const unsigned char*)data.bytes;
    u_int8_t control = bytes[0];
    u_int8_t check1 = bytes[2];
    NSData *decryptData = data;
    if (control != 0) {//心跳包不加密
        //解密数据
        decryptData =  [self getAes256_decryptDataWithOriginData:data];
    }
    u_int8_t check2 = [KDSBleAssistant sumOfDataThroughoutBytes:[decryptData subdataWithRange:NSMakeRange(4, 16)]];
    if (check1 == check2) {
        //                KDSLog(@"校验正确=%@",decryptData)
        [self dealCheckSuccessWithDecryptData:decryptData];
    }else{
        KDSLog(@"--{Kaadas}--校验出错")
    }
}
///处理校验正确之后的数据
- (void)dealCheckSuccessWithDecryptData:(NSData *)decryptData{
    
    KDSLog(@"处理校验正确之后的数据------%@",decryptData);
    const unsigned char *bytes = (const unsigned char *)decryptData.bytes;
    unsigned char transferSerialNumber = bytes[1];
    unsigned char cmd = bytes[3];
    unsigned char status = bytes[4];
    if (cmd==0 && transferSerialNumber<50) return;//心跳包确认帧。
    if (cmd!=0 && !(cmd==KDSBleTunnelOrderEncrypt && status==1 && !self.isBinding)) {
        //只有收到pwd2和退网指令的时候 或根据需要是否发送确认帧 或其他cmd非0（对模块执行了任何操作)都要发
        [self sendConfirmDataToBleDevice:(int)transferSerialNumber];
    }
    
    NSString *receipt = @(transferSerialNumber).stringValue;
    //如果是app主动发送命令，那么队列里会有记录，根据tsn和命令值执行相应的命令就行。
    KDSBleTunnelTask *task = self.tasksMDict[receipt];
    if (task && (cmd == 0 || cmd == task.order
                 || cmd == KDSBleTunnelOrderSetWeekly
                 || cmd == KDSBleTunnelOrderGetWeekly
                 || cmd == KDSBleTunnelOrderDeleteWeekly
                 || cmd == KDSBleTunnelOrderSetYMD
                 || cmd == KDSBleTunnelOrderGetYMD
                 || cmd == KDSBleTunnelOrderDeleteYMD))
    {
        NSLog(@"--{Kaadas}--执行任务返回的data=%@",decryptData);
        [self handleTask:task withData:decryptData];
        return;
    }
    //执行app主动发送命令队列中不存在的上报命令
    KDSBleTunnelOrder order = (KDSBleTunnelOrder)cmd;
    switch (order) {
        case KDSBleTunnelOrderEncrypt:
            if (status == 1 && self.isBinding)//收到锁发送过来的入网(绑定)指令，可以在返回数据中提取pwd2
            {
                self.pwd2 = [decryptData subdataWithRange:NSMakeRange(5, 4)];
                NSLog(@"~~~~~收到入网命令self.pwd2=%@",self.pwd2);
                [self sendResponseInOrOutNet:(int)transferSerialNumber];
                if ([_delegate respondsToSelector:@selector(didReceiveInNetOrOutNetCommand:)])
                {
                    [_delegate didReceiveInNetOrOutNetCommand:YES];
                }
                sleep(0.2);
                [self authenticationWithPwd1:self.pwd1 pwd2:self.pwd2 completion:nil];
            }
            else if (status == 2)//收到pwd3，绑定成功。
            {
                self.pwd3 = [decryptData subdataWithRange:NSMakeRange(5, 4)];
                
                NSLog(@"~~~~~收到self.pwd3，绑定成功=%@",self.pwd3);
                self.isBinding = YES;
                [self updateLockClock:nil];
            }
            else if (status == 3)//收到退网(重置)指令。
            {
                NSLog(@"~~~~~收到退网命令");
                [self sendResponseInOrOutNet:(int)transferSerialNumber];
                if ([_delegate respondsToSelector:@selector(didReceiveInNetOrOutNetCommand:)]) {
                    [_delegate didReceiveInNetOrOutNetCommand:NO];
                }
            }
            break;
            
        case KDSBleTunnelOrderLockOperate:
            
            if (status == 1 && bytes[5] != 9) {//9是模式设置，此种情况下不可能有开锁和关锁。
                
                if (bytes[6] == 1 || bytes[6] == 0x0d) {//关锁
                    [[NSNotificationCenter defaultCenter] postNotificationName:KDSLockDidCloseNotification object:nil userInfo:@{@"peripheral" : self.connectedPeripheral}];
                }else if (bytes[6] == 2 || bytes[6] == 0x0e){//开锁
                    //2.6版本 开锁成功之后 这个方法会调用两次
                    [[NSNotificationCenter defaultCenter] postNotificationName:KDSLockDidOpenNotification object:nil userInfo:@{@"peripheral" : self.connectedPeripheral}];
                }
            }
            else
            {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:KDSLockDidReportNotification object:nil userInfo:@{@"peripheral":self.connectedPeripheral, @"data":decryptData}];
                if (bytes[5] == 9)
                {
                    //                    self.onAdminMode = (bytes[6] >> 3) & 0x1;
                    self.connectedPeripheral.isAutoMode = (bytes[6] >> 4) & 0x1;
                }
            }
            break;
            
        case KDSBleTunnelOrderZero:
            if (status == (NSInteger)KDSBleErrorNotAuth)
            {
                KDSLog(@"没有鉴权");
                self.pwd3 = nil;
                [[NSNotificationCenter defaultCenter] postNotificationName:KDSLockAuthFailedNotification object:nil userInfo:@{@"peripheral":self.connectedPeripheral, @"code":@(status)}];
            }
            break;
            
        case KDSBleTunnelOrderAlarm:
            [[NSNotificationCenter defaultCenter] postNotificationName:KDSLockDidAlarmNotification object:nil userInfo:@{@"peripheral":self.connectedPeripheral, @"data":decryptData}];
            break;
            
        default:
            break;
    }
}

/**
 *@abstract 当主动发送的任务收到回复时，根据返回的数据处理任务。
 *@param task app向蓝牙发送的任务。
 *@param data 蓝牙返回的解密数据。
 */
- (void)handleTask:(KDSBleTunnelTask *)task withData:(NSData *)data
{
    task.taskResendBlock = nil;
    const unsigned char *bytes = (const unsigned char *)data.bytes;
    unsigned char cmd = bytes[3];
    int checksum = bytes[2];
    if (cmd == 0)
    {
        //cmd=0时，是查询任务确认帧(校验码为0)不处理，或者失败了(校验码不为0)。
        if ((checksum == 0 && task.isQueryTask) || bytes[4] == (int)KDSBleErrorPending) return;
        void (^block)(NSData *data) = task.bleReplyBlock;
        self.tasksMDict[task.receipt] = nil;
        !block ?: block(data);
        return;
    }
    switch (task.order) {
        case KDSBleTunnelOrderGetUnlockRecord://查询记录有多次返回，不能直接执行block。
        case KDSBleTunnelOrderGetAlarmRecord:
            [self dealRecordData:data task:task];
            break;
            
        case KDSBleTunnelOrderGetSN:
        {
            NSMutableData *container = task.attrs[@"container"];
            if (bytes[5] == 0)
            {
                if (!container.length)
                {
                    [container appendData:data];
                }
                else//如果先收到第二段数据
                {
                    NSData *existed = [NSData dataWithData:container];
                    [container replaceBytesInRange:NSMakeRange(0, existed.length) withBytes:data.bytes length:data.length];
                    [container appendData:existed];
                }
            }
            else
            {
                [container appendData:[data subdataWithRange:NSMakeRange(6, 3)]];
            }
            if (container.length > 20)
            {
                void (^block)(NSData *data) = task.bleReplyBlock;
                self.tasksMDict[task.receipt] = nil;
                !block ?: block(container.copy);
            }
        }
            break;
            
        case KDSBleTunnelOrderGetOpRec:
            [self dealOpRecData:data task:task];
            break;
            
        default:
        {
            void (^block)(NSData *data) = task.bleReplyBlock;
            self.tasksMDict[task.receipt] = nil;
            !block ?: block(data);
        }
            break;
    }
}

/**
 *@abstract 从蓝牙返回的开锁/报警记录数据中提取开锁/报警记录。
 *@param data 蓝牙返回的开锁/报警记录数据。
 *@param task 待处理的任务，由于发送任务时设置了任务的attrs属性，因此这里需要提取isAll、group、index和container属性值。
 */
-(void)dealRecordData:(NSData *)data task:(KDSBleTunnelTask *)task
{
    const unsigned char* bytes = data.bytes;
    int total = 0, current = 0;
    id obj = nil;
    NSLog(@"~~~~%@",data);
    unsigned seconds = *((unsigned *)(bytes + 10));//系统刚好是小端，所以这里的值不用再转换了。
    NSDate *date = seconds==0xffffffff ? nil : [NSDate dateWithTimeIntervalSince1970:seconds - [[NSTimeZone localTimeZone] secondsFromGMT] + FixedTime];
    self.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    if (task.order == KDSBleTunnelOrderGetUnlockRecord)
    {
        if (bytes[8] != 2) return;//不是开锁
        KDSBleUnlockRecord *record = [[KDSBleUnlockRecord alloc] initWithData:data];
        if (date) record.date = [self.dateFormatter stringFromDate:date];
        total = record.total;
        current = record.current;
        obj = record;
    }
    else if (task.order == KDSBleTunnelOrderGetAlarmRecord)
    {
        KDSBleAlarmRecord *record = [[KDSBleAlarmRecord alloc] initWithData:data];
        if (date) record.date = [self.dateFormatter stringFromDate:date];
        total = record.total;
        current = record.current;
        obj = record;
    }
    else
    {
        return;
    }
    
    NSMutableDictionary *attrs = (NSMutableDictionary *)task.attrs;
    BOOL isAll = [attrs[@"isAll"] boolValue];
    int group = [attrs[@"group"] intValue];
    NSMutableArray *container = attrs[@"container"];
    if (total != 0 && ![container containsObject:obj])
    {
        [container addObject:obj];
    }
    if (isAll || group>=0)
    {
        NSUInteger count = container.count;
        if (total == 0 && count == 0)
        {
            void (^block)(NSData *data) = task.bleReplyBlock;
            self.tasksMDict[task.receipt] = nil;
            //当没有操作记录执行回调时，可判断为数据收发已经完毕。如果首条获取到的数据就有问题(不该为0却为0)，那么这里逻辑就不对。
            !block ?: block((NSData *)container);
        }
        else
        {
            if (task.timeout < 300) task.timeout = 300;//对于获取多条记录来说，默认的20秒可能有点少。
            task.dataInterval = 1.8;
            //判断数据收发是否已完成
            BOOL finished = (isAll && count==total) || (!isAll && (count==20 || count==total-group*20));
            if (!finished)
            {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
                !task.bleReplyBlock ?: task.bleReplyBlock(container);
                NSLog(@"~~~9999%@",container);
#pragma clang disgnostic pop
            }
            else
            {
                task.dataInterval = 0.1;
            }
        }
    }
    else//获取单条记录
    {
        void (^block)(NSData *data) = task.bleReplyBlock;
        self.tasksMDict[task.receipt] = nil;
        !block ?: block((NSData *)container);
    }
}

/**
 *@abstract 从蓝牙返回的操作记录数据中提取操作记录。数据接收完毕或每接收10条数据执行一次任务的回调。
 *@param data 蓝牙返回的操作记录数据。
 *@param task 待处理的任务，由于发送任务时设置了任务的attrs属性，因此这里需要提取container属性值。
 */
-(void)dealOpRecData:(NSData *)data task:(KDSBleTunnelTask *)task
{
    const unsigned char* bytes = data.bytes;
    NSLog(@"~~~~~%@", data);
    KDSBleOpRec *rec = [[KDSBleOpRec alloc] initWithData:data];
    unsigned seconds = *((unsigned *)(bytes + 13));//系统刚好是小端，所以这里的值不用再转换了。
    if (seconds != 0xffffffff)
    {
        seconds -= [[NSTimeZone localTimeZone] secondsFromGMT];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds + FixedTime];
        self.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        rec.date = [self.dateFormatter stringFromDate:date];
    }
    NSMutableArray *container = task.attrs[@"container"];
    if (rec.niketotal && ![container containsObject:rec])
    {
        //启动数据超时定时器后，停止任务超时定时器，等待数据接收间隔超时后结束任务。
        task.dataInterval = 1.8;
        if (task.timeout < INT_MAX)
        {
            task.timeout = INT_MAX;
        }
        [container addObject:rec];
        NSUInteger count = container.count;
        if (count % 10 == 0)
        {
            !task.bleReplyBlock ?: task.bleReplyBlock((NSData *)container);
        }
        int fidx = [task.attrs[@"fromIndex"] intValue];
        int tidx = [task.attrs[@"toIndex"] intValue];
        if (count == tidx-fidx+1 || count == rec.niketotal || count == (rec.niketotal-fidx+1))
        {
            //当接收到的数据满足结束判定条件时，0.1秒后执行数据间隙超时定时器，回调判断container有数据，也可视为数据收发已经完毕。
            task.dataInterval = 0.1;
        }
    }
    else
    {
        if (container.count == 0)
        {
            void (^block)(NSData *data) = task.bleReplyBlock;
            self.tasksMDict[task.receipt] = nil;
            //当没有操作记录执行回调时，可判断为数据收发已经完毕。如果首条获取到的数据就有问题(不该为0却为0)，那么这里逻辑就不对。
            !block ?: block((NSData *)container);
        }
    }
    
}

#pragma mark - 新模块发送确认帧
- (void)sendConfirmDataToBleDevice:(NSInteger)tsn{
    if (tsn != 0) {
        //        [self pauseTimer];
        Byte conformByte[] = {0x00,tsn,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,};
        NSData *conformData = [[NSData alloc] initWithBytes:conformByte length:sizeof(conformByte)];
        if (self.writeCharacteristic && self.connectedPeripheral ) {///设备已经连接且要写入特征
            //            KDSLog(@"发送了确认帧:%@ %@",conformData,getcurretenDate);
            [self.connectedPeripheral writeValue:conformData forCharacteristic:self.writeCharacteristic type:0];
        }
        return;
    }
    [self sendConfirmDataToOldBleDevice];
}

#pragma mark - 发送收到 入网/退网 确认帧
- (void)sendResponseInOrOutNet:(int)tsn{
    if (_connectedPeripheral.isNewDevice) {
        [self sendConfirmDataToBleDevice:tsn];
        return;
    }
    [self sendReveiveInNetOrOutNetDatToOldBleDevice];
}
#pragma mark - 发送 入网/退网成功 确认帧
- (void)sendInOrOutNetSuccessFrame{
    if (!self.connectedPeripheral.isNewDevice) {
        //新的模块不需要发送 入退网成功的确认帧 只需要在收到pdw2的时候发送即可
        //旧的模块是与App在服务器中绑定成功之后发送
        [self oldBleModelSendInNetSuccessDada];
    }
}

#pragma mark - 获取解密数据
///解密数据，绑定/重置时只能使用密码1+4字节都为0的NSData解密(即密码2必须为nil)；鉴权时只能使用密码1+密码2解密(即密码3必须为nil)；鉴权成功获取密码3后只能使用密码1+密码3解密；否则解密的数据都不正确。
- (NSData *)getAes256_decryptDataWithOriginData:(NSData *)data{
    NSMutableData *keyData = [NSMutableData data];
    NSData *key1Data = [KDSBleAssistant convertHexStrToData:_pwd1];
    [keyData appendData:key1Data];
    if (self.pwd2 == nil) {//解密pwd2
        Byte behindByte[] = {0x00,0x00,0x00,0x00};
        NSData *behindData= [NSData dataWithBytes:behindByte length:sizeof(behindByte)];
        [keyData appendData:behindData];
        KDSLog(@"keyData1:%@",keyData);
        
    }else if(self.pwd2 && self.pwd3 == nil){//解密pwd3
        [keyData appendData:self.pwd2];
        KDSLog(@"keyData2:%@",keyData);
    }
    else if(self.pwd2 && self.pwd3){//建立通道以后 解密数据
        [keyData appendData:self.pwd3];
        //        KDSLog(@"keyData3:%@",keyData);
    }
    //    KDSLog(@"收到的原始数据:%@",data);
    NSData *resultData = [[data subdataWithRange:NSMakeRange(4, 16)] aes256_decryptData:keyData];
    NSMutableData *decryptData = [NSMutableData data];
    [decryptData appendData:[data subdataWithRange:NSMakeRange(0, 4)]];
    [decryptData appendData:resultData];
    //    KDSLog(@"--{Kaadas}--蓝牙--收到的解密后数据%@",decryptData);
    return decryptData.copy;
}
#pragma mark - 获取设备信息
- (void)getDeviceInfoWithDevType:(DeviceInfo)type{
    if (_connectedPeripheral == nil) return;
    
    switch (type) {
        case DeviceInfoSystemID:
            if(_systemIDCharacteristic)[_connectedPeripheral readValueForCharacteristic:_systemIDCharacteristic];
            break;
        case DeviceInfoModelNum:
            if(_modelNumCharacteristic)[_connectedPeripheral readValueForCharacteristic:_modelNumCharacteristic];
            break;
        case DeviceInfoSerialNum:
            if(_seriaNumCharacteristic)[_connectedPeripheral readValueForCharacteristic:_seriaNumCharacteristic];
            break;
        case DeviceInfoFirmWare:
            if(_firmwareCharacteristic)[_connectedPeripheral readValueForCharacteristic:_firmwareCharacteristic];
            break;
        case DeviceInfoHardware:
            if(_hardwareCharacteristic)[_connectedPeripheral readValueForCharacteristic:_hardwareCharacteristic];
            break;
        case DeviceInfoSoftware:
            if(_softwareCharacteristic)[_connectedPeripheral readValueForCharacteristic:_softwareCharacteristic];
            break;
        case DeviceInfoMfrName:
            if(_mfrNameCharacteristic)[_connectedPeripheral readValueForCharacteristic:_mfrNameCharacteristic];
            break;
        case DeviceInfoBattery:
            if(_batteryCharacteristic)[_connectedPeripheral readValueForCharacteristic:_batteryCharacteristic];
            break;
        default:
            break;
    }
}
#pragma mark - 获取电量
- (void)getDeviceElectric{
    if (_writeCharacteristic == nil) return;
    KDSLog(@"connectedPeripheral.name:%@",_connectedPeripheral.name);
    if (self.connectedPeripheral.isNewDevice) {
        KDSLog(@"新设备获取电量")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getDeviceInfoWithDevType:DeviceInfoBattery];
        });
    }else{
        [self oldBleModelbeginGetElectric];
    }
}

-(void)dealloc{
    [self.heartbeatTimer invalidate];
    self.heartbeatTimer=nil;
    [self endConnectPeripheral:self.connectedPeripheral];
}

#pragma mark - 内部使用的蓝牙命令相关方法。所有的递归方法使用上都有缺陷，只是为了方便外部使用。
static void onAdminMode(void(^*block)(void))
{
    (*block)();
}

/**
 *@abstract 根据命令类型创建一个任务。任务成功创建后，会自动添加到当前队列中。
 *@param orderType 命令类型，参考KDSBleTunnelOrder枚举。
 *@param payload 蓝牙协议对应命令所需的载荷数据，16字节。
 *@note 如果新创建的命令的tsn和当前队列中的命令的tsn有重复，则会删除上一个重复tsn的命令，然后把当前命令加入队列中。即旧命令会失效。
 *@return 命令对象。如果连续的tsn包含相同的命令则会返回空，否则返回的命令已设置好tsn和order属性。如果有正在进行的鉴权命令，也返回空，即必须等待鉴权命令完成才能进行其它操作。
 */
- (nullable KDSBleTunnelTask *)createTask:(KDSBleTunnelOrder)orderType withPayload:(const unsigned char[])payload
{
    //不考虑管理员模式
    //    if (self.onAdminMode)
    //    {
    //        void(^block)(void) __attribute__((cleanup(onAdminMode), unused)) = self.onAdminModeBlock ?: (^(){});
    //    }
    KDSBleTunnelTask *task = self.tasksMDict[@(self.tsn).stringValue];
    if (self.tasksMDict.count > 4) {return nil; }
    if (task && task.order == orderType) { return nil; }
    for (KDSBleTunnelTask *task in self.tasksMDict.allValues)
    {
        if (task.order == KDSBleTunnelOrderAuth)
        {
            return nil;
        }
    }
    int sum = [KDSBleAssistant sumOfDataThroughoutBytes:[[NSData alloc] initWithBytes:payload length:16]];
    self.tsn++;
    unsigned char* bytes = (unsigned char*)malloc(20);
    bytes[0] = 1; bytes[1] = self.tsn; bytes[2] = sum; bytes[3] = orderType;
    memcpy(bytes + 4, payload, 16);
    task = [[KDSBleTunnelTask alloc] initWithData:[[NSData alloc] initWithBytesNoCopy:bytes length:20]];
    self.tasksMDict[@(task.tsn).stringValue] = task;
    return task;
}

/**
 *@abstract 执行任务。将创建并配置好的任务的数据发送到蓝牙。
 *@param task 创建并配置好的任务。
 */
- (void)performTask:(KDSBleTunnelTask *)task
{
    //发送新命令的时候，如果已在队列中的命令被标记了重发就取消重发，免得锁蓝牙处理混乱。
    for (KDSBleTunnelTask *task in self.tasksMDict.allValues)
    {
        task.taskResendBlock = nil;
    }
    NSMutableData *key = [NSMutableData dataWithData:[KDSBleAssistant convertHexStrToData:self.pwd1]];
    if (self.pwd3)//鉴权后+密码3加密
    {
        [key appendData:self.pwd3];
    }
    else if (self.pwd2)//鉴权时+密码2加密
    {
        [key appendData:self.pwd2];
    }
    else//这个应该只有入网命令使用，按照解密逻辑，后接4位0加密
    {
        [key appendBytes:(char[]){0, 0, 0, 0} length:4];
    }
    NSData *encryptData = [[task.data subdataWithRange:NSMakeRange(4, 16)] aes256_encryptData:key];
    NSLog(@"--{Kaadas}--encryptData=key=%@",key);
    NSLog(@"--{Kaadas}--encryptData====%@",encryptData);
    
    [key setData:[task.data subdataWithRange:NSMakeRange(0, 4)]];
    [key appendData:encryptData];
    if (self.connectedPeripheral && self.writeCharacteristic)
    {
        [self pauseTimer];
        NSLog(@"--{Kaadas}--执行任务data=%@",task.data);
        [self.connectedPeripheral writeValue:key forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
    __weak typeof(self) weakSelf = self;
    task.taskResendBlock = ^{
        if (weakSelf.connectedPeripheral && weakSelf.writeCharacteristic)
        {
            NSLog(@"发送ssid数据到模块地址：%@-----值：%@",weakSelf.connectedPeripheral,key);
            [weakSelf pauseTimer];
            [weakSelf.connectedPeripheral writeValue:key forCharacteristic:weakSelf.writeCharacteristic type:0];
        }
    };
}

/**
 *@abstract 发送蓝牙命令。此方法根据传入的参数封装了一个命令对象，设置了bleReplyBlock属性。
 *@note 递归执行此方法时，需注意命令重复和管理模式的错误。当tag非0时，请注意数据成功收发完毕后从队列中移除对应的任务。
 *@param order 要发送的命令。
 *@param payload 命令的有效数据，请确保是合法的16字节且填充0的数据。
 *@param tag 这个标记是用来标记执行completion回调时是否将队列中的任务删除的，0删除，非0不删除。如果蓝牙命令有多次回复，则不应删除，否则无法处理第一条后的数据(由于在队列中找不到任务，导致数据被丢弃)。但是，如果超时，即使tag非0，任务也会从队列中移除。
 *@param completion 超时或者收到蓝牙回复后执行的回调，error参考KDSBleError(如果只是简单的应答帧才使用此参数，否则不应该使用此参数，具体需参考蓝牙协议每个命令的数据格式)，data为蓝牙返回的数据，如果超时则为空。
 *@return 返回内部创建的命令，如果命令重复或正在鉴权等异常情况，则返回空。
 */
- (nullable KDSBleTunnelTask *)sendOrder:(KDSBleTunnelOrder)order payload:(const unsigned char [])payload tag:(int)tag completion:(nullable void(^)(KDSBleError error, NSData * __nullable data))completion
{
    if (!self.connectedPeripheral)
    {
        !completion ?: completion(KDSBleErrorFailure, nil);
        return nil;
    }
    //管理员模式下的指令直接返回执行失败，不考虑管理员模式的话注释掉就可以正常下发指令
    //    if (self.onAdminMode && order != KDSBleTunnelOrderAuth)//??...其它命令
    //    {
    //        !completion ?: completion(KDSBleErrorAdminMode, nil);
    //        return nil;
    //    }
    KDSBleTunnelTask *task = [self createTask:order withPayload:payload];
    if (!task)
    {
        !completion ?: completion(KDSBleErrorDuplOrAuthenticating, nil);
        return nil;
    }
    NSString *receipt = task.receipt;
    __weak typeof(self) weakSelf = self;
    NSLog(@"bleReplyBlock");
    task.bleReplyBlock = ^(NSData * _Nullable data) {
        NSLog(@"bleReplyBlock%@",data);
        if (tag == 0 || !data) weakSelf.tasksMDict[receipt] = nil;
        if (!completion) return;
        if (!data)
        {
            completion(!weakSelf.pwd3 ? KDSBleErrorDuplOrAuthenticating : KDSBleErrorNoReply, nil);
        }
        else if ([data isKindOfClass:NSData.class])
        {
            const unsigned char *bytes = data.bytes;//bytes[4]是执行结果。
            completion((KDSBleError)bytes[4], data);
        }
        else
        {
            completion(KDSBleErrorSuccess, data);
        }
    };
    [self performTask:task];
    
    return task;
}

/**
 *@abstract 获取锁中保存的开锁、报警记录。该方法不保证能获取完整的记录。旧蓝牙只获取全部记录。
 *@param order 命令，查看开锁记录或者报警记录之一。
 *@param isAll 是否获取全部记录，如是，会忽略group和index参数。
 *@param group 单组记录索引，从0开始，如果超出0~9范围会忽略此参数，否则会忽略index参数。
 *@param index 单条记录索引，从0开始，超出0~199范围会忽略。
 *@param completion 每获取到一条记录就会执行一次回调。如果error成功，records返回记录，否则为nil；如果records不为空且元素个数为0表示锁中没有开锁记录；finished为YES时表示获取操作已结束。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)internalGetRecordWithOrder:(KDSBleTunnelOrder)order isAll:(BOOL)isAll orAtGroup:(int)group orAtIndex:(int)index completion:(nullable void(^)(BOOL finished, KDSBleError error, NSArray<KDSBleRecord *> * __nullable records))completion
{
    __weak typeof(self) weakSelf = self;
    if (!self.connectedPeripheral)
    {
        !completion ?: completion(YES, KDSBleErrorFailure, nil);
        return @"";
    }
    if (_connectedPeripheral.isNewDevice) {//新蓝牙模块
        
        Byte payloadByte[16] = {0};
        if (isAll)
        {
            payloadByte[0] = 1;
            payloadByte[1] = 200;
        }
        else if (0 <= group && group < 10)
        {
            payloadByte[0] = group * 20;
            payloadByte[1] = (group + 1) * 20;
        }
        else if (0 <= index && index < 200)
        {
            payloadByte[0] = payloadByte[1] = index;
        }
        else
        {
            !completion ?: completion(YES, KDSBleErrorFailure, nil);
            return @"0";
        }
        NSMutableArray *container = [NSMutableArray array];//保存记录的数组。
        //这里约定做个特殊的处理，获取完成后，将container传给参数data
        KDSBleTunnelTask *task = [self sendOrder:order payload:payloadByte tag:1 completion:^(KDSBleError error, NSData * _Nullable data) {
            if (![data isKindOfClass:NSArray.class])
            {
                const Byte *bytes = data.bytes;
                KDSBleError err = !weakSelf.pwd3 ? error : (bytes ? (KDSBleError)bytes[4] : KDSBleErrorNoReply);
                err = container.count ? KDSBleErrorSuccess : err;
                NSArray *arr = container.count ? container.copy : nil;
                !completion ?: completion(YES, err, arr);
                return;
            }
            if (((NSArray *)data).count == 0 && container.count == 0)
            {
                !completion ?: completion(YES, KDSBleErrorSuccess, container.copy);
            }
            else
            {
                !completion ?: completion(!isAll && (group<0 || group>9), KDSBleErrorSuccess, container.copy);
            }
        }];
        task.attrs = @{@"isAll":@(isAll), @"group":@(group), @"index":@(index), @"container":container, @"isComplete":@(NO)};
        return task.receipt ?: @"";
    }
    //旧的蓝牙模块，读取的是全部记录。
    if (order != KDSBleTunnelOrderGetUnlockRecord)
    {
        !completion ?: completion(YES, KDSBleErrorUnsupportAttr, nil);
        return @"";
    }
    KDSBleTunnelTask *task = [KDSBleTunnelTask new];
    task.command = KDSBleOldCommandUnlockRecord;
    if (self.tasksMDict[task.receipt] != nil) return task.receipt;
    NSString *receipt = task.receipt;
    task.attrs = @{@"container" : [NSMutableArray array]};
    task.bleReplyBlock = ^(NSData * _Nullable data) {
        weakSelf.tasksMDict[receipt] = nil;
        !completion ?: completion(YES, data ? KDSBleErrorSuccess : KDSBleErrorNoReply, data ? (NSArray *)data : nil);
    };
    self.tasksMDict[task.receipt] = task;
    [self oldBleModelSendGetHistoryRecoryOrder];
    return receipt;
}

///发送命令查询用户类型，有结果返回时通知外界。
- (void)retrieveUsers
{
    if (self.retrievingUserId >= self.connectedPeripheral.maxUsers) return;
    __weak typeof(self) weakSelf = self;
    self.tsn += 1;
    [self getUserTypeWithId:@(self.retrievingUserId).stringValue KeyType:KDSBleKeyTypePIN completion:^(KDSBleError error, KDSBleUserType * _Nullable user) {
        if (error != KDSBleErrorSuccess)
        {
            [weakSelf.retrievedUsersArr addObject:[KDSBleUserType new]];
            return;
        }
        [weakSelf.retrievedUsersArr addObject:user];
        [[NSNotificationCenter defaultCenter] postNotificationName:KDSLockUsersDidUpdateNotification object:nil userInfo:@{@"users" : weakSelf.users}];
    }];
    self.retrievingUserId += 1;
}

///发送命令查询用户计划，有结果返回时通知外界。
- (void)retrieveSchedules
{
    if (self.retrievingScheduleId >= 5) return;
    __weak typeof(self) weakSelf = self;
    self.tsn += 1;
    [self getScheduleWithScheduleId:(int)self.retrievingScheduleId completion:^(KDSBleError error, KDSBleScheduleModel * _Nullable model) {
        if (error != KDSBleErrorSuccess)
        {
            [weakSelf.retrievedSchedulesArr addObject:model];
            [[NSNotificationCenter defaultCenter] postNotificationName:KDSLockSchedulesDidUpdateNotification object:nil userInfo:@{@"schedules" : weakSelf.schedules}];
        }
    }];
    self.retrievingScheduleId++;
}

/**
 *@abstract 递归获取丢失的记录。分组获取，传入的索引大于记录总数会被忽略。由于分组获取数据量不大，因此等到一次数据收发结束再处理。
 *@param indexes 要获取的记录的索引数组。获取单组记录可以传一组索引，获取单条记录传该记录的索引。
 *@param times 递归次数，方法外调用时一般将此值设置为0，失败递归不超过5次。
 *@param order 记录类型，只能是KDSBleTunnelOrderGetUnlockRecord或者KDSBleTunnelOrderGetAlarmRecord。
 *@param container 初始时必须是一个可变数组，用来保存获取到的记录。
 *@param completion 一次数据收发结束完成的回调，如果出错，表明递归完成都没能获取到数据；如果成功且container元素个数为0，表示锁中没有记录；其它情况获取到所有索引的记录或递归超次数后会执行此回调；此回调的参数等于传入的container。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)recursiveGetRecordAtIndexes:(NSArray<NSNumber *> *)indexes times:(int)times order:(KDSBleTunnelOrder)order container:(NSMutableArray<KDSBleRecord *> *)container completion:(void (^)(BOOL finished, KDSBleError error, NSArray * _Nonnull container))completion
{
    if (indexes.count == 0 || times >= 2)
    {
        !completion ?: completion(YES, KDSBleErrorSuccess, container);
        return @"";
    }
    NSMutableArray<NSNumber *> *losses = [NSMutableArray arrayWithArray:indexes];
    __weak typeof(self) weakSelf = self;
    NSMutableArray<NSNumber *> *groups = groups = [NSMutableArray array];//统计丢失的数据分在多少组。
    for (NSNumber *n in losses)
    {
        int group = n.intValue / 20;
        if (![groups containsObject:@(group)]) [groups addObject:@(group)];
    }
    
    return [self internalGetRecordWithOrder:order isAll:NO orAtGroup:groups ? groups.firstObject.intValue : -1 orAtIndex:groups ? -1 : losses.firstObject.intValue completion:^(BOOL finished, KDSBleError error, NSArray<KDSBleRecord *> * _Nullable records) {
        
        if (!finished || !completion) return;//由于分组获取数据量不大，因此等到数据收发结束再处理。
        if (error == KDSBleErrorSuccess)
        {
            if (records.count == 0)
            {
                [losses removeAllObjects];
            }
            else
            {
                for (KDSBleRecord *record in records)
                {
                    if (![container containsObject:record])
                    {
                        [container addObject:record];
                        [losses removeObject:@(record.current)];
                    }
                }
                int total = records.firstObject.total;
                for (NSInteger i = 0; i < losses.count; ++i)
                {
                    if (losses[i].intValue >= total)
                    {
                        [losses removeObjectAtIndex:i];
                        --i;
                    }
                }
            }
            !losses.count ?: completion(NO, KDSBleErrorSuccess, container);//获取完毕在外面执行回调。
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((losses.count ? 0.2 : 0) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf recursiveGetRecordAtIndexes:losses times:times+1 order:order container:container completion:completion];
            });
        }
        else
        {
            if (times >= 2 && container.count == 0)
            {
                !completion ?: completion(YES, error, container);//5次递归错误在这里执行回调。
            }
            else
            {
                [weakSelf recursiveGetRecordAtIndexes:losses times:times+1 order:order container:container completion:completion];//数据未获取完成且未超出递归次数，进入下一次递归。
            }
        }
    }];
}

/**
 *@abstract 递归获取全部记录。
 *@param times 递归次数，方法外调用时一般将此值设置为0，失败递归不超过5次。
 *@param order 记录类型，只能是KDSBleTunnelOrderGetUnlockRecord或者KDSBleTunnelOrderGetAlarmRecord。
 *@param container 初始时必须是一个可变数组，用来保存获取到的记录。
 *@param completion 每获取到一条记录就会执行一次回调。如果出错，表明递归完成都没能获取到数据；如果成功且container元素个数为0，表示锁中没有记录；其它情况获取到所有索引的记录或递归超次数后会执行此回调；此回调的参数等于传入的container。如果finished为YES，递归结束。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)recursiveGetAllRecords:(int)times order:(KDSBleTunnelOrder)order container:(NSMutableArray<KDSBleRecord *> *)container completion:(void (^)(BOOL finished, KDSBleError error, NSArray<KDSBleRecord *> * _Nonnull container))completion
{
    int total = container.firstObject ? container.firstObject.total : 200;
    if (total == container.count || times > 2)
    {
        [container sortUsingComparator:^NSComparisonResult(KDSBleRecord * _Nonnull obj1, KDSBleRecord *  _Nonnull obj2) {
            return obj1.current > obj2.current ? NSOrderedDescending : NSOrderedAscending;
        }];
        !completion ?: completion(YES, KDSBleErrorSuccess, container);//递归结束，全部或只有一部分数据，在这里执行回调
        return @"";
    }
    __weak typeof(self) weakSelf = self;
    //如果丢失的数据处于4组内，逐组获取，否则还是全部获取。这里的阈值可经过大量测试确定，此优化待测试。。。
    NSMutableArray<NSNumber *> *losses = [NSMutableArray arrayWithCapacity:total];
    for (int i = 0; i < total; ++i)
    {
        [losses addObject:@(i)];
    }
    for (KDSBleRecord *record in container)
    {
        if ([losses containsObject:@(record.current)])
        {
            [losses removeObject:@(record.current)];
        }
    }
    NSMutableArray<NSNumber *> *groups = groups = [NSMutableArray arrayWithCapacity:10];
    for (NSNumber *n in losses)
    {
        int group = n.intValue / 20;
        if (![groups containsObject:@(group)]) [groups addObject:@(group)];
    }
    //if (groups.count < 4)
    //    {
    return [self recursiveGetRecordAtIndexes:losses times:0 order:order container:container completion:^(BOOL finished, KDSBleError error, NSArray * _Nonnull container) {
        
        if (!completion) return;
        for (KDSBleRecord *record in container)
        {
            if ([losses containsObject:@(record.current)])
            {
                [losses removeObject:@(record.current)];
            }
        }
        if ((error==KDSBleErrorSuccess && container.count==0) || losses.count==0)
        {
            completion(YES, error, container);
            return;
        }
        completion(NO, error, container);
        if (finished)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf recursiveGetAllRecords:times + 1 order:order container:container completion:completion];
            });
        }
    }];
    //    }
    /*return [self internalGetRecordWithOrder:order isAll:YES orAtGroup:-1 orAtIndex:-1 completion:^(BOOL finished, KDSBleError error, NSArray<KDSBleRecord *> * _Nullable records) {
     
     if (!completion) return;
     if (error == KDSBleErrorSuccess)
     {
     if (records.count == 0)
     {
     completion(YES, KDSBleErrorSuccess, container);//锁中没有记录在这里执行回调
     }
     else
     {
     if (![container containsObject:records.lastObject])
     {
     [container addObject:records.lastObject];
     }
     //获取到全部数据时，在外面执行回调。
     BOOL complete = total==container.count;
     complete ?: completion(NO, error, container);
     if (finished)
     {
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((complete ? 0 : 0.2) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
     [weakSelf recursiveGetAllRecords:times + 1 order:order container:container completion:completion];//获取全部或部分数据，进入下一次递归
     });
     }
     }
     }
     else
     {
     if (times >= 4 && container.count == 0)
     {
     completion(YES, error, container);//5次递归错误在这里执行回调。
     }
     else
     {
     [weakSelf recursiveGetAllRecords:times + 1 order:order container:container completion:completion];//数据未获取完成且未超出递归次数，进入下一次递归。
     }
     }
     }];*/
}

/**
 *@abstract 递归获取全部操作记录。
 *@param times 递归次数，方法外调用时一般将此值设置为0，失败递归不超过3次。
 *@param fidx 开始编号，不能大于65535.
 *@param tidx 结束编号，不能大于65535.
 *@param container 初始时必须是一个包含0个对象的可变数组，用来保存获取到的记录。
 *@param completion 成功时，获取到数据执行的回调，每10条或数据传输完毕会执行一次回调，此回调的参数等于传入的container；失败时，则首次递归就失败了。如果finished为YES，递归结束。
 *@return 返回任务的凭证，如果任务还未执行，可以根据此凭证从队列中删除该任务。
 */
- (NSString *)recursiveGetOpRecords:(int)times fromIndex:(int)fidx toIndex:(int)tidx container:(NSMutableArray<KDSBleOpRec *> *)container completion:(void (^)(BOOL finished, KDSBleError error, NSArray<KDSBleOpRec *> * _Nonnull container))completion
{
    if ((container.count && (container.firstObject.niketotal==container.count || container.firstObject.niketotal==tidx+1)) || times>=3)
    {
        // 结束条件  数据已经填充完毕   操作记录的总条数等于21条 次数超出3次
        !completion ?: completion(YES, KDSBleErrorSuccess, container);
        return @"";
    }
    
    NSMutableArray<NSNumber *> *groups = nil;
    if (container.firstObject && container.firstObject.niketotal > 20)
    {
        groups = [NSMutableArray arrayWithCapacity:25];
        NSMutableArray<NSNumber *> *losses = [NSMutableArray array];
        for (int i = 0; i < container.firstObject.niketotal; ++i)
        {
            [losses addObject:@(i)];
        }
        for (KDSBleOpRec *rec in container)
        {
            if ([losses containsObject:@(rec.nikecurrent)]) [losses removeObject:@(rec.nikecurrent)];
        }
        for (NSNumber *loss in losses)
        {
            NSNumber *group = @(loss.intValue / 20);
            if (![groups containsObject:group]) [groups addObject:group];
        }
    }
    if (groups && groups.count < 25)
    {
        fidx = groups.firstObject.intValue * 20; tidx = fidx + 20;
    }
    __weak typeof(self) weakSelf = self;
    unsigned char payload[16] = {1, 3, fidx & 0xff, (fidx>>8) & 0xff, tidx & 0xff, (tidx>>8) & 0xff, 0};
    KDSBleTunnelTask *task = [self sendOrder:KDSBleTunnelOrderGetOpRec payload:payload tag:1 completion:^(KDSBleError error, NSData * _Nullable data) {
        //不考虑管理员模式
        if (/*error==KDSBleErrorAdminMode || */error==KDSBleErrorDuplOrAuthenticating)
        {
            !completion ?: completion(YES, error, container);
            return;
        }
        if (![data isKindOfClass:NSArray.class])
        {//获取操作记录时，如果超时则data为nil，否则最后一个记录获取完5秒后还没有新的记录代表蓝牙数据传输完毕。
            const Byte *bytes = data.bytes;
            KDSBleError err = bytes ? (KDSBleError)bytes[4] : error;
            err = container.count ? KDSBleErrorSuccess : err;
            if (err == KDSBleErrorSuccess)
            {
                [weakSelf recursiveGetOpRecords:times + 1 fromIndex:fidx toIndex:tidx container:container completion:completion];//dispatch_after
            }
            else
            {
                !completion ?: completion(YES, err, container);
            }
            return;
        }
        if (container.count == 0)
        {
            !completion ?: completion(YES, KDSBleErrorSuccess, container);
            return;
        }
        [container sortUsingComparator:^NSComparisonResult(KDSBleOpRec *  _Nonnull obj1, KDSBleOpRec *  _Nonnull obj2) {
            return obj1.nikecurrent > obj2.nikecurrent;
        }];//考虑数据量大时的排序
        !completion ?: completion(NO, KDSBleErrorSuccess, container);
        
    }];
    
    task.attrs = @{@"container" : container, @"fromIndex":@(fidx), @"toIndex":@(tidx)};
    return task.receipt ?: @"";
}

#pragma mark - 对外接口
#pragma mark  蓝牙功能部分
- (NSString *)authenticationWithPwd1:(NSString *)pwd1 pwd2:(id)pwd2 completion:(nullable void(^)(KDSBleError error))completion
{
    if ([pwd2 isKindOfClass:[NSString class]])
    {
        self.pwd2 = [KDSBleAssistant convertHexStrToData:(NSString *)pwd2];
    }
    self.pwd1 = pwd1;
    Byte payload[16] = {0};
    for (int i = 0; i < self.systemID.length; ++i)
    {
        payload[i] = ((Byte *)self.systemID.bytes)[i];
    }
    __weak typeof(self) weakSelf = self;
    KDSBleTunnelTask *task = [self sendOrder:KDSBleTunnelOrderAuth payload:payload tag:0 completion:^(KDSBleError error, NSData * _Nullable data) {
        
        if (!data)
        {
            !completion ?: completion(error);
            return;
        }
        const unsigned char *bytes = data.bytes;
        if (bytes[4] != 0 && weakSelf.pwd1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:KDSLockAuthFailedNotification object:nil userInfo:@{@"peripheral":weakSelf.connectedPeripheral, @"code":@(bytes[4])}];
            weakSelf.pwd3 = nil;
        }
        if (!weakSelf.pwd1)//如果密码为空，有可能是绑定时还没有获取密码就已经操作绑定，此时应该获取一下序列号。
        {
            [weakSelf getDeviceInfoWithDevType:DeviceInfoSerialNum];
        }
        //0成功，1失败，0x7e未绑定(pwd2为空)，0x91鉴权内容不正确，0x9A重复，0xC0硬件错误，0xC2校验错误(一般是pwd2被修改)
        //payload的第一个字节是执行结果。
        !completion ?: completion((KDSBleError)bytes[4]);
        
    }];
    
    return task.receipt ?: @"";
}

- (void)startRetrieveUsersAndSchedules
{
    [self.retrievedUsersArr removeAllObjects];
    self.retrievingUserId = 0;
    //[self.retrievedSchedulesArr removeAllObjects];
    //self.retrievingScheduleId = 0;
}

- (NSString *)getAllUsersWithKeyType:(KDSBleKeyType)keyType completion:(void (^)(KDSBleError, NSArray<KDSBleUserType *> * _Nullable))completion
{
    Byte payload[16] = {(char)keyType, 0};
    //这个命令每条数据最多能包含100条密匙信息，超过100条密匙信息，会分开多条数据返回，这里暂时不考虑此种情况。
    return [self sendOrder:KDSBleTunnelOrderSyncKey payload:payload tag:0 completion:^(KDSBleError error, NSData * _Nullable data) {
        const unsigned char *bytes = data.bytes;//bytes方法指向接收者管理的一段连续的内存，即取出data的首地址
        NSLog(@"--{Kaadas}--密钥--%@",data);
        if (!data || bytes[3] != (int)KDSBleTunnelOrderSyncKey)
        {
            KDSBleError err = !data ? KDSBleErrorNoReply : (bytes[4] == 0 ? KDSBleErrorFailure : (KDSBleError)bytes[4]);
            !completion ?: completion(err, nil);
            return;
        }
        int total = bytes[6];//锁最大秘钥个数，蓝牙模块 所有类型赋值都是100
        //把密匙信息占用的字节数以及位都提取出来。
        int totalBytes = ceil(bytes[6] / 8.0);//密匙信息占用的字节数
        const unsigned char *infos = bytes + 7;//内存地址加7，即内存地址指向data的Value首位
        NSMutableArray<NSNumber *> *bits = [NSMutableArray arrayWithCapacity:totalBytes * 8];//密匙信息占用的位数
        while (totalBytes)
        {
            for (char i = 7, c = *infos; i > -1; --i)
            {
                [bits addObject:@((c >> i) & 0x1)];//循环判断 char 字符变量右移i位与上0x1
            }
            totalBytes--;
            infos++;//内存地址加1：下一个字节
        }
        NSMutableArray<KDSBleUserType *> *users = [NSMutableArray arrayWithCapacity:total];
        //查询所有密钥编号按一个编号1Bit,1表示密钥存在，0表示不存在。序号采用倒序排列，低编号在前。
        for (int j = 0; j < bits.count; ++j)
        {
            if (!bits[j].intValue || bytes[5] != (int)keyType) continue;
            KDSBleUserType *user = [KDSBleUserType new];
            user.keyType = (KDSBleKeyType)bytes[5];
            user.userId = j;
            [users addObject:user];
        }
        !completion ?: completion(KDSBleErrorSuccess, users);
    }].receipt ?: @"";
}

- (NSString *)updateLockClock:(nullable void (^)(KDSBleError))completion
{
    if (!self.isAdmin)
    {
        !completion ?: completion(KDSBleErrorNoReply);
        return @"";
    }
    // 得到当前时间（世界标准时间 UTC/GMT）
    NSDate *date = [NSDate date];
    // 设置系统时区为本地时区
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    // 计算本地时区与 GMT 时区的时间差
    NSInteger interval = [zone secondsFromGMT];
    //得到本地时间
    date = [date dateByAddingTimeInterval:interval];
    //本地时间距离1970年的时间
    NSTimeInterval time=[date timeIntervalSince1970];
    long long int timeTo2000 = (long long int)time - FixedTime;
    Byte payload[16] = {3, 4, timeTo2000 & 0xff, (timeTo2000 >> 8) & 0xff, (timeTo2000 >> 16) & 0xff, (timeTo2000 >> 24) & 0xff, 0};
    return [self sendOrder:KDSBleTunnelOrderUpdateLockParam payload:payload tag:0 completion:^(KDSBleError error, NSData * _Nullable data) {
        !completion ?: completion(error);
    }].receipt ?: @"";
}

- (NSString *)setLockLanguage:(NSString *)language completion:(void (^)(KDSBleError))completion
{
    Byte payload[16] = {1, 2, language.UTF8String[0], language.UTF8String[1], 0};
    return [self sendOrder:KDSBleTunnelOrderUpdateLockParam payload:payload tag:0 completion:^(KDSBleError error, NSData * _Nullable data) {
        !completion ?: completion(error);
    }].receipt ?: @"";
}

- (NSString *)setLockVolume:(int)volume completion:(void (^)(KDSBleError))completion
{
    Byte payload[16] = {2, 1, volume, 0};
    return [self sendOrder:KDSBleTunnelOrderUpdateLockParam payload:payload tag:0 completion:^(KDSBleError error, NSData * _Nullable data) {
        !completion ?: completion(error);
    }].receipt ?: @"";
}

- (NSString *)setLockAutoLockStatus:(int)status completion:(nullable void(^)(KDSBleError error))completion
{
    Byte payload[16] = {4, 1, status, 0};
    return [self sendOrder:KDSBleTunnelOrderUpdateLockParam payload:payload tag:0 completion:^(KDSBleError error, NSData * _Nullable data) {
        !completion ?: completion(error);
    }].receipt ?: @"";
}

- (NSString *)setLockLockInsideStatus:(int)status completion:(nullable void(^)(KDSBleError error))completion
{
    Byte payload[16] = {5, 1, status, 0};
    return [self sendOrder:KDSBleTunnelOrderUpdateLockParam payload:payload tag:0 completion:^(KDSBleError error, NSData * _Nullable data) {
        !completion ?: completion(error);
    }].receipt ?: @"";
}

- (NSString *)setLockAwayHomeStatus:(int)status completion:(nullable void(^)(KDSBleError error))completion
{
    Byte payload[16] = {6, 1, status, 0};
    return [self sendOrder:KDSBleTunnelOrderUpdateLockParam payload:payload tag:0 completion:^(KDSBleError error, NSData * _Nullable data) {
        !completion ?: completion(error);
    }].receipt ?: @"";
}

- (NSString *)setLockBleStatus:(int)status completion:(nullable void(^)(KDSBleError error))completion
{
    Byte payload[16] = {7, 1, status, 0};
    return [self sendOrder:KDSBleTunnelOrderUpdateLockParam payload:payload tag:0 completion:^(KDSBleError error, NSData * _Nullable data) {
        !completion ?: completion(error);
    }].receipt ?: @"";
}

- (NSString *)setLockSecurityModeStatus:(int)status completion:(nullable void(^)(KDSBleError error))completion
{
    Byte payload[16] = {8, 1, status, 0};
    return [self sendOrder:KDSBleTunnelOrderUpdateLockParam payload:payload tag:0 completion:^(KDSBleError error, NSData * _Nullable data) {
        !completion ?: completion(error);
    }].receipt ?: @"";
}

- (NSString *)operateLockWithPwd:(NSString *)pwd actionType:(KDSBleLockControl)action keyType:(KDSBleLockControl)key completion:(nullable void(^)(KDSBleError error, CBPeripheral * __nullable peripheral))completion
{
    __weak typeof(self) weakSelf = self;
    if (_connectedPeripheral.isNewDevice)
    {
        key = self.connectedPeripheral.unlockPIN ? key : KDSBleLockControlKeyAPP;
        Byte payload[16] = {(char)action, (char)key, 0, 0};
        if (key != KDSBleLockControlKeyAPP)
        {
            payload[3] = pwd.length;//密码长度
            //第4个字节开始是密码，每一个字节保存一位密码。
            for (int i = 0; i< pwd.length; i++)
            {
                payload[i + 4] = pwd.UTF8String[i];
            }
        }
        return [self sendOrder:KDSBleTunnelOrderControl payload:payload tag:0 completion:^(KDSBleError error, NSData * _Nullable data) {
            if (error == KDSBleErrorSuccess) [weakSelf getDeviceElectric];
            !completion ?: completion(error, error==KDSBleErrorSuccess ? weakSelf.connectedPeripheral : nil);
        }].receipt ?: @"";
    }
    else
    {
        //这里旧模块暂时只考虑开锁功能
        if (action != KDSBleLockControlActionUnlock) return @"";
        KDSBleTunnelTask *task = [[KDSBleTunnelTask alloc] init];
        task.command = KDSBleOldCommandLockStatus;//开锁发的是C2命令，结果却是通过B1返回，这协议是要上天？
        NSString *receipt = task.receipt;
        task.bleReplyBlock = ^(NSData * _Nullable data) {
            if (!data)
            {
                weakSelf.tasksMDict[receipt] = nil;
                !completion ?: completion(KDSBleErrorNoReply, nil);
                return;
            }
            const unsigned char *bytes = data.bytes;
            !completion ?: completion(bytes[5]==0x01 ? KDSBleErrorSuccess : KDSBleErrorFailure, weakSelf.connectedPeripheral);
        };
        self.tasksMDict[receipt] = task;
        [self oldBleModelbeginOpenLock];
        return receipt;
    }
}

- (NSString *)getAllRecord:(int)type completion:(void (^)(BOOL, KDSBleError, NSArray<KDSBleRecord *> * _Nullable))completion
{
    if (type != 1 && self.connectedPeripheral.bleVersion == 1)
    {
        !completion ?: completion(YES, KDSBleErrorInvalidField, nil);
        return @"0";
    }
    NSAssert(type==1 || type==2, @"暂时只支持开锁记录和报警记录。");
    void(^__block completion_)(BOOL, KDSBleError, NSArray<KDSBleUnlockRecord *> * _Nullable) = completion;
    NSMutableArray *container = [NSMutableArray array];
    return [self recursiveGetAllRecords:0 order:type==1 ? KDSBleTunnelOrderGetUnlockRecord : KDSBleTunnelOrderGetAlarmRecord container:container completion:^(BOOL finished, KDSBleError error, NSArray * _Nonnull container) {
        !completion_ ?: completion_(finished, error, error==KDSBleErrorSuccess ? container.copy : nil);
        if (finished)
        {
            completion_ = nil;
        }
    }];
}

- (NSString *)getRecord:(int)type atGroup:(int)group completion:(void (^)(KDSBleError, NSArray<KDSBleRecord *> * _Nullable))completion
{
    if (group < 0 || group > 9 || (type != 1 && self.connectedPeripheral.bleVersion == 1))
    {
        !completion ?: completion(KDSBleErrorInvalidField, nil);
        return @"0";
    }
    NSAssert(type==1 || type==2, @"暂时只支持开锁记录和报警记录。");
    void(^__block _completion)(KDSBleError, NSArray*) = completion;
    NSMutableArray *container = [NSMutableArray arrayWithCapacity:20];
    NSMutableArray *losses = [NSMutableArray arrayWithCapacity:20];
    for (int i = group * 20; i < (group + 1) * 20; ++i)
    {
        [losses addObject:@(i)];
    }
    return [self recursiveGetRecordAtIndexes:losses times:0 order:type==1 ? KDSBleTunnelOrderGetUnlockRecord : KDSBleTunnelOrderGetAlarmRecord container:container completion:^(BOOL finished, KDSBleError error, NSArray * _Nonnull container) {
        if (!_completion || !finished) return;
        _completion(error, error==KDSBleErrorSuccess ? container.copy : nil);
        _completion = nil;
    }];
}

- (NSString *)getRecord:(int)type atIndex:(int)index completion:(void (^)(KDSBleError, KDSBleRecord * _Nullable))completion
{
    if (self.connectedPeripheral && !self.connectedPeripheral.isNewDevice) return @"0";//不支持
    NSAssert(type==1 || type==2, @"暂时只支持开锁记录和报警记录。");
    return [self internalGetRecordWithOrder:type==1 ? KDSBleTunnelOrderGetUnlockRecord : KDSBleTunnelOrderGetAlarmRecord isAll:NO orAtGroup:-1 orAtIndex:index completion:^(BOOL finished, KDSBleError error, NSArray<KDSBleUnlockRecord *> * _Nullable records) {
        !completion ?: completion(error, records.firstObject);
    }];
}

- (NSString *)updateRecord:(int)type afterData:(NSString *)data completion:(void (^)(BOOL, KDSBleError, NSArray<KDSBleRecord *> * _Nullable))completion
{
    NSAssert(type==1 || type==2, @"暂时只支持开锁记录和报警记录。");
    void(^__block completion_)(BOOL, KDSBleError, NSArray *) = completion;
    //从效率上说先请求第一组记录，如果没有或者记录已上传过，则处理第一组记录后结束。这里的逻辑是假定开锁数据都是唯一的。
    return [self getRecord:type atGroup:0 completion:^(KDSBleError error, NSArray<KDSBleRecord *> * _Nullable records) {
        
        if (!completion_) return;
        if (!records.count)
        {
            completion_(YES, error, records);
            completion_ = nil;
            return;
        }
        Class cls = type==1 ? KDSBleUnlockRecord.class : KDSBleAlarmRecord.class;
        KDSBleRecord *rec = [[cls alloc] initWithHexString:data];
        BOOL after = ![rec isEqual:records.firstObject];
        if (!after)
        {
            completion_(YES, error, [NSArray array]);
            completion_ = nil;
            return;
        }
        
        after = YES;
        NSMutableArray<KDSBleRecord *> *mRecords = [NSMutableArray array];
        for (KDSBleRecord *record in records)
        {
            [mRecords addObject:record];
            if ([rec isEqual:record])
            {
                after = NO;
                break;
            }
        }
        if (!after || records.firstObject.total == records.count)
        {
            //到这儿开始，只有第一组有新数据没有上传
            completion_(YES, error, mRecords.copy);
            completion_ = nil;
            return;
        }
        completion_(NO, error, records);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self recursiveGetAllRecords:0 order:type==1 ? KDSBleTunnelOrderGetUnlockRecord : KDSBleTunnelOrderGetAlarmRecord container:mRecords completion:^(BOOL finished, KDSBleError error, NSArray * _Nonnull container) {
                !completion_ ?: completion_(finished, error, error==KDSBleErrorSuccess ? container.copy : nil);
                if (finished)
                {
                    completion_ = nil;
                }
            }];
        });
    }];
}

- (NSString *)setUserTypeWithId:(NSString *)userId KeyType:(KDSBleKeyType)keyType userType:(KDSBleSetUserType)userType completion:(nullable void (^)(KDSBleError))completion
{
    Byte payload[16] = {(char)keyType, userId.intValue, (char)userType, 0};
    return [self sendOrder:KDSBleTunnelOrderSetUserType payload:payload tag:0 completion:^(KDSBleError error, NSData * _Nullable data) {
        !completion ?: completion(error);
    }].receipt ?: @"";
}

- (NSString *)getUserTypeWithId:(NSString *)userId KeyType:(KDSBleKeyType)keyType completion:(void (^)(KDSBleError, KDSBleUserType * _Nullable))completion
{
    Byte payload[16] = {(char)keyType, userId.intValue, 0};
    return [self sendOrder:KDSBleTunnelOrderGetUserType payload:payload tag:0 completion:^(KDSBleError error, NSData * _Nullable data) {//这是查询命令，不能根据error参数判断成功与否。
        const unsigned char *bytes = data.bytes;
        if (!data || bytes[3] == 0)
        {
            KDSBleError err = !data ? KDSBleErrorNoReply : (bytes[4] == 0 ? KDSBleErrorFailure : (KDSBleError)bytes[4]);
            !completion ?: completion(err, nil);
            return;
        }
        KDSBleError err = bytes[5] == userId.intValue ? KDSBleErrorSuccess : KDSBleErrorFailure;
        err = bytes[6] == 0xff ? KDSBleErrorLockTimeout : err;
        KDSBleUserType *user = [KDSBleUserType new];
        user.keyType = (KDSBleKeyType)bytes[4];
        user.userId = bytes[5];
        user.userType = (KDSBleSetUserType)bytes[6];
        !completion ?: completion(err, err == KDSBleErrorSuccess ? user : nil);
    }].receipt ?: @"";
}

- (NSString *)scheduleYMDWithScheduleId:(int)scheduleId userId:(int)userId keyType:(KDSBleKeyType)keyType begin:(NSString *)begin end:(NSString *)end completion:(nullable void(^)(KDSBleError error))completion
{
    begin = [KDSBleAssistant extractDateString:begin];
    end = [KDSBleAssistant extractDateString:end];
    self.dateFormatter.dateFormat = @"yyyyMMddHHmmss";
    NSDate *beginDate = [self.dateFormatter dateFromString:begin];
    NSDate *endDate = [self.dateFormatter dateFromString:end];
    NSInteger secondsFromGMT = [NSTimeZone systemTimeZone].secondsFromGMT;
    //距2000年1月1日0时0分0秒的秒数
    unsigned beginSec = (unsigned)(beginDate.timeIntervalSince1970 + secondsFromGMT - FixedTime);
    unsigned endSec = (unsigned)(endDate.timeIntervalSince1970 + secondsFromGMT - FixedTime);
    //    scheduleId = scheduleId > KDSMaxScheduleId ? scheduleId : scheduleId;
    Byte payload[16] = {scheduleId, userId, keyType, beginSec & 0xff, (beginSec >> 8) & 0xff, (beginSec >> 16) & 0xff, (beginSec >> 24) & 0xff, endSec & 0xff, (endSec >> 8) & 0xff, (endSec >> 16) & 0xff, (endSec >> 24) & 0xff, 0};
    return [self sendOrder:KDSBleTunnelOrderSetYMD payload:payload tag:0 completion:^(KDSBleError error, NSData * _Nullable data) {
        !completion ?: completion(error);
    }].receipt ?: @"";
}

- (NSString *)deleteYMD:(int)scheduleId completion:(void (^)(KDSBleError))completion
{
    //    scheduleId = scheduleId > KDSMaxScheduleId ? scheduleId : scheduleId;
    Byte payload[16] = {scheduleId, 0};
    return [self sendOrder:KDSBleTunnelOrderDeleteYMD payload:payload tag:0 completion:^(KDSBleError error, NSData * _Nullable data) {
        !completion ?: completion(error);
    }].receipt ?: @"";
}

- (NSString *)scheduleWeeklyWithScheduleId:(int)scheduleId userId:(int)userId keyType:(KDSBleKeyType)keyType weekMask:(int)mask beginHour:(int)beginHour beginMin:(int)beginMin endHour:(int)endHour endMin:(int)endMin completion:(void (^)(KDSBleError))completion
{
    //    scheduleId = scheduleId > KDSMaxScheduleId ? scheduleId : scheduleId;
    Byte payload[16] = {scheduleId, (char)keyType, userId, mask, beginHour, beginMin, endHour, endMin, 0};
    return [self sendOrder:KDSBleTunnelOrderSetWeekly payload:payload tag:0 completion:^(KDSBleError error, NSData * _Nullable data) {
        !completion ?: completion(error);
    }].receipt ?: @"";
}

- (NSString *)deleteWeekly:(int)scheduleId completion:(void (^)(KDSBleError))completion
{
    //    scheduleId = scheduleId > KDSMaxScheduleId ? scheduleId : scheduleId;
    Byte payload[16] = {(char)(scheduleId), 0};
    return [self sendOrder:KDSBleTunnelOrderDeleteWeekly payload:payload tag:0 completion:^(KDSBleError error, NSData * _Nullable data) {
        !completion ?: completion(error);
    }].receipt ?: @"";
}

- (NSString *)getScheduleWithScheduleId:(int)scheduleId completion:(void (^)(KDSBleError, KDSBleScheduleModel * _Nullable))completion
{
    //    scheduleId = scheduleId > KDSMaxScheduleId ? scheduleId : scheduleId;
    Byte payload[16] = {scheduleId, 0};
    return [self sendOrder:KDSBleTunnelOrderGetWeekly payload:payload tag:0 completion:^(KDSBleError error, NSData * _Nullable data) {//此命令不能根据error参数判断成功与否。
        const unsigned char *bytes = data.bytes;
        //蓝牙不区分年月日和周计划，为了区别，根据协议这里判断这3个字节是不是都为0，如果否则表示这是一个年月日计划。
        if (!data)
        {
            !completion ?: completion(error, nil);
            return;
        }
        if (bytes[12] == bytes[13] && bytes[13] == bytes[14] && bytes[12] == 0)
        {
            KDSBleWeeklyModel *model = [[KDSBleWeeklyModel alloc] initWithData:data];
            BOOL result = bytes[4] == scheduleId;
            result = result && (bytes[10] > bytes[8] || (bytes[10] == bytes[8] && bytes[11] >= bytes[9]));
            !completion ?: completion(result ? KDSBleErrorSuccess : KDSBleErrorFailure, result ? model : nil);
        }
        else
        {
            KDSBleYMDModel *model = [[KDSBleYMDModel alloc] initWithData:data];
            KDSBleError err = (bytes[4] == scheduleId && model.beginTime <= model.endTime) ? KDSBleErrorSuccess : KDSBleErrorFailure;
            !completion ?: completion(err, err == KDSBleErrorSuccess ? model : nil);
        }
    }].receipt ?: @"";
}

- (NSString *)manageKeyWithPwd:(NSString *)pwd userId:(NSString *)userId action:(KDSBleKeyManageAction)action keyType:(KDSBleKeyType)keyType completion:(void (^)(KDSBleError))completion
{
    if (action == KDSBleKeyManageActionAlter)
    {
        return [self manageKeyWithPwd:pwd userId:userId action:KDSBleKeyManageActionDelete keyType:keyType completion:^(KDSBleError error) {
            if (error != KDSBleErrorSuccess)
            {
                !completion ?: completion(error);
                return;
            }
            [self manageKeyWithPwd:pwd userId:userId action:KDSBleKeyManageActionSet keyType:keyType completion:^(KDSBleError error) {
                !completion ?: completion(error);
            }];
        }];
    }
    if (action == KDSBleKeyManageActionSet && keyType == KDSBleKeyTypeAdmin) userId = @"255";
    Byte payload[16] = {(char)action, (char)keyType, userId.intValue, pwd.length, 0};
    for (int i = 0; i < pwd.length; ++i)
    {
        payload[4 + i] = pwd.UTF8String[i];
    }
    KDSMQTTTask *task = [self sendOrder:KDSBleTunnelOrderKeyManage payload:payload tag:0 completion:^(KDSBleError error, NSData * _Nullable data) {
        !completion ?: completion(error);
    }];
    if ((keyType == KDSBleKeyTypeFingerprint || keyType == KDSBleKeyTypeRFID) && action == KDSBleKeyManageActionSet)
    {
        task.timeout = 80;//设置指纹/卡片超时时间设为80秒。
    }
    return task.receipt ?: @"";
}

- (NSString *)getLockInfo:(void (^)(KDSBleError, KDSBleLockInfoModel * _Nullable))completion
{
    Byte payload[16] = {1, 0};
    return [self sendOrder:KDSBleTunnelOrderGetLockInfo payload:payload tag:0 completion:^(KDSBleError error, NSData * _Nullable data) {
        const Byte *bytes = data.bytes;
        if (!bytes || bytes[3] != (int)KDSBleTunnelOrderGetLockInfo)
        {
            !completion ?: completion(error == KDSBleErrorSuccess ? KDSBleErrorFailure : error, nil);
            return;
        }
        KDSBleLockInfoModel *model = [[KDSBleLockInfoModel alloc] initWithData:data];
        unsigned seconds = *((unsigned *)(bytes + 16));//系统刚好是小端，所以这里的值不用再转换了。
        seconds -= [[NSTimeZone localTimeZone] secondsFromGMT];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds + FixedTime];
        self.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        model.time = [self.dateFormatter stringFromDate:date];
        !completion ?: completion(KDSBleErrorSuccess, model);
    }].receipt ?: @"";
}

- (NSString *)bindBleWithManagerPassword:(NSString *)pwd completion:(void (^)(KDSBleError))completion
{
    if (!self.connectedPeripheral || !self.writeCharacteristic)
    {
        !completion ?: completion(KDSBleErrorFailure);
        return @"";
    }
    NSAssert(pwd.length > 4 && pwd.length == strlen(pwd.UTF8String), @"传递的管理密码不正确");//没加区分数字
    Byte payload[16] = {pwd.length, 0};
    int checksum = (int)pwd.length;
    for (int i = 0; i < pwd.length; ++i)
    {
        payload[i + 1] = pwd.UTF8String[i];
        checksum += pwd.UTF8String[i];
    }
    for (NSUInteger j = pwd.length; j < 16; ++j)
    {
        payload[j] = arc4random() % 256;
        checksum += payload[j];
    }
    KDSBleTunnelTask *task = [self sendOrder:KDSBleTunnelOrderBind payload:payload tag:0 completion:^(KDSBleError error, NSData * _Nullable data) {
        !completion ?: completion(error);
    }];
    
    return task.receipt ?: @"";
}

- (NSString *)getSN:(void (^)(KDSBleError, NSString * _Nullable))completion
{
    Byte payload[16] = {0};
    //如果成功，前六个字节装头数据，七至二十三装序列号。
    KDSBleTunnelTask *task = [self sendOrder:KDSBleTunnelOrderGetSN payload:payload tag:1 completion:^(KDSBleError error, NSData * _Nullable data) {
        const unsigned char *bytes = data.bytes;
        error = !data ? KDSBleErrorNoReply : (data.length == 20 ? (KDSBleError)bytes[4] : KDSBleErrorSuccess);
        !completion ?: completion(error, error == KDSBleErrorSuccess ? [[NSString alloc] initWithBytes:bytes + 6 length:17 encoding:NSUTF8StringEncoding] : nil);
    }];
    task.attrs = @{@"container" : [NSMutableData dataWithCapacity:23]};
    
    return task.receipt ?: @"";
}

- (NSString *)getUnlockTimes:(void (^)(KDSBleError, int))completion
{
    Byte payload[16] = {0};
    return [self sendOrder:KDSBleTunnelOrderGetTimes payload:payload tag:0 completion:^(KDSBleError error, NSData * _Nullable data) {
        const Byte *bytes = data.bytes;
        if (!bytes)
        {
            !completion ?: completion(KDSBleErrorNoReply, -1);
            return;
        }
        KDSBleError err = bytes[3] == KDSBleTunnelOrderGetTimes ? KDSBleErrorSuccess : (KDSBleError)bytes[4];
        !completion ?: completion(err, err == KDSBleErrorSuccess ? *(unsigned*)(bytes+4) : -1);
    }].receipt ?: @"";
}

- (NSString *)getLockParam:(int)type completion:(void (^)(KDSBleError, id _Nullable))completion
{
    Byte payload[16] = {type, 0};
    __weak typeof(self) weakSelf = self;
    return [self sendOrder:KDSBleTunnelOrderGetParam payload:payload tag:0 completion:^(KDSBleError error, NSData * _Nullable data) {
        
        if (!completion) return;
        if (data.length != 20)
        {
            completion(!data ? error : KDSBleErrorFailure, nil);
            return;
        }
        const uint8_t *bytes = data.bytes;
        //bytes[5] == type ??
        switch (type) {
            case 1:
                completion(error, [data subdataWithRange:NSMakeRange(6, 14)]);
                break;
            case 2:
            case 3:
            case 4:
            {
                NSString *value = @((const char*)bytes + 6);
                if (type == 2)
                {
                    /*NSRange range = [value rangeOfString:@"0"];
                     if (range.location != NSNotFound)
                     {
                     value = [value substringToIndex:range.location];
                     }*/
                    if (weakSelf.connectedPeripheral.bleVersion > 2 && value.length > 2)
                    {
                        value = [value substringToIndex:value.length - 2];
                    }
                }
                completion(error, value);
            }
                break;
                
            case 5:
                completion(error, @(bytes[6]));
                break;
                
            default:
                completion(KDSBleErrorInvalidField, nil);//参数不正确
                break;
        }
    }].receipt ?: @"";
}

- (NSString *)getOpRecAfterData:(NSString *)data completion:(void (^)(BOOL, KDSBleError, NSArray<KDSBleOpRec *> * _Nullable))completion
{
    int toIndex = data ? 20 : 500;
    NSMutableArray *container = [NSMutableArray array];
    __block void(^_completion)(BOOL, KDSBleError, NSArray *) = completion;
    __weak typeof(self) weakSelf = self;
     // times 递归次数 初始值为 0    开始的index  结束的index   记录保存
    return [self recursiveGetOpRecords:0 fromIndex:0 toIndex:toIndex container:container completion:^(BOOL finished, KDSBleError error, NSArray<KDSBleOpRec *> * _Nonnull container) {
        if (!finished)
        {
            !_completion ?: _completion(NO, error, container.copy);
        }
        else
        {
            KDSBleOpRec *rec = [[KDSBleOpRec alloc] initWithHexString:data];
            BOOL after = rec && [container containsObject:rec];
            if ((data && !after) && container.count)
            {
                [weakSelf recursiveGetOpRecords:0 fromIndex:container.count==toIndex ? toIndex : 0 toIndex:500 container:container completion:^(BOOL finished, KDSBleError error, NSArray<KDSBleOpRec *> * _Nonnull container) {
                    if (!finished)
                    {
                        !_completion ?: _completion(NO, error, container.copy);
                    }
                    else
                    {
                        !_completion ?: _completion(YES, error, container.count ? container.copy : nil);
                        _completion = nil;
                    }
                }];
            }
            else
            {
                !_completion ?: _completion(YES, error, error==KDSBleErrorSuccess ? container.copy : nil);
                _completion = nil;
            }
        }
    }];
}

- (void)cancelTaskWithReceipt:(NSString *)receipt
{
    if (receipt.length == 0 || receipt.intValue == 0) return;
    self.tasksMDict[receipt].bleReplyBlock = nil;
    self.tasksMDict[receipt] = nil;
}

#pragma 瑞瀛网关协议
/**
 *@abstract 执行任务。将创建并配置好的任务的数据发送到蓝牙。
 *@param task 创建并配置好的任务。
 */
- (void)performRYTask:(KDSBleTunnelTask *)task
{
    //发送新命令的时候，如果已在队列中的命令被标记了重发就取消重发，免得锁蓝牙处理混乱。
    for (KDSBleTunnelTask *task in self.tasksMDict.allValues)
    {
        task.taskResendBlock = nil;
    }
    NSMutableData *key = [NSMutableData dataWithData:[KDSBleAssistant convertHexStrToData:self.pwd1]];
    
    if (self.connectedPeripheral && self.writeCharacteristic)
    {
        NSLog(@"--{Kaadas}--执行任务data=%@",task.data);
        [self.connectedPeripheral writeValue:key forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
    __weak typeof(self) weakSelf = self;
    task.taskResendBlock = ^{
        if (weakSelf.connectedPeripheral && weakSelf.writeCharacteristic)
        {
            [weakSelf.connectedPeripheral writeValue:key forCharacteristic:weakSelf.writeCharacteristic type:0];
        }
    };
}
/**
 *@abstract 根据命令类型创建一个任务。任务成功创建后，会自动添加到当前队列中。
 *@param orderType 命令类型，参考KDSRYBle2WiFi枚举。
 *@param payload 蓝牙协议对应命令所需的载荷数据。
 *@return 命令对象。
 */
- (nullable KDSBleTunnelTask *)createRYTask:(KDSRYBleOrder)orderType withPayload:(NSString *)payload
{
    
    KDSBleTunnelTask *task = self.tasksMDict[@(self.tsn).stringValue];
    if (self.tasksMDict.count > 4) {return nil; }
    if (task && task.order == KDSRYBle2WiFi) { return nil; }
    
    //    int sum = [KDSBleAssistant sumOfDataThroughoutBytes:[payload dataUsingEncoding:NSUTF8StringEncoding]];
    self.tsn++;
    //    unsigned char* bytes = (unsigned char*)malloc(20);
    //    bytes[0] = 1; bytes[1] = self.tsn; bytes[2] = sum; bytes[3] = orderType;
    //    memcpy(bytes + 4, [payload UTF8String], 16);
    task = [[KDSBleTunnelTask alloc] initWithData:[payload dataUsingEncoding:NSUTF8StringEncoding]];
    self.tasksMDict[@(task.tsn).stringValue] = task;
    return task;
}
/**
 *@abstract 发送蓝牙命令。此方法根据传入的参数封装了一个命令对象，设置了bleReplyBlock属性。
 *@note 递归执行此方法时，需注意命令重复和管理模式的错误。当tag非0时，请注意数据成功收发完毕后从队列中移除对应的任务。
 *@param order 要发送的命令。
 *@param payload 命令的有效数据，请确保是合法的16字节且填充0的数据。
 *@param tag 这个标记是用来标记执行completion回调时是否将队列中的任务删除的，0删除，非0不删除。如果蓝牙命令有多次回复，则不应删除，否则无法处理第一条后的数据(由于在队列中找不到任务，导致数据被丢弃)。但是，如果超时，即使tag非0，任务也会从队列中移除。
 *@param completion 超时或者收到蓝牙回复后执行的回调，error参考KDSBleError(如果只是简单的应答帧才使用此参数，否则不应该使用此参数，具体需参考蓝牙协议每个命令的数据格式)，data为蓝牙返回的数据，如果超时则为空。
 *@return 返回内部创建的命令，如果命令重复情况，则返回空。
 */
- (nullable KDSBleTunnelTask *)sendRYOrder:(KDSRYBleOrder)order payload:(NSString *)payload tag:(int)tag completion:(nullable void(^)(KDSBleError error, NSData * __nullable data))completion
{
    if (!self.connectedPeripheral)
    {
        !completion ?: completion(KDSBleErrorFailure, nil);
        return nil;
    }
    
    KDSBleTunnelTask *task = [self createRYTask:order withPayload:payload];
    if (!task)
    {
        !completion ?: completion(KDSBleErrorDuplOrAuthenticating, nil);
        return nil;
    }
    NSString *receipt = task.receipt;
    __weak typeof(self) weakSelf = self;
    NSLog(@"bleReplyBlock");
    task.bleReplyBlock = ^(NSData * _Nullable data) {
        NSLog(@"bleReplyBlock==%@",data);
        //        if (tag == 0 || !data) weakSelf.tasksMDict[receipt] = nil;
        //        if (!completion) return;
        //        if (!data)
        //        {
        //            completion(!weakSelf.pwd3 ? KDSBleErrorDuplOrAuthenticating : KDSBleErrorNoReply, nil);
        //        }
        //        else if ([data isKindOfClass:NSData.class])
        //        {
        //            const unsigned char *bytes = data.bytes;//bytes[4]是执行结果。
        //            completion((KDSBleError)bytes[4], data);
        //        }
        //        else
        //        {
        //            completion(KDSBleErrorSuccess, data);
        //        }
    };
    [self performRYTask:task];
    
    return task;
}
- (NSString *)sendaccountData:(nullable NSString *)data completion:(nullable void(^)(KDSBleError error))completion
{
    if (!self.connectedPeripheral)
    {
        !completion ?: completion(KDSBleErrorFailure);
        return nil;
    }
    return [self sendRYOrder:KDSRYBle2WiFi payload:data tag:0 completion:^(KDSBleError error, NSData * _Nullable data) {
        !completion ?: completion(error);
    }].receipt ?: @"";
}

///回复模块ACK
-(void)sendBleAndWiFiResponseInOrOutNet:(int)control tsn:(int)tsn cmd:(int)cmd value:(int)value
{
    if (tsn == 0) {
        tsn = self.tsn;
    }
    Byte payload[16] = {(char)value, 0};
    int sum = [KDSBleAssistant sumOfDataThroughoutBytes:[[NSData alloc] initWithBytes:payload length:16]];
    unsigned char* bytes = (unsigned char*)malloc(20);
    
    bytes[0] = control;bytes[1] = tsn; bytes[2] = sum; bytes[3] = cmd;
    memcpy(bytes + 4, payload, 16);
    NSData * sendData = [[NSData alloc] initWithBytesNoCopy:bytes length:20];
    if (self.connectedPeripheral)
    {///设备已经连接且要写入特征
        [self.connectedPeripheral writeValue:sendData forCharacteristic:self.writeCharacteristic type:0];
        NSLog(@"Wi-Fi锁发送ACK到模块的数据：%@,蓝牙地址：%@",sendData,self.connectedPeripheral);
    }
}

-(void)sendWiFiSSIDWithSSID_len:(int)SSID_len SSID_index:(int)SSID_index cmd:(int)cmd SSIDData:(NSData *)ssidData completion:(nullable void(^)(KDSBleError error))completion
{
    
    Byte payload[16];// = {SSID_len, SSID_index, ssidData};
    payload[0] = SSID_len;
    payload[1] = SSID_index;
    for (int i = 0 ; i < ssidData.length; i++) {
        NSData *idata = [ssidData subdataWithRange:NSMakeRange(i, 1)];
        payload[i +2] =((Byte*)[idata bytes])[0];
    }
    
    int sum = [KDSBleAssistant sumOfDataThroughoutBytes:[[NSData alloc] initWithBytes:payload length:16]];
    self.tsn++;
    unsigned char* bytes = (unsigned char*)malloc(20);
    
    bytes[0] = 0;bytes[1] = self.tsn; bytes[2] = sum; bytes[3] = cmd;
    memcpy(bytes + 4, payload, 16);
    NSData * sendData = [[NSData alloc] initWithBytesNoCopy:bytes length:20];
    if (self.connectedPeripheral)
    {///设备已经连接且要写入特征
       // CBCharacteristicWriteWithoutResponse  type0 需要回复  不需要回复
        NSInteger   typenum  =0;
        if ([self.writeCharacteristic.UUID.UUIDString isEqualToString:kSmartHangerUUID]) {
            typenum = 1;
        }
        [self.connectedPeripheral writeValue:sendData forCharacteristic:self.writeCharacteristic type:typenum];
        //
        NSLog(@"zhu=Wi-Fi锁发送ssid或者密码到模的特征值==%@",self.writeCharacteristic);
        NSLog(@"Wi-Fi锁发送ssid或者密码到模块的数据：%@,蓝牙地址：%@",sendData,self.connectedPeripheral);
    }
}

@end
