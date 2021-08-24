//
//  KDSOADVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/5/15.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSOADVC.h"
#import "KDSCircleProgress.h"
#import <TIOAD.h>
#import "MBProgressHUD+MJ.h"
#import "KDSBreakpointDownload.h"
#import "NSTimer+KDSBlock.h"
#import "KDSHttpManager+Ble.h"


// 获取Documents目录路径
#define PATHDOCUMNT  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]

@interface KDSOADVC ()<TIOADClientProgressDelegate,KDSBluetoothToolDelegate,BreakpointDownloadDelegate>

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
@property (weak, nonatomic) IBOutlet UIImageView *lineimg1;
///进入升级状态、正在升级之间
@property (weak, nonatomic) IBOutlet UIImageView *lineimg2;
///正在升级、完成之间
@property (weak, nonatomic) IBOutlet UIImageView *lineimg3;
/// 蓝牙NSUUID
@property (nonatomic, copy)NSUUID *peripheralWithIdentifier;
/// 进度（值范围0.0~1.0，默认0.0）
@property (nonatomic, assign)CGFloat progress;
@property (nonatomic, strong)TIOADToadImageReader *oadImage;
@property (nonatomic, strong)TIOADToadImageReader * protorocolOADImage;
@property (nonatomic, strong)TIOADClient *client;
@property (nonatomic, strong)TIOADClient *protocolClient;
//协议栈升级是否成功YES、NO
@property (nonatomic, assign)BOOL protocolIsSuccess;


@end

@implementation KDSOADVC

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
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:BluetoothProtocolStack];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:BluetoothBin];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopOTA:) name:@"OTAStateNotify" object:nil];
    
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
    self.startUpgradingBtn.layer.masksToBounds = YES;
    self.startUpgradingBtn.layer.cornerRadius = 22;
    [KDSBreakpointDownload manager].delegate = self;
    self.protocolIsSuccess = NO;
    //下载进度 通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadEventNotification:) name:KDSBreakpointDownloadEventNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkReachabilityStatusDidChange:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
}

-(void)startOADProcess{
    
    KDSLog(@"--{Kaadas}--开始DFU传镜像文件");
    if (!_lineimg2.highlighted) {
        return;
    }
    
    //判断特征值FFD0是否存在
    if (self.lock.bleTool.connectedPeripheral.state == CBPeripheralStateConnected) {
        //获取固件文件名
        NSString *fileName = [[NSUserDefaults standardUserDefaults] objectForKey:BluetoothBin] ;
        NSString * protocolFileName = [[NSUserDefaults standardUserDefaults] objectForKey:BluetoothProtocolStack];
        // 获取Documents目录路径
        NSString *docDir = PATHDOCUMNT;
        // response.suggestedFilename ： 建议使用的文件名，一般跟服务器端的文件名一致
        NSString *file = [docDir stringByAppendingPathComponent:fileName];
        NSString *protocolFile = [docDir stringByAppendingPathComponent:protocolFileName];
        // 创建NSFileManager
        NSFileManager *fileManager = [NSFileManager defaultManager];
        ///进入OTA升级流程
        KDSLog(@"--00--00--file==%@==fileName====%@===fileManager:==%@",file,fileName,fileManager);
        if (self.protocolStackUrl.length >0 && !self.protocolIsSuccess) {

            if ( protocolFileName == nil || protocolFileName == NULL || [protocolFileName isKindOfClass:[NSNull class]]  || [[protocolFileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
                ///没有对应的镜像文件
                [MBProgressHUD showError:Localized(@"没有镜像文件")];
                return ;
            }
            self.protorocolOADImage = [[TIOADToadImageReader alloc] initWithImageData:[NSData dataWithContentsOfFile:protocolFile] fileName:protocolFileName];
            NSLog(@"--00--00--protorocolOADImage==%@",self.protorocolOADImage);
            self.protocolClient = [[TIOADClient alloc]  initWithPeripheral:self.lock.bleTool.connectedPeripheral andImageData:self.protorocolOADImage andDelegate:self];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self.protocolClient startOAD];
            });
        }else{
            if ( fileName == nil || fileName == NULL || [fileName isKindOfClass:[NSNull class]]  || [[fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
                ///没有对应的镜像文件
                [MBProgressHUD showError:Localized(@"没有镜像文件")];
                return ;
            }
            self.oadImage = [[TIOADToadImageReader alloc] initWithImageData:[NSData dataWithContentsOfFile:file] fileName:fileName];
            NSLog(@"--00--00--oadImage==%@",self.oadImage);
            self.client = [[TIOADClient alloc]  initWithPeripheral:self.lock.bleTool.connectedPeripheral andImageData:self.oadImage andDelegate:self];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
                [self.client startOAD];
            });
        }
        
    }else{
        [self connectBLE];
    }
}

///连接蓝牙
-(void)connectBLE{
    NSLog(@"--00--00--连接蓝牙=%@",self.lock.bleTool.connectedPeripheral);
    [self.lock.bleTool.centralManager connectPeripheral:self.lock.bleTool.connectedPeripheral options:nil];
}
///进入OTA升级流程
-(void)OTAProcess{
    
    NSLog(@"--00--00--resetOAD---characteristic");
    
    if (self.lock.bleTool.connectedPeripheral) {
        [self.lock.bleTool resetOAD:self.lock.bleTool.connectedPeripheral];
    }else{
        [MBProgressHUD showError:Localized(@"bleNotConnect")];
        _startUpgradingBtn.enabled = YES;
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    _icon2Img.highlighted = YES;
}

#pragma mark BreakpointDownloadDelegate
//下载成功
-(void)breakpointDownloadDone{
    self.lineimg1.highlighted = YES;
    KDSLog(@"--{Kaadas}--下载bin文件成功");
    //重连
    if (self.lock.bleTool.connectedPeripheral) {
        [self.lock.bleTool.centralManager connectPeripheral:self.lock.bleTool.connectedPeripheral options:nil];
    }else{
        [MBProgressHUD showError:Localized(@"bleNotConnect")];
        self.startUpgradingBtn.enabled = YES;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - OTA Progress Animation

-(void)otaFail:(NSString *)cause{
    
    NSString *softwareRev = [self parseBluetoothVersion];

    [[KDSHttpManager sharedManager] UpdateResultsBleOTAWithSerialNumber:self.lock.device.deviceSN withCustomer:1 withVersion:softwareRev withResultCode:[NSString stringWithFormat:@"%@--IOS--%@",@"升级失败",cause] withDevNum:1 success:^{
        
    } error:^(NSError * _Nonnull error) {
        

    } failure:^(NSError * _Nonnull error) {
        
    }];

    UIAlertController *OTAView = [UIAlertController alertControllerWithTitle:Localized(@"升级失败")message:Localized(@"锁OTA升级失败，请重试？")preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    [OTAView addAction:defaultAction];
    ///提示用户是否需要OTA升级。
    [self presentViewController:OTAView animated:YES completion:nil];
    
}

#pragma mark - 控件等事件方法。
- (IBAction)startUpgrading:(id)sender {
    KDSLog(@"--{Kaadas}--点击开始升级");
    //禁止再点击升级
    _startUpgradingBtn.enabled = NO;
    self.progressView.showOTAStateText = YES;
    self.progressView.showOTAPromptText = YES;
    if (self.lock.bleTool.isBinding){
        //鉴权完成,检查bin文件
        [self checkBinWithUpdateURL];
    }
}

///检测固件并下载
-(void)checkBinWithUpdateURL{
    //获取固件文件名
    NSString *fileName = [[NSUserDefaults standardUserDefaults] objectForKey:BluetoothBin] ;
    //     获取Documents目录路径
    NSString *docDir = PATHDOCUMNT;
    //    文件名，一般跟服务器端的文件名一致
    NSString *file = [docDir stringByAppendingPathComponent:fileName];
    // 创建NSFileManager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    KDSLog(@"--00--00--file==%@==fileName====%@===fileManager:==%@",file,fileName,fileManager);
    [self startDownloadWithUpdateURL];
    
}

-(void)startDownloadWithUpdateURL{
    
    _icon1Img.highlighted = YES;
    if (self.protocolStackUrl.length >0) {
 
            [[KDSBreakpointDownload manager] startDownloadWithURL:self.protocolStackUrl fromWhere:@"fromStackOAD"];

            // 追加任务
            [[KDSBreakpointDownload manager] startDownloadWithURL:self.url fromWhere:@"fromSoftWareOAD"];
 
    }else{
        
        [[KDSBreakpointDownload manager] startDownloadWithURL:self.url fromWhere:@"fromSoftWareOAD"];
    }
}

#pragma mark - TIOADClientProgressDelegate
-(void)client:(TIOADClient *)client oadProgressUpdated:(TIOADClientProgressValues_t)progress {
    
    self.progress = (float)progress.currentBlock/(float)progress.totalBlocks;
    ///DFU传输镜像文件，从进度50%开始
    if (self.protocolStackUrl.length >0) {
        if ([client isEqual:self.protocolClient]) {
            self.progressView.progress = 0.5+self.progress/4;
        }if ([client isEqual:self.client]) {
            self.progressView.progress = 0.75+self.progress/4;
        }
        
    }else{
        self.progressView.progress = 0.5+self.progress/2;
    }
    
    //蓝色
    self.progressView.pathFillColor = [UIColor colorWithRed:28/255.0 green:143/255.0 blue:252/255.0 alpha:1];
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
    
}
-(void)client:(TIOADClient *)client oadProcessStateChanged:(TIOADClientState_t)state error:(NSError *)error {
    NSLog(@"State changed : %d",(int)state);
    NSLog(@"Error: %@",error);
    //状态
    NSString * startStr = [TIOADClient getStateStringFromState:state];
    //Feedback complete OK为代理返回的state代表升级完成
    if ([startStr isEqualToString:@"Feedback complete OK"]) {
        //升级完成
        NSString * protocolFileName = [[NSUserDefaults standardUserDefaults] objectForKey:BluetoothProtocolStack];
        NSString * fileName = [[NSUserDefaults standardUserDefaults] objectForKey:BluetoothBin];
        // 获取Documents目录路径
        NSString *docDir = PATHDOCUMNT;
        NSString *file = [docDir stringByAppendingPathComponent:fileName];
        NSString *protocolFile = [docDir stringByAppendingPathComponent:protocolFileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //判断文件是否存在
        if ([client isEqual:self.protocolClient]) {

        if([fileManager fileExistsAtPath:file]){
            //删除文件
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:BluetoothProtocolStack];
            self.protocolIsSuccess = YES;
            NSLog(@"协议栈升级成功");

                [client stopOAD];
            
        }
        }
        if ([client isEqual:self.client]) {
            if([fileManager fileExistsAtPath:protocolFile]){
                //删除文件
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:BluetoothBin];
                self.icon4Img.highlighted = YES;
                NSLog(@"固件升级成功");
                //提示用户OTA升级流程完成。
                [client stopOAD];
                [self showTipsView];
            }
        }
        
    }else if (state == tiOADClientOADServiceMissingOnPeripheral){
        UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:Localized(@"tiOADClientOADServiceMissingOnPeripheral") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        [alertVC addAction:ok];
        [self presentViewController:alertVC animated:YES completion:nil];
        
    }else if(state == tiOADClientHeaderFailed){
        
        UIAlertController *OTAComoleteView = [UIAlertController alertControllerWithTitle:Localized(@"tiOADClientHeaderFailed")message:nil preferredStyle:UIAlertControllerStyleAlert];
               
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                   ///OTA升级流程完成
            [self.navigationController popToRootViewControllerAnimated:YES];
                   
        }];
        [OTAComoleteView addAction:defaultAction];
        
        if (self.protocolStackUrl.length > 0) {
            if ([client isEqual:self.protocolClient] && self.protocolIsSuccess) {
                //提示用户OTA升级流程完成。
                [self presentViewController:OTAComoleteView animated:YES completion:nil];
            }
        }
        
    }else{
        //self.TIOADCurrentStatus.text = Localized(@"正在升级,请勿操作...");
        self.lineimg3.highlighted = YES;
        self.icon3Img.highlighted = YES;
    }
}

-(void)showTipsView
{
    NSString *softwareRev = [self parseBluetoothVersion];

    [[KDSHttpManager sharedManager] UpdateResultsBleOTAWithSerialNumber:self.lock.device.deviceSN withCustomer:1 withVersion:softwareRev withResultCode:@"锁OTA升级成功--IOS" withDevNum:1 success:^{
        
    } error:^(NSError * _Nonnull error) {
        

    } failure:^(NSError * _Nonnull error) {
        
    }];
    
    UIAlertController *OTAComoleteView = [UIAlertController alertControllerWithTitle:Localized(@"锁OTA升级成功")message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        if (self.lock.bleTool.connectedPeripheral) {
//            [self.lock.bleTool.centralManager cancelPeripheralConnection:self.lock.bleTool.connectedPeripheral];
            [self.lock.bleTool endConnectPeripheral:self.lock.bleTool.connectedPeripheral];
        }else{
            [MBProgressHUD showError:Localized(@"bleNotConnect")];
            _startUpgradingBtn.enabled = YES;
        }
        ///OTA升级流程完成
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }];
    [OTAComoleteView addAction:defaultAction];
    [self presentViewController:OTAComoleteView animated:YES completion:nil];
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
        // Fallback on earlier versions
        if (central.state != CBCentralManagerStatePoweredOn)
        {
            [MBProgressHUD showError:Localized(@"请打开手机蓝牙")];
        }
    }
}
///发现蓝牙设备
- (void)didDiscoverPeripheral:(CBPeripheral *)peripheral{
    KDSLog(@"--{Kaadas}--发现蓝牙设备");
    
}
///连接上蓝牙设备
- (void)didConnectPeripheral:(CBPeripheral *)peripheral{
    KDSLog(@"--{Kaadas}--连接上蓝牙设备");
    if (peripheral.identifier == self.lock.bleTool.connectedPeripheralWithIdentifier) {
        NSLog(@"--{Kaadas}--相等");
        if (self.lock.bleTool.isBinding&&_icon1Img.highlighted && self.lineimg1.highlighted) {
            NSLog(@"--{Kaadas}--鉴权完成和下载完成");
            [self OTAProcess];
        }
        if (self.lock.bleTool.isBinding&&_icon1Img.highlighted && self.lineimg1.highlighted && self.lineimg2.highlighted) {
            NSLog(@"--{Kaadas}--进入升级状态DFU");
            _lineimg2.highlighted = YES;
            self.countdown = 15;
            //做个超时15s，第3点没亮
            __weak typeof(self) weakSelf = self;
            NSTimer *timer = [NSTimer kdsScheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
                if (weakSelf.countdown < 0 || !weakSelf)
                {
                    [timer invalidate];
                    weakSelf.countdown = 15;
                    if(!_lineimg3.highlighted){
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
            _lineimg2.highlighted = YES;
        }
    }
    else{
        NSLog(@"--{Kaadas}--不相等");
    }
}
///断开连接蓝牙设备
- (void)didDisConnectPeripheral:(CBPeripheral *_Nonnull)peripheral{
    KDSLog(@"--{Kaadas}--断开蓝牙设备");
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive){//应用程序运行在前台,目前接收事件。
        if (_icon4Img.highlighted) {
            KDSLog(@"--{Kaadas}--升级完成完成状态图，开始搜索蓝牙%@",peripheral);
            return;
        }
        if (_icon2Img.highlighted) {
            KDSLog(@"--{Kaadas}--进入升级状态=%@",peripheral);
            //若不是升级完成则重连
            [self.lock.bleTool.centralManager connectPeripheral:peripheral options:nil];
            return;
        }
        if (_icon1Img.highlighted && _lineimg1.highlighted) {
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

///网络状态改变的通知。当网络不可用时，会将网关、猫眼和网关锁的状态设置为离线后发出通知KDSDeviceSyncNotification
- (void)networkReachabilityStatusDidChange:(NSNotification *)noti
{
    NSNumber *number = noti.userInfo[AFNetworkingReachabilityNotificationStatusItem];
    AFNetworkReachabilityStatus status = number.integerValue;
    switch (status)
    {
            
        case AFNetworkReachabilityStatusReachableViaWWAN://2G,3G,4G...
        case AFNetworkReachabilityStatusReachableViaWiFi://wifi网络
            if(_icon1Img.highlighted&&!_lineimg1.highlighted){
            // [[KDSBreakpointDownload manager] resume];//恢复下载
            }
            break;
        default://未识别的网络/不可达的网络
            if(_icon1Img.highlighted&&!_lineimg1.highlighted){
            //[[KDSBreakpointDownload manager] pause];//暂停下载
            }
            break;
    }
}

-(void)stopOTA:(NSNotification *)noti
{
    self.lock.bleTool.isBinding = NO;//断开蓝牙前，把标志位置为NO
    if (self.lock.bleTool.connectedPeripheral) {
//            [self.lock.bleTool.centralManager cancelPeripheralConnection: self.lock.bleTool.connectedPeripheral];
        [self.lock.bleTool endConnectPeripheral:self.lock.bleTool.connectedPeripheral];
    }
    
}

@end
