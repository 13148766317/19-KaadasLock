//
//  KDSAddZigBeeLock5VC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/10.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSAddZigBeeLock5VC.h"
#import "KDSAddLockSuccessVC.h"
#import "MBProgressHUD+MJ.h"
#import "KDSCountdown.h"


static int TIMER_MULTICAST_TIMEOUT        = 60;//60s

@interface KDSAddZigBeeLock5VC ()

@property (nonatomic, strong) KDSCountdown *countdown;//允许入网倒计时定时器
@property (nonatomic) long nowTimeSp;
@property (nonatomic) long finalMinuteSp;

///是否连接成功
@property(nonatomic,assign)BOOL isSuccess;

@end

@implementation KDSAddZigBeeLock5VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"addDoorLock");
    [self setUI];
    //开始倒计时
    [self countdownTime];
    [[KDSMQTTManager sharedManager] gw:self.gw.model setDeviceAccess:@"zigbee" enable:YES completion:^(NSError * _Nullable error, BOOL success) {
        
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidJoinGateway:) name:KDSMQTTEventNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDSMQTTEventNotification object:nil];
}

-(void)setUI
{
    UIImageView * bgImg = [UIImageView new];
    bgImg.image = [UIImage imageNamed:@"loginBg"];
    [self.view addSubview:bgImg];
    [bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(0);
    }];
    ///添加门锁的logo
    UIImageView * addZigBeeLocklogoImg = [UIImageView new];
    addZigBeeLocklogoImg.image = [UIImage imageNamed:@"添加ZigBee_添加猫眼_猫眼绑定-等待"];
    [self.view addSubview:addZigBeeLocklogoImg];
    [addZigBeeLocklogoImg mas_makeConstraints:^(MASConstraintMaker *make) {
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
    [addZigBeeLocklogoImg.layer addAnimation:animation forKey:nil];
    
    
    UIImageView * smallIconImg = [UIImageView new];
    smallIconImg.image = [UIImage imageNamed:@"Gateway lock"];
    [self.view addSubview:smallIconImg];
    [smallIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(53);
        make.height.mas_equalTo(60);
        make.centerX.mas_equalTo(addZigBeeLocklogoImg.mas_centerX).offset(0);
        make.centerY.mas_equalTo(addZigBeeLocklogoImg.mas_centerY).offset(0);
    }];
    
    ///提示语：正在连接网关锁···
    UILabel * tipMsgLabe = [UILabel new];
    tipMsgLabe.text = Localized(@"Connecting Gateway Lock");
    tipMsgLabe.font = [UIFont systemFontOfSize:17];
    tipMsgLabe.textColor = UIColor.whiteColor;
    tipMsgLabe.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipMsgLabe];
    [tipMsgLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(18);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.centerY.mas_equalTo(self.view.mas_centerY).offset(0);
    }];
    
    UILabel * detailLabe = [UILabel new];
    detailLabe.text = Localized(@"It takes about two minutes.");
    detailLabe.font = [UIFont systemFontOfSize:12];
    detailLabe.textColor = KDSRGBColor(170, 228, 255);
    detailLabe.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:detailLabe];
    [detailLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe.mas_bottom).offset(14);
        make.height.mas_equalTo(16);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    
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
        
        NSTimeInterval time = TIMER_MULTICAST_TIMEOUT;//秒数
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
    
    NSLog(@"minute = %ld, second = %ld", minute, second);
    if (second == 0 && minute == 0) {
        //倒计时结束没有收到入网成功的推送消息认为是入网失败
        [_countdown destoryTimer];
        [MBProgressHUD showError:Localized(@"Gateway Lock Add Failure")];
        self.isSuccess = NO;
        KDSAddLockSuccessVC * VC = [KDSAddLockSuccessVC new];
        VC.isSuccess = self.isSuccess;
        [self.navigationController pushViewController:VC animated:YES];
        
        return;
    }
    
}

- (void) didInBackground: (NSNotification *)notification {
    
    NSLog(@"倒计时进入后台");
    [_countdown destoryTimer];
    
}

- (void) willEnterForground: (NSNotification *)notification {
    
    NSLog(@"倒计时进入前台");
    [self getNowTimeSP:@""];  //进入前台重新获取当前的时间戳，在进行倒计时， 主要是为了解决app退到后台倒计时停止的问题，缺点就是不能防止用户更改本地时间造成的倒计时错误
    
}

#pragma mark - 通知。
///锁添加到网关的通知。
- (void)deviceDidJoinGateway:(NSNotification *)noti
{
    MQTTSubEvent event = noti.userInfo[MQTTEventKey];
    NSDictionary *param = noti.userInfo[MQTTEventParamKey];
    NSString *gwId = param[@"gwId"];
    if ([event isEqualToString:MQTTSubEventDeviceOnline] && [gwId isEqualToString:self.gw.model.deviceSN])
    {
        [_countdown destoryTimer];
        self.isSuccess = YES;
        [MBProgressHUD showSuccess:Localized(@"gwLockJoinGatewaySuccess")];
        GatewayDeviceModel *m = param[@"device"];
        KDSAddLockSuccessVC * VC = [KDSAddLockSuccessVC new];
        VC.gw = self.gw;
        VC.device = m;
        VC.isSuccess = self.isSuccess;
        [self.navigationController pushViewController:VC animated:YES];
    }
    
}

@end
