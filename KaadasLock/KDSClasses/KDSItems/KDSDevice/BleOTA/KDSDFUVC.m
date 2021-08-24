//
//  KDSDFUVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/5/15.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSDFUVC.h"
#import "KDSCircleProgress.h"
#import "BootLoaderServiceModel.h"
#import "KDSBreakpointDownload.h"
#import "MBProgressHUD+MJ.h"
#import "OTAFileParser.h"
#import "BootLoaderServiceModel.h"
#import "Utilities.h"
#import "NSTimer+KDSBlock.h"
#import "KDSHttpManager+Ble.h"

@interface KDSDFUVC ()<KDSBluetoothToolDelegate,BreakpointDownloadDelegate>
{
    BootLoaderServiceModel *bootloaderModel;
    
    NSMutableArray *currentRowDataArray;
    uint32_t currentRowDataAddress;
    uint32_t currentRowDataCRC32;
    
    BOOL isBootloaderCharacteristicFound, isWritingFile1;
    int currentRowNumber, currentIndex;
    int maxDataSize;
    
    NSArray *firmwareFileList, *fileRowDataArray;
    NSDictionary *fileHeaderDict;
    NSDictionary *appInfoDict;
    
}
///下载进度条view
@property (weak, nonatomic) IBOutlet KDSCircleProgress *progressView;
///开始升级按钮
@property (weak, nonatomic) IBOutlet UIButton *startUpgradingBtn;
///下载
@property (weak, nonatomic) IBOutlet UIImageView *icon1Img;
///进入升级状态
@property (weak, nonatomic) IBOutlet UIImageView *icon2Img;
///正在升级
@property (weak, nonatomic) IBOutlet UIImageView *icon3Img;
///完成
@property (weak, nonatomic) IBOutlet UIImageView *icon4Img;
///下载、进入升级状态之间
@property (weak, nonatomic) IBOutlet UIImageView *line1Img;
///进入升级状态、正在升级之间
@property (weak, nonatomic) IBOutlet UIImageView *line2Img;
///正在升级、完成之间
@property (weak, nonatomic) IBOutlet UIImageView *line3Img;


@end

@implementation KDSDFUVC
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //这儿禁侧滑返回手势。
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 50, 40);
        [btn setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
        [btn setContentEdgeInsets:UIEdgeInsetsMake(0, -40, 0, 0)];
        [btn addTarget:self action:@selector(navBackClick) forControlEvents:UIControlEventTouchUpInside];
        //设置返回按钮
        UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
        self.navigationItem.leftBarButtonItem = backBarButton;
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
}
    
-(void)navBackClick{
    KDSLog(@"--{Kaadas}--点击返回");
    if (_startUpgradingBtn.enabled) {
        self.lock.bleTool.isBinding = NO;//断开蓝牙前，把标志位置为NO
//        [self.lock.bleTool.centralManager cancelPeripheralConnection: self.lock.bleTool.connectedPeripheral];
        [self.lock.bleTool endConnectPeripheral:self.lock.bleTool.connectedPeripheral];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationTitleLabel.text = Localized(@"Lock OTA upgrade");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopOTA) name:@"OTAStateNotify" object:nil];
    //OTA前先断开蓝牙
    if (!_isBootLoadModel) {
        self.lock.bleTool.isBinding = NO;//断开蓝牙前，把标志位置为NO
//        [self.lock.bleTool.centralManager cancelPeripheralConnection: self.lock.bleTool.connectedPeripheral];
        [self.lock.bleTool endConnectPeripheral:self.lock.bleTool.connectedPeripheral];
    }
    ///改变开始角度
    self.progressView.startAngle = 140;
    ///改变减少角度
    self.progressView.reduceAngle = 100;
    ///改变线宽
    self.progressView.strokeWidth = 17;
    ///改变动画时长
    //self.progressView.duration = sender.value;
    ///是否显示圆点
    self.progressView.showPoint = NO;
    ///是否显示百分比进度文本
    self.progressView.showProgressText = YES;
    ///是否显示ota状态进度文本
    self.progressView.showOTAStateText = NO;
    ///是否显示提示文本
    self.progressView.showOTAPromptText = NO;
    ///进度是否从头开始
    self.progressView.increaseFromLast = YES;
    ///设置下载代理
    [KDSBreakpointDownload manager].delegate = self;
    //下载进度 通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadEventNotification:) name:KDSBreakpointDownloadEventNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkReachabilityStatusDidChange:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:BluetoothBinP6];
    
}

///网络状态改变的通知。当网络不可用时，会将网关、猫眼和网关锁的状态设置为离线后发出通知KDSDeviceSyncNotification
- (void)networkReachabilityStatusDidChange:(NSNotification *)noti
{
    NSNumber *number = noti.userInfo[AFNetworkingReachabilityNotificationStatusItem];
    AFNetworkReachabilityStatus status = number.integerValue;
    switch (status)
    {
        case AFNetworkReachabilityStatusReachableViaWWAN://2G,3G,4G...
        case AFNetworkReachabilityStatusReachableViaWiFi://wifi网络
            if(_icon1Img.highlighted&&!_line1Img.highlighted){
//                [[KDSBreakpointDownload manager] resume];//恢复下载
            }
            break;
        default://未识别的网络/不可达的网络
            if(_icon1Img.highlighted&&!_line1Img.highlighted){
//                [[KDSBreakpointDownload manager] pause];//暂停下载
            }
            break;
    }
}

-(void)stopOTA{
    self.lock.bleTool.isBinding = NO;//断开蓝牙前，把标志位置为NO
//    [self.lock.bleTool.centralManager cancelPeripheralConnection: self.lock.bleTool.connectedPeripheral];
    [self.lock.bleTool endConnectPeripheral:self.lock.bleTool.connectedPeripheral];

}
#pragma mark - 控件等事件方法。
- (IBAction)startUpgrading:(id)sender {
    KDSLog(@"--{Kaadas}--点击开始升级");
    //禁止再点击升级
    _startUpgradingBtn.enabled = NO;
    self.progressView.showOTAStateText = YES;
    self.progressView.showOTAPromptText = YES;
    if (self.lock.bleTool.isBinding) {
        //鉴权完成,检查bin文件
        [self checkBinWithUpdateURL];
    }else{
        //兼容锁鉴权慢的问题（S8C）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           NSLog(@"--{Kaadas}--_isBootLoadModel==%d",_isBootLoadModel);
            //已在bootload模式
            if (_isBootLoadModel) {
                //检查bin文件
                [self checkBinWithUpdateURL];
                return ;
            }
            if (self.lock.bleTool.isBinding) {
                //鉴权完成,检查bin文件
                [self checkBinWithUpdateURL];
            }else{
                //鉴权失败
                UIAlertController * OTAView = [UIAlertController alertControllerWithTitle:Localized(@"tips") message:Localized(@"鉴权超时") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                     [self.navigationController popViewControllerAnimated:YES];
                }];
                [OTAView addAction:defaultAction];
                if (OTAView) {
                    //提示用户是否需要OTA升级。
                    [self presentViewController:OTAView animated:YES completion:nil];
                }
            }
        });
    }
  
}

-(void)checkBinWithUpdateURL{
    //获取固件文件名
    NSString *fileName = [[NSUserDefaults standardUserDefaults] objectForKey:BluetoothBinP6] ;
//     获取Documents目录路径
    NSString *docDir = PATHDOCUMNT;
//    文件名，一般跟服务器端的文件名一致
    NSString *file = [docDir stringByAppendingPathComponent:fileName];
    // 创建NSFileManager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //本地未保存最新固件
    KDSLog(@"file:==%@==fileName:===%@=fileManager:==%@",file,fileName,fileManager);
     [self startDownloadWithUpdateURL];
     
}
-(void)startDownloadWithUpdateURL{
    _icon1Img.highlighted = YES;
    [[KDSBreakpointDownload manager] startDownloadWithURL:self.url fromWhere:@"fromDFU"];
}

#pragma mark BreakpointDownloadDelegate
///下载成功
-(void)breakpointDownloadDone{
    _line1Img.highlighted = YES;
    KDSLog(@"--{Kaadas}--下载bin文件成功");
    //重连
    if (self.lock.bleTool.connectedPeripheral) {
        [self.lock.bleTool.centralManager connectPeripheral:self.lock.bleTool.connectedPeripheral options:nil];
    }else{
        [MBProgressHUD showError:Localized(@"bleNotConnect")];
        _startUpgradingBtn.enabled = YES;
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
#pragma mark - KDSBluetoothDelegate

///检测手机蓝牙状态
- (void)discoverManagerDidUpdateState:(CBCentralManager *)central{
    KDSLog(@"--{Kaadas}--检测手机蓝牙状态");
    if (@available(iOS 10.0, *)) {
        if (central.state != CBManagerStatePoweredOn)
        {
            [MBProgressHUD showError:Localized(@"请打开手机蓝牙")];
        }
    } else {
        if (central.state != CBCentralManagerStatePoweredOn)
        {
            [MBProgressHUD showError:Localized(@"请打开手机蓝牙")];
        }
    }
}
////发现蓝牙设备
- (void)didDiscoverPeripheral:(CBPeripheral *)peripheral{
    KDSLog(@"--{Kaadas}--发现蓝牙设备");

}
///连接上蓝牙设备
- (void)didConnectPeripheral:(CBPeripheral *)peripheral{
    if (peripheral.identifier == self.lock.bleTool.connectedPeripheralWithIdentifier) {
        if (self.lock.bleTool.isBinding&&_icon1Img.highlighted&&_line1Img.highlighted) {
            NSLog(@"--{Kaadas}--鉴权完成和下载完成");
            [self DFUProcess];
        }
        if (self.lock.bleTool.isBinding&&_icon1Img.highlighted&&_line1Img.highlighted&&_icon2Img.highlighted && _line3Img.highlighted) {
            NSLog(@"--{Kaadas}--进入升级状态DFU");
            _line2Img.highlighted = YES;
            self.countdown = 15;
            //做个超时15s，第3点没亮
            __weak typeof(self) weakSelf = self;
            NSTimer *timer = [NSTimer kdsScheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
                if (weakSelf.countdown < 0 || !weakSelf)
                {
                    [timer invalidate];
                    weakSelf.countdown = 15;
                    if(!_line3Img.highlighted){
                        [self otaFail:@"15s超时"];
                    }
                    return;
                }
                weakSelf.countdown--;
                NSLog(@"--{Kaadas}--countdown=%ld",(long)weakSelf.countdown);
            }];
            [timer fire];
        }
        if (_isBootLoadModel) {
            _icon2Img.highlighted = YES;
            _line2Img.highlighted = YES;
        }
    }else{
        NSLog(@"--{Kaadas}--不相等");
    }
}
///断开连接蓝牙设备
- (void)didDisConnectPeripheral:(CBPeripheral *_Nonnull)peripheral{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive){//应用程序运行在前台,目前接收事件。
        if (_icon3Img.highlighted && _icon4Img.highlighted) {
            KDSLog(@"--{Kaadas}--升级完成完成状态图，开始搜索蓝牙%@",peripheral);
            [MBProgressHUD showError:Localized(@"bleNotConnect")];
            _startUpgradingBtn.enabled = YES;
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        if (_icon2Img.highlighted) {
            KDSLog(@"--{Kaadas}--进入升级状态=%@",peripheral);
            //若不是升级完成则重连
                [self.lock.bleTool.centralManager connectPeripheral:peripheral options:nil];
            return;
        }
        if (_icon1Img.highlighted && _line1Img.highlighted) {
            KDSLog(@"--{Kaadas}--准备进入升级状态=%@",peripheral);
            [self.lock.bleTool.centralManager connectPeripheral:peripheral options:nil];
            return;
        }
    }else {
         if (_icon1Img.highlighted) {
             //已开始升级
             [self.navigationController popViewControllerAnimated:YES];
         }
    }
}
///进入DFU升级流程
-(void)DFUProcess{
    KDSLog(@"--{Kaadas}--resetDFU");
    if (self.lock.bleTool.connectedPeripheral) {
        [self.lock.bleTool resetDFU:self.lock.bleTool.connectedPeripheral];
    }else{
        [MBProgressHUD showError:Localized(@"bleNotConnect")];
        _startUpgradingBtn.enabled = YES;
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    _icon2Img.highlighted = YES;
}
-(void)startDFUProcess{
    KDSLog(@"--{Kaadas}--开始DFU传镜像文件");
    if (!_line2Img.highlighted) {
        return;
    }
    _icon3Img.highlighted = YES;
    //获取固件文件名
    NSString *fileName = [[NSUserDefaults standardUserDefaults] objectForKey:BluetoothBinP6] ;
    // 获取Documents目录路径
    NSString *docDir = PATHDOCUMNT;
    //文件名，一般跟服务器端的文件名一致
    NSString *file = [docDir stringByAppendingPathComponent:fileName];
    // 创建NSFileManager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    KDSLog(@"file:==%@==fileName:===%@=fileManager:==%@",file,fileName,fileManager);
    if (self.lock.bleTool.connectedPeripheral.state == CBPeripheralStateConnected) {
        OTAFileParser *fileParser = [OTAFileParser new];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            ///开始解析固件
            [fileParser parseFirmwareFileWithName_v1:fileName path:docDir onFinish:^(NSMutableDictionary *header, NSDictionary *appInfo, NSArray *rowData, NSError *error) {
                if(error) {
                    NSLog(@"--{Kaadas}--OTAError");
                    [MBProgressHUD showError:error.localizedDescription];
                    
                } else if (header && rowData) {
                    NSLog(@"--{Kaadas}--header && rowData");
                    ///固件头，App检验固件？
                    NSLog(@"--{Kaadas}--header==%@",header);
                    ///固件大小和写flash地址
                    NSLog(@"--{Kaadas}--appInfo==%@",appInfo);
                    ///Address行地址，CRC32：行检验值，DataArrays：包数据
                    NSLog(@"--{Kaadas}--rowData==%@",rowData);
                    
                    fileHeaderDict = header;
                    appInfoDict = appInfo;
                    fileRowDataArray = rowData;
                    [self initializeFileTransfer_v1];
                }
            }];
        });
    }
}
#pragma mark - OTA Upgrade
///初始化bootloaderModel模型
-(void) initServiceModel
{
    if (!bootloaderModel)
    {
        //bootloaderModel = [[BootLoaderServiceModel alloc] initWithPeripheral:_dev.peripheral];
        bootloaderModel = [[BootLoaderServiceModel alloc] init];
        
    }
    
    [bootloaderModel discoverService:self.lock.bleTool.connectedPeripheral.services  peripheral:self.lock.bleTool.connectedPeripheral CharacteristicsWithCompletionHandler:^(BOOL success, NSError *error)
     {
         if (success)
         {
             NSLog(@"--{Kaadas}--发现DFU特征");
             isBootloaderCharacteristicFound = YES;
             if (bootloaderModel.isWriteWithoutResponseSupported)
             {
                 maxDataSize = WRITE_NO_RESP_MAX_DATA_SIZE;
             }
             else
             {
                 maxDataSize = WRITE_WITH_RESP_MAX_DATA_SIZE;
             }
         }
         else{
             NSLog(@"--{Kaadas}--没发现DFU特征");
         }
     }];
}
///开始文件传输的方法（cyacd2）
-(void) initializeFileTransfer_v1 {
    ///初始化BootLoaderServiceModel
    [self initServiceModel];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (isBootloaderCharacteristicFound) {
            currentIndex = 0;
            [self registerForBootloaderCharacteristicNotifications_v1];
            
            bootloaderModel.fileVersion = [[fileHeaderDict objectForKey:FILE_VERSION] integerValue];
            
            // Set checksum type
            if ([[fileHeaderDict objectForKey:CHECKSUM_TYPE] integerValue]) {
                [bootloaderModel setCheckSumType:CRC_16];
            } else {
                [bootloaderModel setCheckSumType:CHECK_SUM];
            }
            
            [self sendEnterBootloaderCmd];

        }else{
            [self initServiceModel];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                if (isBootloaderCharacteristicFound) {
                    currentIndex = 0;
                    [self registerForBootloaderCharacteristicNotifications_v1];

                    bootloaderModel.fileVersion = [[fileHeaderDict objectForKey:FILE_VERSION] integerValue];

                    // Set checksum type
                    if ([[fileHeaderDict objectForKey:CHECKSUM_TYPE] integerValue]) {
                        [bootloaderModel setCheckSumType:CRC_16];
                    }else{
                        [bootloaderModel setCheckSumType:CHECK_SUM];
                    }
                    [self sendEnterBootloaderCmd];

                }else{
                    [self otaFail:@"is not Found BootloaderCharacteristic"];
                }
            });
        }
    });

}

///处理特征值更新的方法
-(void) registerForBootloaderCharacteristicNotifications_v1
{
    [bootloaderModel enableNotificationForBootloaderCharacteristicAndSetNotificationHandler:^(NSError *error, id command, unsigned char otaError)
     {
         if (nil == error)
         {
             NSLog(@"--{Kaadas}--command=%@",command);
             NSLog(@"--{Kaadas}--otaError=%c",otaError);
             [self handleResponseForCommand_v1:command error:otaError];
         }
         else{
             NSLog(@"--{Kaadas}--error=%@",error);
             NSLog(@"--{Kaadas}--error.localizedDescription=%@",error.localizedDescription);
         }
     }];
}
- (void)sendEnterBootloaderCmd {
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[fileHeaderDict objectForKey:PRODUCT_ID] forKey:PRODUCT_ID];
    NSData *data = [bootloaderModel createPacketWithCommandCode_v1:ENTER_BOOTLOADER dataLength:4 data:dataDict];
    [bootloaderModel writeCharacteristicValueWithData:data command:ENTER_BOOTLOADER];
}

///方法处理来自设备的响应的文件传输
-(void) handleResponseForCommand_v1:(id)command error:(unsigned char)error {
    if (SUCCESS == error) {
        if ([command isEqual:@(ENTER_BOOTLOADER)]) {
            // Compare Silicon ID and Silicon Rev string
            if ([[[fileHeaderDict objectForKey:SILICON_ID] lowercaseString] isEqualToString:bootloaderModel.siliconIDString] && [[fileHeaderDict objectForKey:SILICON_REV] isEqualToString:bootloaderModel.siliconRevString]) {
                /* Send SET_APP_METADATA command */
                uint8_t appID = [[fileHeaderDict objectForKey:APP_ID] unsignedCharValue];
                uint32_t appStart = 0xFFFFFFFF;
                uint32_t appSize = 0;
                if (appInfoDict) {
                    appStart = [appInfoDict[APPINFO_APP_START] unsignedIntValue];
                    appSize = [appInfoDict[APPINFO_APP_SIZE] unsignedIntValue];
                } else {
                    for (NSDictionary *rowDict in fileRowDataArray) {
                        if (RowTypeData == [[rowDict objectForKey:ROW_TYPE] unsignedCharValue]) {
                            uint32_t addr = [[rowDict objectForKey:ADDRESS] unsignedIntValue];
                            if (addr < appStart) {
                                appStart = addr;
                            }
                            appSize += [[rowDict objectForKey:DATA_LENGTH] unsignedIntValue];
                        }
                    }
                }
                NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedChar:appID], APP_ID, [NSNumber numberWithUnsignedInt:appStart], APP_META_APP_START, [NSNumber numberWithUnsignedInt:appSize], APP_META_APP_SIZE, nil];
                NSData *data = [bootloaderModel createPacketWithCommandCode_v1:SET_APP_METADATA dataLength:9 data:dataDict];
                [bootloaderModel writeCharacteristicValueWithData:data command:SET_APP_METADATA];
            }else {
                [self otaFail:@"fileHeaderDict has no SILICON_ID"];
            }
        }else if ([command isEqual:@(SET_APP_METADATA)]) {
            NSDictionary *rowDataDict = [fileRowDataArray objectAtIndex:currentIndex];
            if (RowTypeEiv == [[rowDataDict objectForKey:ROW_TYPE] unsignedCharValue]) {
                /* Send SET_EIV command */
                NSArray *dataArr = [rowDataDict objectForKey:DATA_ARRAY];
                NSDictionary * dataDict = [NSDictionary dictionaryWithObject:dataArr forKey:ROW_DATA];
                NSData *data = [bootloaderModel createPacketWithCommandCode_v1:SET_EIV dataLength:[dataArr count] data:dataDict];
                [bootloaderModel writeCharacteristicValueWithData:data command:SET_EIV];
            } else {
                //Process data row
                [self startProgrammingDataRowAtIndex_v1:currentIndex];
            }
        } else if ([command isEqual:@(SEND_DATA)]) {
            /* Send SEND_DATA/PROGRAM_DATA commands */
            if (bootloaderModel.isSendRowDataSuccess) {
                [self programDataRowAtIndex_v1:currentIndex];
            } else {
                [self otaFail:@"SendRowData is not Success"];
//                [Utilities alertWithTitle:APP_NAME message:LOCALIZEDSTRING(@"OTASendDataCommandFailed")];
            }
        } else if ([command isEqual:@(PROGRAM_DATA)] || [command isEqual:@(SET_EIV)]) {
            // Update progress and proceed to next row
            if (bootloaderModel.isProgramRowDataSuccess) {
                currentIndex++;
//                self.Psoc6DFUCurrentStatus.text = Localized(@"正在升级,请勿操作...");
                _line3Img.highlighted = YES;

                float percentage = (float) currentIndex/fileRowDataArray.count;
                NSLog(@"--{Kaadas}--currentIndex==%d",currentIndex);
                NSLog(@"--{Kaadas}--fileRowDataArray.count==%lu",(unsigned long)fileRowDataArray.count);
                ///DFU传输镜像文件，从进度50%开始
                self.progressView.progress = 0.5+percentage/2;
                //蓝色
                self.progressView.pathFillColor = [UIColor colorWithRed:28/255.0 green:143/255.0 blue:252/255.0 alpha:1];
                [UIView animateWithDuration:0.5 animations:^{
                    [self.view layoutIfNeeded];
                }];
                
                if (currentIndex < fileRowDataArray.count) {
                    NSDictionary * rowDataDict = [fileRowDataArray objectAtIndex:currentIndex];
                    if (RowTypeEiv == [[rowDataDict objectForKey:ROW_TYPE] unsignedCharValue]) {
                        /* Send SET_EIV command */
                        NSArray * dataArr = [rowDataDict objectForKey:DATA_ARRAY];
                        NSDictionary * dataDict = [NSDictionary dictionaryWithObject:dataArr forKey:ROW_DATA];
                        NSData * data = [bootloaderModel createPacketWithCommandCode_v1:SET_EIV dataLength:[dataArr count] data:dataDict];
                        [bootloaderModel writeCharacteristicValueWithData:data command:SET_EIV];
                    } else {
                        //Process data row (program next row)
                        [self startProgrammingDataRowAtIndex_v1:currentIndex];
                    }
                } else {
                    /* Send VERIFY_APP command */
                    uint8_t appID = [[fileHeaderDict objectForKey:APP_ID] unsignedCharValue];
                    NSDictionary * dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:appID] forKey:APP_ID];
                    NSData * data = [bootloaderModel createPacketWithCommandCode_v1:VERIFY_APP dataLength:1 data:dataDict];
                    [bootloaderModel writeCharacteristicValueWithData:data command:VERIFY_APP];
                }
            } else {
                [self otaFail:@"ProgramRowData is not Success"];
            }
        } else if ([command isEqual:@(VERIFY_APP)]) {
            if (bootloaderModel.isAppValid) {
                
                ///升级完成
                _icon4Img.highlighted = YES;
                self.lock.bleTool.isBinding = NO;//把标志位置为NO

                /* Send EXIT_BOOTLOADER command */
                NSData *exitBootloaderCommandData = [bootloaderModel createPacketWithCommandCode_v1:EXIT_BOOTLOADER dataLength:0 data:nil];
                [bootloaderModel writeCharacteristicValueWithData:exitBootloaderCommandData command:EXIT_BOOTLOADER];
                //获取固件文件名
                NSString *fileName = [[NSUserDefaults standardUserDefaults] objectForKey:BluetoothBinP6] ;
                // 获取Documents目录路径
                NSString *docDir = PATHDOCUMNT;
                // response.suggestedFilename ： 建议使用的文件名，一般跟服务器端的文件名一致
                NSString *file = [docDir stringByAppendingPathComponent:fileName];
                // 创建NSFileManager
                NSFileManager *fileManager = [NSFileManager defaultManager];
                //判断文件是否存在
                if([fileManager fileExistsAtPath:file]){
                    //删除文件
                    [fileManager removeItemAtPath:file error:nil];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:BluetoothBinP6];
                }
                NSString *softwareRev = [self parseBluetoothVersion];

                [[KDSHttpManager sharedManager] UpdateResultsBleOTAWithSerialNumber:self.lock.device.deviceSN withCustomer:1 withVersion:softwareRev withResultCode:@"锁OTA升级成功--IOS" withDevNum:1 success:^{
                    
                } error:^(NSError * _Nonnull error) {
                    

                } failure:^(NSError * _Nonnull error) {
                    
                }];
                UIAlertController *OTAComoleteView = [UIAlertController alertControllerWithTitle:Localized(@"锁OTA升级成功")message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    if (self.lock.bleTool.connectedPeripheral) {
//                        [self.lock.bleTool.centralManager cancelPeripheralConnection:self.lock.bleTool.connectedPeripheral];
                        [self.lock.bleTool endConnectPeripheral:self.lock.bleTool.connectedPeripheral];
                    }else{
                        [MBProgressHUD showError:Localized(@"bleNotConnect")];
                        _startUpgradingBtn.enabled = YES;
                        NSLog(@"ota升级后锁信息：%@---地址：%@",self.lock.bleTool.connectedPeripheral.serialNumber,self.lock.device.deviceSN);
                    }
                    ///OTA升级流程完成
                    [self.navigationController popViewControllerAnimated:YES];
                                                                                             
                }];
                [OTAComoleteView addAction:defaultAction];
                //提示用户OTA升级流程完成。
                [self presentViewController:OTAComoleteView animated:YES completion:nil];
            }else {
                [self otaFail:@"App is not Valid"];
                currentIndex = 0;
            }
        }
    }else{
        [self otaFail:@"error"];
    }
}
/**
 解析蓝牙版本为存数字的字符串以便比较大小
 @return 蓝牙版本
 */
-(NSString *)parseBluetoothVersion{
    //截取出字符串后带了\u0000
//    NSString *bleVesion = [self.lock.bleTool.connectedPeripheral.softwareVer componentsSeparatedByString:@"-"].lastObject;
    NSString *bleVesion ;
    if (!self.lock.bleTool.connectedPeripheral.softwareVer.length) {
        bleVesion = [self.lock.device.softwareVersion componentsSeparatedByString:@"-"].firstObject;
    }else{
        bleVesion = [self.lock.bleTool.connectedPeripheral.softwareVer componentsSeparatedByString:@"-"].firstObject;
    }
    //去掉NSString中的\u0000
    if (bleVesion.length > 9) {
        //挽救K9S、V6、V7第一版本的字符串带\u0000错误
        bleVesion = [bleVesion substringToIndex:9];
    }
//    //去掉NSString中的V
//    bleVesion = [bleVesion stringByReplacingOccurrencesOfString:@"V" withString:@""];
//    //带T为测试固件
//    bleVesion = [bleVesion stringByReplacingOccurrencesOfString:@"T" withString:@""];
    return bleVesion;
}
///方法将固件文件数据写入设备
-(void) startProgrammingDataRowAtIndex_v1:(int) index
{
    NSDictionary *rowDataDict = [fileRowDataArray objectAtIndex:index];
    //Write data using SEND_DATA/PROGRAM_ROW commands
    currentRowDataArray = [[rowDataDict objectForKey:DATA_ARRAY] mutableCopy];
    currentRowDataAddress = [[rowDataDict objectForKey:ADDRESS] unsignedIntValue];
    currentRowDataCRC32 = [[rowDataDict objectForKey:CRC_32] unsignedIntValue];
    
    [self programDataRowAtIndex_v1:index];
}
///方法将数据写入行。
-(void) programDataRowAtIndex_v1:(int)index
{
    if (currentRowDataArray.count > maxDataSize){
        NSDictionary * dataDict = [NSDictionary dictionaryWithObjectsAndKeys:[currentRowDataArray subarrayWithRange:NSMakeRange(0, maxDataSize)], ROW_DATA, nil];
        NSData * data = [bootloaderModel createPacketWithCommandCode_v1:SEND_DATA dataLength:maxDataSize data:dataDict];
        [bootloaderModel writeCharacteristicValueWithData:data command:SEND_DATA];
        [currentRowDataArray removeObjectsInRange:NSMakeRange(0, maxDataSize)];
    }else{
        //Last packet data
        NSDictionary * dataDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:currentRowDataAddress], ADDRESS, [NSNumber numberWithUnsignedInt:currentRowDataCRC32], CRC_32, currentRowDataArray, ROW_DATA, nil];
        NSData * data = [bootloaderModel createPacketWithCommandCode_v1:PROGRAM_DATA dataLength:(currentRowDataArray.count + 8) data:dataDict];
        [bootloaderModel writeCharacteristicValueWithData:data command:PROGRAM_DATA];
    }
}

///升级失败。
-(void)otaFail:(NSString *)cause{
    
    NSString *softwareRev = [self parseBluetoothVersion];

    [[KDSHttpManager sharedManager] UpdateResultsBleOTAWithSerialNumber:self.lock.device.deviceSN withCustomer:1 withVersion:softwareRev withResultCode:[NSString stringWithFormat:@"%@--IOS--%@",@"升级失败",cause] withDevNum:1 success:^{
        
    } error:^(NSError * _Nonnull error) {
        

    } failure:^(NSError * _Nonnull error) {
        
    }];
    
    UIAlertController * OTAView = [UIAlertController alertControllerWithTitle:Localized(@"升级失败") message:Localized(@"锁OTA升级失败，请重试？") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
         [self.navigationController popViewControllerAnimated:YES];
    }];
    [OTAView addAction:defaultAction];
     //提示用户是否需要OTA升级。
    [self presentViewController:OTAView animated:YES completion:nil];
}
#pragma mark - 通知相关方法。
///下载进度事件通知。
- (void)downloadEventNotification:(NSNotification *)noti
{
    NSString *progress = noti.userInfo[@"progress"];
    KDSLog(@"--{Kaadas}--progress==%f",progress.doubleValue);
    ///DFU传输镜像文件，从进度0%开始,50%结束
    self.progressView.progress = progress.doubleValue/2;
    //蓝色
    self.progressView.pathFillColor = [UIColor colorWithRed:28/255.0 green:143/255.0 blue:252/255.0 alpha:1];

}

@end
