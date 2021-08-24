//
//  KDSNewDoorLockVerificationVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/3/11.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSNewDoorLockVerificationVC.h"
#import "KDSWifiLockHelpVC.h"
#import "CYCircularSlider.h"
#import "KDSBleAssistant.h"
#import "NSData+JKEncrypt.h"
#import "NSString+extension.h"
#import "KDSHttpManager+WifiLock.h"
#import "KDSGCDSocketManager.h"
#import "KDSAddWiFiLockFailVC.h"
#import "KDSAddNewWiFiLockFailVC.h"
#import "KDSAddNewWiFiLockStep1VC.h"
#import "KDSInPutWiFiPwdVerificationVC.h"
#import "KDSUpDataAdminiContinueVerificationVC.h"



@interface KDSNewDoorLockVerificationVC ()<senderValueChangeDelegate,TcpRecvDelegate>
@property (nonatomic,strong)CYCircularSlider *circularSlider;
///进度条百分比
@property (nonatomic,strong)UILabel * sliderValueLb;
///发送门锁管理员密码
@property (nonatomic,strong)UILabel * showTipsLb1;
///门锁验证管理员密码
@property (nonatomic,strong)UILabel * showTipsLb2;
///门锁设备验证中
@property (nonatomic,strong)UILabel * showTipsLb3;
///第一步
@property (nonatomic,strong)UIImageView * showTipsImg1;
@property (nonatomic,strong)UIImageView * showHideImg1;
///第二步
@property (nonatomic,strong)UIImageView * showTipsImg2;
@property (nonatomic,strong)UIImageView * showHideImg2;
///第三步
@property (nonatomic,strong)UIImageView * showTipsImg3;
@property (nonatomic,strong)UIImageView * showHideImg3;
@property (strong,nonatomic) NSMutableArray *clientSocket;
///保证只解析一次数据（46个字节是一个完整的包，会有丢包的可能，数据会多发，所有只要接收到一个完整的数据就设置为NO，默认是YES）
@property (nonatomic,assign) BOOL analysis ;
///只有是Wi-Fi状态才可以配网
@property (nonatomic,assign) BOOL wifiStatus;
///与Wi-Fi模块数据交互成功
@property (nonatomic,assign) BOOL wifiSuccess;
@property (nonatomic,strong) KDSGCDSocketManager * socketManager;
///重复验证CRC的时候会用到
@property (nonatomic,strong) NSData * doorLockData;
///180秒没有收到模块发来成功的字符串，就失败
@property (nonatomic,strong) NSTimer * ReceiveDataOutTimer;
///管理员密码输入错误次数（5次错误即失败）
@property (nonatomic,assign) int intPutPwdCount;
@property (nonatomic,strong)CABasicAnimation * rotateAnimation;

@end

@implementation KDSNewDoorLockVerificationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = @"门锁验证";
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [self setUI];
    self.intPutPwdCount = 0;
    self.ReceiveDataOutTimer = [NSTimer scheduledTimerWithTimeInterval:100.0 target:self selector:@selector(receiveDataOutTimer:) userInfo:nil repeats:NO];
    self.socketManager = [KDSGCDSocketManager sharedManager];
    self.socketManager.socketPort = 56789;
    self.socketManager.isApConfigStr = @"apConfig";
    self.socketManager.delegate = self;
    [self startImgRotatingWidthImg:self.showTipsImg1];
    if ([self.upDataAdminiContinueStr isEqualToString:@"upDataAdminiContinueStr"]) {
        NSLog(@"修改管理员密码后交换密码因子");
       self.socketManager.wifiSuccess = YES;
       [[KDSGCDSocketManager sharedManager].serverSocket writeData:[@"ApFactorResend" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:10002];
    }else{
        [self.socketManager startChatServer];
    }
   
}

-(void)setUI
{
    UIView * supView = [UIView new];
    supView.backgroundColor = UIColor.whiteColor;
    supView.layer.masksToBounds = YES;
    supView.layer.cornerRadius = 10;
    [self.view addSubview:supView];
    [supView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.top.equalTo(self.view.mas_top).offset(10);
        make.bottom.equalTo(self.view.mas_bottom).offset(-10);
    }];
    
    CGRect sliderFrame = CGRectMake((KDSScreenWidth-295)/2, 55, 275,275);
    self.circularSlider =[[CYCircularSlider alloc]initWithFrame:sliderFrame];
    self.circularSlider.delegate = self;
    [_circularSlider setAngleCurrent:80];
    [supView addSubview:self.circularSlider];
    
    UIImageView * tipsImgView = [UIImageView new];
    tipsImgView.image = [UIImage imageNamed:@"addWiFiLockConnectingIcon"];
    [supView addSubview:tipsImgView];
    [tipsImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@180);
        make.centerX.equalTo(supView);
        make.center.equalTo(self.circularSlider);
    }];
    
    self.sliderValueLb = [UILabel new];
    self.sliderValueLb.text = [NSString stringWithFormat:@"%@%%",@"10"];
    self.sliderValueLb.textColor = UIColor.blackColor;
    self.sliderValueLb.textAlignment = NSTextAlignmentCenter;
    self.sliderValueLb.font = [UIFont systemFontOfSize:27];
    [supView addSubview:self.sliderValueLb];
    [self.sliderValueLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@25);
        make.centerX.equalTo(supView);
        make.center.equalTo(tipsImgView);
    }];
    UILabel * tipsLb = [UILabel new];
    tipsLb.text = @"loading...";
    tipsLb.textColor = KDSRGBColor(202, 202, 202);
    tipsLb.font = [UIFont systemFontOfSize:13];
    tipsLb.textAlignment = NSTextAlignmentCenter;
    [supView addSubview:tipsLb];
    [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sliderValueLb.mas_bottom).offset(5);
        make.centerX.equalTo(supView);
        make.height.equalTo(@15);
        
    }];
    UILabel * tipsLb1 = [UILabel new];
    tipsLb1.text = @"请将手机和设备尽量靠近路由器";
    tipsLb1.textColor = KDSRGBColor(31, 31, 31);
    tipsLb1.textAlignment = NSTextAlignmentCenter;
    tipsLb1.font = [UIFont systemFontOfSize:14];
    [supView addSubview:tipsLb1];
    [tipsLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.circularSlider.mas_bottom).offset(0);
        make.height.equalTo(@20);
        make.centerX.equalTo(supView);
    }];
    
    self.showTipsImg1 =[UIImageView new];
    self.showTipsImg1.image = [UIImage imageNamed:@"addWiFiLockStatusOpenImg"];
    [supView addSubview:self.showTipsImg1];
    [self.showTipsImg1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@21);
        make.top.equalTo(tipsLb1.mas_bottom).offset(KDSScreenHeight > 667 ? 123 : 73);
        make.right.equalTo(supView.mas_right).offset(-20);
    }];
    self.showHideImg1 =[UIImageView new];
    self.showHideImg1.image = [UIImage imageNamed:@"addWiFiLockStatusYesImg"];
    [supView addSubview:self.showHideImg1];
    self.showHideImg1.hidden = YES;
    [self.showHideImg1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@21);
        make.top.equalTo(tipsLb1.mas_bottom).offset(KDSScreenHeight > 667 ? 123 : 73);
        make.right.equalTo(supView.mas_right).offset(-20);
    }];
    self.showTipsLb1 = [UILabel new];
    self.showTipsLb1.text = @"发送门锁管理员密码";
    self.showTipsLb1.textColor = KDSRGBColor(31, 31, 31);
    self.showTipsLb1.textAlignment = NSTextAlignmentLeft;
    self.showTipsLb1.font = [UIFont systemFontOfSize:13];
    [supView addSubview:self.showTipsLb1];
    [self.showTipsLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsLb1.mas_bottom).offset(KDSScreenHeight > 667 ? 120 : 70);
        make.height.equalTo(@30);
        make.left.equalTo(supView.mas_left).offset(25);
        make.right.equalTo(self.showTipsImg1.mas_left).offset(-20);
    }];
    UIView * line1 = [UIView new];
    line1.backgroundColor = KDSRGBColor(240, 240, 240);
    [supView addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.showTipsLb1.mas_bottom).offset(0);
        make.height.equalTo(@1);
        make.left.equalTo(supView.mas_left).offset(25);
        make.right.equalTo(supView.mas_right).offset(-28);
    }];
    UIView * line2 = [UIView new];
    line2.backgroundColor = KDSRGBColor(240, 240, 240);
    [supView addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line1.mas_bottom).offset(45);
        make.height.equalTo(@1);
        make.left.equalTo(supView.mas_left).offset(25);
        make.right.equalTo(supView.mas_right).offset(-28);
    }];
    self.showTipsImg2 =[UIImageView new];
    self.showTipsImg2.image = [UIImage imageNamed:@"addWiFiLockStatusOffImg"];
    [supView addSubview:self.showTipsImg2];
    [self.showTipsImg2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@21);
        make.bottom.equalTo(line2.mas_top).offset(-3);
        make.right.equalTo(supView.mas_right).offset(-20);
    }];
    self.showHideImg2 =[UIImageView new];
    self.showHideImg2.image = [UIImage imageNamed:@"addWiFiLockStatusYesImg"];
    [supView addSubview:self.showHideImg2];
    self.showHideImg2.hidden = YES;
    [self.showHideImg2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@21);
        make.bottom.equalTo(line2.mas_top).offset(-3);
        make.right.equalTo(supView.mas_right).offset(-20);
    }];
    self.showTipsLb2 = [UILabel new];
    self.showTipsLb2.text = @"门锁验证管理员密码";
    self.showTipsLb2.textColor = KDSRGBColor(205, 205, 205);
    self.showTipsLb2.textAlignment = NSTextAlignmentLeft;
    self.showTipsLb2.font = [UIFont systemFontOfSize:13];
    [supView addSubview:self.showTipsLb2];
    [self.showTipsLb2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(line2.mas_bottom).offset(0);
        make.height.equalTo(@30);
        make.left.equalTo(supView.mas_left).offset(25);
        make.right.equalTo(self.showTipsImg1.mas_left).offset(-20);
    }];
    UIView * line3 = [UIView new];
    line3.backgroundColor = KDSRGBColor(240, 240, 240);
    [supView addSubview:line3];
    [line3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line2.mas_bottom).offset(45);
        make.height.equalTo(@1);
        make.left.equalTo(supView.mas_left).offset(25);
        make.right.equalTo(supView.mas_right).offset(-28);
    }];
    self.showTipsImg3 =[UIImageView new];
    self.showTipsImg3.image = [UIImage imageNamed:@"addWiFiLockStatusOffImg"];
    [supView addSubview:self.showTipsImg3];
    [self.showTipsImg3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@21);
        make.bottom.equalTo(line3.mas_top).offset(-3);
        make.right.equalTo(supView.mas_right).offset(-20);
    }];
    self.showHideImg3 =[UIImageView new];
    self.showHideImg3.image = [UIImage imageNamed:@"addWiFiLockStatusYesImg"];
    [supView addSubview:self.showHideImg3];
    self.showHideImg3.hidden = YES;
    [self.showHideImg3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@21);
        make.bottom.equalTo(line3.mas_top).offset(-3);
        make.right.equalTo(supView.mas_right).offset(-20);
    }];
    self.showTipsLb3 = [UILabel new];
    self.showTipsLb3.text = @"门锁设备验证中";
    self.showTipsLb3.textColor = KDSRGBColor(205, 205, 205);
    self.showTipsLb3.textAlignment = NSTextAlignmentLeft;
    self.showTipsLb3.font = [UIFont systemFontOfSize:13];
    [supView addSubview:self.showTipsLb3];
    [self.showTipsLb3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(line3.mas_bottom).offset(0);
        make.height.equalTo(@30);
        make.left.equalTo(supView.mas_left).offset(25);
        make.right.equalTo(self.showTipsImg1.mas_left).offset(-20);
    }];
    
}

// 开始旋转
- (void)startImgRotatingWidthImg:(UIImageView *)imgView {
    self.rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    self.rotateAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    self.rotateAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2];
    self.rotateAnimation.duration = 1.0;
    self.rotateAnimation.repeatCount = MAXFLOAT;
    [imgView.layer addAnimation:self.rotateAnimation forKey:nil];
    
}
// 停止旋转
- (void)stopImgRotatingWidthImg:(UIImageView *)imgView
{
    CFTimeInterval pausedTime = [self.showTipsImg1.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    imgView.layer.speed = 0.0;
    imgView.layer.timeOffset = pausedTime;
    self.rotateAnimation.removedOnCompletion = YES;
    self.rotateAnimation.fillMode = kCAFillModeRemoved;
}

#pragma mark senderValueChangeDelegate

-(void)senderVlueWithNum:(int)num{
    
//    self.sliderValueLb.text = [NSString stringWithFormat:@"%d%%",num];
}

#pragma mark 控件点击事件

-(void)navRightClick
{
    KDSWifiLockHelpVC * vc = [KDSWifiLockHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)navBackClick
{
    UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:@"" message:@"确定重新开始配网吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[KDSAddNewWiFiLockStep1VC class]]) {
                [[KDSGCDSocketManager sharedManager].serverSocket disconnect];
                KDSAddNewWiFiLockStep1VC *A =(KDSAddNewWiFiLockStep1VC *)controller;
                [self.navigationController popToViewController:A animated:YES];
            }
        }
    }];
    [cancelAction setValue:KDSRGBColor(164, 164, 164) forKey:@"titleTextColor"];
    [alerVC addAction:cancelAction];
    [alerVC addAction:okAction];
    [self presentViewController:alerVC animated:YES completion:nil];
}

-(void)recv:(NSData *)data withTag:(long)tag
{
    if ([self.adminPwd isEqualToString:@"12345678"]) {
        UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:@"" message:@"门锁初始密码不能验证，\n 请修改门锁管理密码或重新输入" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * againInPutAction = [UIAlertAction actionWithTitle:@"重新输入" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //返回上一个页面需断开socket
            [[KDSGCDSocketManager sharedManager].serverSocket disconnect];
            [self.navigationController popViewControllerAnimated:YES];
            
        }];
        UIAlertAction * changePasswordAction = [UIAlertAction actionWithTitle:@"修改密码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            KDSUpDataAdminiContinueVerificationVC * vc = [KDSUpDataAdminiContinueVerificationVC new];
            [self.navigationController pushViewController:vc animated:YES];
        }];
        [againInPutAction setValue:KDSRGBColor(164, 164, 164) forKey:@"titleTextColor"];
        [alerVC addAction:againInPutAction];
        [alerVC addAction:changePasswordAction];
        [self presentViewController:alerVC animated:YES completion:nil];
        return;
    }
    KDSGCDSocketManager * socketManager = [KDSGCDSocketManager sharedManager];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (data.length >= 46) {
            ///接收正确的数据进行验证
//            self.showTipsImg1.image = [UIImage imageNamed:@"addWiFiLockStatusYesImg"];
            self.showTipsImg1.hidden = YES;
            self.showHideImg1.hidden = NO;
            self.showTipsImg2.image = [UIImage imageNamed:@"addWiFiLockStatusOpenImg"];
            self.showTipsLb2.textColor = KDSRGBColor(31, 31, 31);
            [self stopImgRotatingWidthImg:self.showTipsImg1];
            [self startImgRotatingWidthImg:self.showTipsImg2];
            [_circularSlider setAngleCurrent:140];
            self.sliderValueLb.text = @"50%";
            [self getRandomCodeWidthAdminPwd:self.adminPwd resultData:data];
            self.doorLockData = data;
        }else{
            ///字节不够的话，等3秒，把接收的拼接在一起
            NSMutableData * currentData = [NSMutableData new];
            [currentData appendData:data];
            NSLog(@"是否拿到模块发过来的数据：%@---%@时间戳：%@",data,currentData,[NSDate date]);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (currentData.length >= 46) {
                    ///接收正确的数据进行验证
                    [self getRandomCodeWidthAdminPwd:self.adminPwd resultData:currentData];
                    self.doorLockData = currentData;
                }else{
                    [socketManager.serverSocket writeData:[@"CRCError" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:10 tag:0];
                    ///数据库接收失败、或者接收的错误数据
                }
            });
        }
    });
}

-(void)getRandomCodeWidthAdminPwd:(NSString *)pwd resultData:(NSData *)data
{
    ///28字节的随机数A+4字节的CRC32+13字节的eSN（WF开头）+ 1字节功能集共45个字节
    KDSGCDSocketManager * socketManager = [KDSGCDSocketManager sharedManager];
    NSData * eSN = [data subdataWithRange:NSMakeRange(32, 13)];
    NSString * wifiSN = [[NSString alloc] initWithData:eSN encoding:NSUTF8StringEncoding];
    NSString * string = @"";
    for (int i = 0; i<pwd.length; i ++) {
        NSString * temstring = [NSString ToHex:[pwd substringWithRange:NSMakeRange(i, 1)].integerValue];
        string  = [string stringByAppendingFormat:@"%02ld",(long)temstring.integerValue];
    }
    NSData * datastring = [KDSBleAssistant convertHexStrToData:string];
    NSString *aString = [[NSString alloc] initWithData:datastring encoding:NSUTF8StringEncoding];
    //key AES256后的值
    NSString * Haxi = [NSString sha256HashFor:aString];
    NSData *resultData = [[data subdataWithRange:NSMakeRange(0, 32)] aesWifiLock256_decryptData:[KDSBleAssistant convertHexStrToData:Haxi]];
    int crc = [NSString data2Int:[resultData subdataWithRange:NSMakeRange(28, 4)]];
    //测试数据：随机数A
    int32_t randomCode = [[resultData subdataWithRange:NSMakeRange(0, 28)] crc32];
    ///添加到服务器用到的随机数A
    NSString * randomCodeData = [KDSBleAssistant convertDataToHexStr:[resultData subdataWithRange:NSMakeRange(0, 28)]];
    u_int8_t tt;
    [[data subdataWithRange:NSMakeRange(45, 1)] getBytes:&tt length:sizeof(tt)];
    long long int value = randomCode;
    Byte byte[4] = {};
    byte[3] =(Byte) ((value>>24) & 0xFF);
    byte[2] =(Byte) ((value>>16) & 0xFF);
    byte[1] =(Byte) ((value>>8) & 0xFF);
    byte[0] =(Byte) (value & 0xFF);
    //    NSData *adata = [[NSData alloc] initWithBytes:byte length:4];
    //    NSLog(@"%s-%@",byte,adata);
    NSLog(@"随机数生成的CRC：%d原始CRC：%d",randomCode,crc);
    if (randomCode != crc) {
        self.intPutPwdCount ++;
        NSString * messageStr;NSString * titleStr;
        titleStr = @"好的";
        messageStr = @"门锁管理员密码验证失败\n请重新输入";
        if (self.intPutPwdCount == 3) {
            messageStr = @"门锁管理密码验证失败3次，\n超过5次，配网失败";
            titleStr = @"确定";
        }if (self.intPutPwdCount == 5) {
            messageStr = @"门锁管理密码验证已失败5次，\n请修改管理密码，重新配网";
            titleStr = @"确定";
        }
        //方案一：密码错误直接失败
        [socketManager.serverSocket writeData:[@"CRCError" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:10 tag:0];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:nil message:messageStr preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * okAction = [UIAlertAction actionWithTitle:titleStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (self.intPutPwdCount >= 5) {
                    KDSAddWiFiLockFailVC * vc = [KDSAddWiFiLockFailVC new];
                    [self.navigationController pushViewController:vc animated:YES];
                    [[KDSGCDSocketManager sharedManager].serverSocket disconnect];
                    
                }else{
                    [self inputPwdAgain];
                }
            }];
            [alerVC addAction:okAction];
            [self presentViewController:alerVC animated:YES completion:nil];
        });
        
    }else{
        ///拿到随机码、wifiSN、绑定设备
        self.showTipsImg2.hidden = YES;
        self.showHideImg2.hidden = NO;
        self.showTipsImg3.hidden = YES;
        self.showHideImg3.hidden = NO;
        self.showTipsLb3.textColor = KDSRGBColor(31, 31, 31);
        [self stopImgRotatingWidthImg:self.showTipsImg2];
        self.sliderValueLb.text = @"100%";
        [_circularSlider setAngleCurrent:200];
        [socketManager.serverSocket writeData:[@"CRCSuccess" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:10 tag:0];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            KDSWifiLockModel * model = [KDSWifiLockModel new];
            model.wifiSN = wifiSN;
            model.lockNickname = wifiSN;
            model.isAdmin = @"1";
            model.randomCode = randomCodeData;
            model.functionSet = @(tt).stringValue;
            self.wifiSuccess = YES;
            [self.ReceiveDataOutTimer invalidate];
            self.ReceiveDataOutTimer = nil;
            //ap配网（纯wifi锁）
            KDSInPutWiFiPwdVerificationVC * vc = [KDSInPutWiFiPwdVerificationVC new];
            vc.model = model;
            [self.navigationController pushViewController:vc animated:YES];
        });
    }
}

-(void)recvDataTimeOut
{
    
}
-(void)receiveDataOutTimer:(NSTimer *)receiceDataOutTimer
{
    [self.ReceiveDataOutTimer invalidate];
    self.ReceiveDataOutTimer = nil;
    [[KDSGCDSocketManager sharedManager].serverSocket disconnect];
    KDSAddNewWiFiLockFailVC * vc = [KDSAddNewWiFiLockFailVC new];
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(void)inputPwdAgain
{
    __weak typeof(self) weakSelf = self;
    UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:@"" message:@"请输入管理员密码" preferredStyle:UIAlertControllerStyleAlert];
    [alerVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.secureTextEntry = NO;
        textField.textAlignment = NSTextAlignmentCenter;
        textField.textColor = KDSRGBColor(0x10, 0x10, 0x10);
        textField.font = [UIFont systemFontOfSize:13];
        [textField addTarget:weakSelf action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf getRandomCodeWidthAdminPwd:alerVC.textFields.firstObject.text resultData:self.doorLockData];
        
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alerVC addAction:ok];
    [alerVC addAction:cancel];
    [self presentViewController:alerVC animated:YES completion:nil];
}


///首页长按开锁密码输入框限制6-12位数字密码
-(void)textFieldTextDidChange:(UITextField *)sender{
    
    char pwd[13] = {0};
    int index = 0;
    NSString *text = sender.text.length > 12 ? [sender.text substringToIndex:12] : sender.text;
    for (NSInteger i = 0; i < text.length; ++i)
    {
        unichar c = [text characterAtIndex:i];
        if (c < '0' || c > '9') continue;
        pwd[index++] = c;
    }
    sender.text = @(pwd);
    
}
-(void)dealloc
{
    [self stopImgRotatingWidthImg:self.showTipsImg3];
}


@end
