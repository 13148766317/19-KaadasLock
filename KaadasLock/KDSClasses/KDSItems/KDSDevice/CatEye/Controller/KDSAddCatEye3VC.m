//
//  KDSAddCatEye3VC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/10.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSAddCatEye3VC.h"
#import "KDSAddCatEye4VC.h"
#import "MBProgressHUD+MJ.h"
#import "KDSMQTT.h"
#import "NetworkManagerByReachability.h"
#import "hisi_util.h"
#import "MBProgressHUD+MJ.h"
#import "ProcessMultiCastLinkData.h"
#import "KDSCountdown.h"
#import "GCDAsyncSocket.h"
#import "CGlobal.h"
#import "KDSMQTT.h"
#import "KDSFTIndicator.h"
#import "KDSCateyeHelpVC.h"



#define allowCateyeJoinTimeOut 120
#define               WELCOME_MSG  0
#define               READ_TIMEOUT 40.0

static const uint16_t hostPort = 0x3516;
static int TIMER_MULTICAST_TIMEOUT        = 60;//60s
//static int TIMER_APMODE_TIMEOUT           = 60;//60s

int        counterTime = 0;
static int ONLINE_PORT = 0x3516;

@interface KDSAddCatEye3VC ()

@property(nonatomic,readwrite,strong)ProcessMultiCastLinkData *multiCastLinkDataThread;
@property(nonatomic,assign)Boolean           multiCastButtonSending;
@property(nonatomic,readwrite,strong)WifiNetworkInfo  *myWifiNetworkInfo;
@property(nonatomic,readwrite,strong) NSTimer          *sendTimeOutTimer;
@property(nonatomic, strong) KDSCountdown *countdown;//允许入网倒计时定时器
@property(nonatomic) long nowTimeSp;
@property(nonatomic) long finalMinuteSp;
@property(nonatomic,strong)NSString  *minute_1;
@property(nonatomic,strong)NSString  *minute_2;
@property(nonatomic,strong)NSString  *second_1;
@property(nonatomic,strong)NSString  *second_2;
@property(strong, nonatomic)GCDAsyncSocket * serverSocket;
@property(strong, nonatomic)GCDAsyncSocket * clientSocket;
@property(nonatomic)BOOL  retry;//重新发送入网运行标志
///是否连接成功
@property(nonatomic,assign)BOOL isSuccess;

@property(nonatomic,strong) UIImageView * addZigBeeLocklogoImg;

@end

@implementation KDSAddCatEye3VC

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    self.navigationController.navigationBar.hidden = YES;
    
    if(_retry){
        
        [[KDSMQTTManager sharedManager] gw:self.gatewayModel setCateyeAccessEnable:YES withCateyeSN:self.deviceSN mac:self.deviceMac completion:^(NSError * _Nullable error, BOOL success) {
            if (success) {
                //重试，重新发送允许入网
                //发送允许猫眼入网消息
                [self countdownTime];
                //发送组播
                [self processMultiCastButtonEvent];
            }else{
                [MBProgressHUD showError:Localized(@"setFailed")];
            }
           
        }];
        CABasicAnimation *animation =  [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
        animation.fromValue = [NSNumber numberWithFloat:0.f];
        animation.toValue =  [NSNumber numberWithFloat: M_PI *2];
        animation.duration  = 1;
        animation.autoreverses = NO;
        animation.fillMode =kCAFillModeForwards;
        animation.repeatCount = MAXFLOAT; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
        [self.addZigBeeLocklogoImg.layer addAnimation:animation forKey:nil];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"addCatEye");
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [self setUI];
    _retry = NO;
    [self countdownTime];
    //发送组播
    [self processMultiCastButtonEvent];
    ///监听猫眼上线
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidJoinGateway:) name:KDSMQTTEventNotification object:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
//    self.navigationController.navigationBar.hidden = NO;
    //倒计时结束
    [self.countdown destoryTimer];
    //暂停组播
    [self processStopMultiCast];
    
}

-(void)setUI
{
    UIImageView * bgImg = [UIImageView new];
    bgImg.image = [UIImage imageNamed:@"loginBg"];
    [self.view addSubview:bgImg];
    [bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(0);
    }];
    ///添加猫眼的logo
    self.addZigBeeLocklogoImg = [UIImageView new];
    self.addZigBeeLocklogoImg.image = [UIImage imageNamed:@"添加ZigBee_添加猫眼_猫眼绑定-等待"];
    [self.view addSubview:self.addZigBeeLocklogoImg];
    [self.addZigBeeLocklogoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(130);
        make.top.mas_equalTo(self.view.mas_top).offset(kNavBarHeight+kStatusBarHeight+40);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    CABasicAnimation *animation =  [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
    animation.fromValue = [NSNumber numberWithFloat:0.f];
    animation.toValue =  [NSNumber numberWithFloat: M_PI *2];
    animation.duration  = 1;
    animation.autoreverses = NO;
    animation.fillMode =kCAFillModeForwards;
    animation.repeatCount = MAXFLOAT; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
    [self.addZigBeeLocklogoImg.layer addAnimation:animation forKey:nil];
    
    UIImageView * smallIconImg = [UIImageView new];
    smallIconImg.image = [UIImage imageNamed:@"添加ZigBee_添加猫眼_猫眼绑定-猫眼"];
    [self.view addSubview:smallIconImg];
    [smallIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(53);
        make.height.mas_equalTo(60);
        make.centerX.mas_equalTo(self.addZigBeeLocklogoImg.mas_centerX).offset(0);
        make.centerY.mas_equalTo(self.addZigBeeLocklogoImg.mas_centerY).offset(0);
    }];
    
    UILabel * tipMsgLabe = [UILabel new];
    tipMsgLabe.text = Localized(@"Connecting Cat's Eye");
    tipMsgLabe.font = [UIFont systemFontOfSize:17];
    tipMsgLabe.textColor = UIColor.whiteColor;
    tipMsgLabe.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipMsgLabe];
    [tipMsgLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(18);
        make.centerY.mas_equalTo(self.view.mas_centerY).offset(0);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    
    UILabel * detailLabe = [UILabel new];
    detailLabe.text = Localized(@"It takes about two minutes.");
    detailLabe.font = [UIFont systemFontOfSize:12];
    detailLabe.textColor = KDSRGBColor(170, 228, 255);
    detailLabe.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:detailLabe];
    [detailLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(14);
        make.top.mas_equalTo(tipMsgLabe.mas_bottom).offset(13);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];

}

-(void)processMultiCastButtonEvent{
    NSLog(@"Button clicked.组播模式");
    self.myWifiNetworkInfo = [[WifiNetworkInfo alloc]init];
    self.myWifiNetworkInfo.security = SECURITY_PSK;
    
    if(self.multiCastButtonSending != false)/*发送时，stop发送*/
    {
        [self processStopMultiCast];
        
        return;
    }
    self.multiCastButtonSending = true;
    /*add time out timer*/
    self.sendTimeOutTimer  = [NSTimer scheduledTimerWithTimeInterval:TIMER_MULTICAST_TIMEOUT target:self selector:@selector(multiCastTimerOutProcess) userInfo:nil repeats:NO];
    [self.myWifiNetworkInfo setSsid:self.gwSid];
    if((self.myWifiNetworkInfo.security==SECURITY_WEP) || (self.myWifiNetworkInfo.security==SECURITY_PSK))
    {
        /*get password*/
        NSString *password =self.wifiPwd;
        NSLog(@"Button clicked.password:%@",password);
        [self.myWifiNetworkInfo setPassword:password];
    }
    else
    {
        [self.myWifiNetworkInfo setPassword:@""];
    }
    [self.myWifiNetworkInfo setSecurity:self.myWifiNetworkInfo.security];
    [self.myWifiNetworkInfo setDeviceName:self.deviceId];
    [self.myWifiNetworkInfo setIp:[GLobalNetworkManagerByReachability getLocalIPAddress:@"en0"]];
    [self.myWifiNetworkInfo setPort:ONLINE_PORT];
    [self.myWifiNetworkInfo setOnlineProto:ONLINE_MSG_BY_TCP];
    
    /*构建数据包*/
    Boolean flag = [GLobalProcessMultiCastLinkData  constructMultiCastLinkMessageToSend:self.myWifiNetworkInfo];
    if(flag != true)
    {
        NSLog(@"fail to construct multicast link message");
        return;
    }
    /*创建线程监听上线消息*/
    [self recieveOnlineMessage];
    /*发送报文*/
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [GLobalProcessMultiCastLinkData  startSendMultiBroadcast:true:3516];
    });
    NSLog(@"finish processMultiCastButtonEvent");
    
}
-(void)recieveOnlineMessage{
    [self createServerSocket];
    /*tcp server end*/
}
-(void)createServerSocket
{
    NSLog(@"$tcp server createServerSocket thread = %@", [NSThread currentThread]);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    self.serverSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:queue];
    
    NSLog(@"$$$$$$createServerSocket,port:%d",hostPort);
    NSError * error = nil;
    [self.serverSocket setAutoDisconnectOnClosedReadStream:NO];
    [self.serverSocket acceptOnPort:hostPort error:&error];
    
    NSLog(@"createServerSocket,error:%@",error);
}
-(void)countdownTime{
    
    _countdown = [[KDSCountdown alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self getNowTimeSP:@"开始倒计时"];
}

//开始倒计时
- (void) getNowTimeSP: (NSString *) string {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"YYYY年MM月dd日HH:mm:ss"];
    
    //现在时间,你可以输出来看下是什么格式
    NSDate *datenow = [NSDate date];
    //----------将nsdate按formatter格式转成NSString
    NSString *currentTimeString_1 = [formatter stringFromDate:datenow];
    NSDate *applyTimeString_1 = [formatter dateFromString:currentTimeString_1];
    _nowTimeSp = (long long)[applyTimeString_1 timeIntervalSince1970];
    
    //
    if ([string isEqualToString:@"开始倒计时"]) {
        
        NSTimeInterval time = allowCateyeJoinTimeOut;//秒数
        NSDate *lastTwoHour = [datenow dateByAddingTimeInterval:time];
        NSString *currentTimeString_2 = [formatter stringFromDate:lastTwoHour];
        NSDate *applyTimeString_2 = [formatter dateFromString:currentTimeString_2];
        _finalMinuteSp = (long)[applyTimeString_2 timeIntervalSince1970];
        
    }
    
    //时间戳进行倒计时
    long startLong = _nowTimeSp;
    long finishLong = _finalMinuteSp;
    [self startLongLongStartStamp:startLong longlongFinishStamp:finishLong];
    
    
}

///此方法用两个时间戳做参数进行倒计时
-(void)startLongLongStartStamp:(long)strtL longlongFinishStamp:(long) finishL {
    __weak __typeof(self) weakSelf= self;
    
    NSLog(@"second = %ld, minute = %ld", strtL, finishL);
    
    [_countdown countDownWithStratTimeStamp:strtL finishTimeStamp:finishL completeBlock:^(NSInteger day, NSInteger hour, NSInteger minute, NSInteger second) {
        
        [weakSelf refreshUIDay:day hour:hour minute:minute second:second];
    }];
}
-(void)refreshUIDay:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second{
    
    NSString *str_1 = [NSString stringWithFormat:@"%ld", second];
    NSString *str_2 = [NSString stringWithFormat:@"%ld", minute];
    NSLog(@"~~~~~~~~~%@~~~~~%@",str_2,str_1);
    if (second == 0 && minute == 0) {
        
        [self refreshUI];
        
        //暂停组播
        [self processStopMultiCast];
        
        return;
    }
    
    if (minute<10) {
        
        self.minute_1 = [NSString stringWithFormat:@"%@", @"0"];
        self.minute_2 = [NSString stringWithFormat:@"%@",str_2];
        
    }else{
        
        self.minute_1 = [NSString stringWithFormat:@"%@",[str_2 substringToIndex:1]];
        self.minute_2 = [NSString stringWithFormat:@"%@",[str_2 substringFromIndex:1]];
        
    }
    if (second<10) {
        
        self.second_1 = [NSString stringWithFormat:@"%@",@"0"];
        self.second_2 = [NSString stringWithFormat:@"%@",str_1];
        
        
    }else{
        
        self.second_1 = [NSString stringWithFormat:@"%@",[str_1 substringToIndex:1]];
        self.second_2 = [NSString stringWithFormat:@"%@",[str_1 substringFromIndex:1]];
        
    }
    
    
}


#pragma mark- GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    //连接成功，可查看newSocket.connectedHost和newSocket.connectedPort等参数
    self.clientSocket = newSocket;
    [newSocket readDataToLength:6 withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString * receive = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"$$$$$$$tcp server didReadData:%@",receive);
    [[NSNotificationCenter defaultCenter] postNotificationName:OnlineNSNotificationName object:nil userInfo:@{@"message":[NSString stringWithFormat:@"%d",MSG_ONLINE_RECEIVED]}];
    [self handleMessage:MSG_ONLINE_RECEIVED];
}
-(void) handleMessage:(const int)value {
    switch(value){
        case MSG_ONLINE_RECEIVED:
            NSLog(@"process notification MSG_ONLINE_RECEIVED");
            [self.sendTimeOutTimer invalidate];
            self.sendTimeOutTimer =nil;
            //停止接收上线包
            [self stopServerSocket];
            //停止广播
            [GLobalProcessMultiCastLinkData  stopSendMultiBroadcast];
            //multicastTimer.cancel();
            [self.sendTimeOutTimer invalidate];
            self.multiCastButtonSending =false;
            self.sendTimeOutTimer = nil;
//            [self refreshUI];
            break;
        case MSG_MULTICAST_TIMEOUT:
            NSLog(@"process notification MSG_MULTICAST_TIMEOUT");
            [self.sendTimeOutTimer invalidate];
            self.sendTimeOutTimer =nil;
            //停止接受上线包
            [self stopServerSocket];
            //停止广播
            [GLobalProcessMultiCastLinkData  stopSendMultiBroadcast];
            [self.sendTimeOutTimer invalidate];
            self.sendTimeOutTimer = nil;

            self.multiCastButtonSending =false;
            _retry = YES;
            
//            [MBProgressHUD showSuccess:Localized(@"连接失败")];
            self.isSuccess = NO;
            ///猫眼连接失败
            [self refreshUI];
            break;
        case MSG_AP_RECEIVED_ACK:
            break;
        case MSG_CONNECTED_APMODE:
            break;
        case MSG_APMODE_TIMEOUT:
            break;
        default:
            break;
    }
    
}//

//主线程返回界面
-(void)refreshUI{
    //倒计时结束
     [_countdown destoryTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
       
        if (self.isSuccess) {
            [MBProgressHUD showSuccess:Localized(@"Cat'sEyeAccessSuccessfully")];
        }else{
            [MBProgressHUD showError:Localized(@"CatEyeFailure")];
        }
        KDSAddCatEye4VC * addCateye = [KDSAddCatEye4VC new];
        addCateye.isSuccess = self.isSuccess;
        addCateye.gatewayModel = self.gatewayModel;
        addCateye.deviceId = self.deviceSN;
        [self.navigationController pushViewController:addCateye animated:YES];
    });
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err;
{
    NSLog(@"tcp server socketDidDisconnect,err:%@",err);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"didWriteDataWithTag  %ld",tag);
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    if (elapsed <= READ_TIMEOUT)
    {
        NSString *warningMsg = @"Are you still there?\r\n";
        NSData *warningData = [warningMsg dataUsingEncoding:NSUTF8StringEncoding];
        
        [self.clientSocket writeData:warningData withTimeout:-1 tag:0];
        return 0;
    }
    
    return 0;
}

-(void)processStopMultiCast
{
    [self.sendTimeOutTimer invalidate];
    self.sendTimeOutTimer =nil;
    //停止接收上线包
    [self stopServerSocket];
    NSLog(@"Button multiCastButtonSending stop");

    //停止广播
    [GLobalProcessMultiCastLinkData  stopSendMultiBroadcast];
    [self.sendTimeOutTimer invalidate];
    self.sendTimeOutTimer = nil;
    
    self.multiCastButtonSending = false;

}

-(void)stopServerSocket
{
    [self.serverSocket disconnect];
    self.serverSocket = nil;
}

- (void) didInBackground: (NSNotification *)notification {
    
    NSLog(@"倒计时进入后台");
    [_countdown destoryTimer];
    
}

- (void) willEnterForground: (NSNotification *)notification {
    
    NSLog(@"倒计时进入前台");
    [self getNowTimeSP:@""];  //进入前台重新获取当前的时间戳，在进行倒计时， 主要是为了解决app退到后台倒计时停止的问题，缺点就是不能防止用户更改本地时间造成的倒计时错误
    
}
-(void)multiCastTimerOutProcess {
    NSLog(@"delayMethod");
    [self handleMessage:MSG_MULTICAST_TIMEOUT];
}


#pragma mark - 通知。
///猫眼添加到网关的通知。
- (void)deviceDidJoinGateway:(NSNotification *)noti
{
    MQTTSubEvent event = noti.userInfo[MQTTEventKey];
    NSDictionary *param = noti.userInfo[MQTTEventParamKey];
    GatewayDeviceModel * gwDeviceModel = param[@"device"];
    NSString * deviceId = param[@"deviceId"];
    NSString * gwId = param[@"gwId"];
    
    if ([event isEqualToString:MQTTSubEventDeviceOnline] && [self.deviceSN isEqualToString:deviceId]) {
        self.isSuccess = YES;
        KDSCatEye * cateye = [KDSCatEye new];
        GatewayModel * gwModel = [GatewayModel new];
        gwModel.deviceSN = gwId;
        KDSGW *gw = [KDSGW new];
        gw.model = gwModel;
        cateye.gw = gw;
        cateye.gatewayDeviceModel = gwDeviceModel;
        [KDSFTIndicator showNotificationWithTitle:Localized(@"Be careful") message:[NSString stringWithFormat:@"%@%@",deviceId,Localized(@"cateyeOnline")] tapHandler:^{
            
        }];
        self.isSuccess = YES;
        [self refreshUI];
    }
 
}

-(void)navRightClick
{
    KDSCateyeHelpVC * vc = [KDSCateyeHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
